import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  static final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // Voice
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // NVIDIA API - injected at build time via --dart-define=NVIDIA_API_KEY=xxx
  // Never hardcoded in source. Falls back to smart local responses if not set.
  static const String _apiKey = String.fromEnvironment('NVIDIA_API_KEY', defaultValue: '');
  static const String _apiUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';
  static const String _model = 'nvidia/nemotron-3.5-lightning-30b-a3b';

  // Debug: check if API key is configured (does NOT expose the key)
  static bool get isApiConfigured => _apiKey.isNotEmpty && _apiKey.length > 10;

  // System prompt: health/smoking only, no off-topic chatter
  static const String _systemPrompt = '''You are Dr. Quit, an AI health coach inside the QuitVape app. Your ONLY job is to help users quit vaping/smoking and improve their health.

STRICT RULES:
1. ONLY answer questions about: quitting vaping/smoking, nicotine addiction, cravings, withdrawal symptoms, lung health, oral health, heart health, mental health related to quitting, healthy alternatives, breathing exercises, diet/exercise during quitting.
2. If the user asks about ANYTHING else (politics, jokes, coding, movies, general knowledge, math, etc.), politely refuse: "I'm your quit coach — I only help with quitting vaping and health. Ask me about cravings, withdrawal, or your health progress! 💪"
3. Never provide medical diagnosis. For serious symptoms, advise seeing a doctor.
4. Be warm, encouraging, and concise. Use the user's language (Urdu, English, Hindi, Roman Urdu — match their language).
5. Keep responses under 120 words unless they ask for detail.
6. Celebrate their progress and motivate them to stay vape-free.''';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _messages.add({
      'role': 'assistant',
      'content': 'Hey! 👋 I\'m Dr. Quit, your AI health coach! 🩺\n\nI\'m here 24/7 to help you quit vaping and stay healthy.\n\n💬 Type or 🎤 speak — ask me about cravings, withdrawal, or your health!\n\nYou can talk in Urdu, English, Hindi — anything!',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  // Voice input: speech to text
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _sendMessage();
          }
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎤 Mic permission needed for voice chat')),
        );
      }
    }
  }

  // Voice output: speak the AI response
  // (TTS removed - was breaking Android build. Voice input still works.)

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _getAIResponse(text);
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': _getFallbackResponse(text),
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    if (_apiKey.isEmpty) {
      // API not configured yet - use smart fallback
      await Future.delayed(const Duration(seconds: 1));
      return _getFallbackResponse(userMessage);
    }

    final days = QuitService.getQuitDuration().inDays;
    final cravingsBeaten = QuitService.getCravingsResisted();
    final userName = QuitService.getUserName();
    final userWeight = QuitService.getUserWeight();
    final userHeight = QuitService.getUserHeight();

    final systemPrompt = '''$_systemPrompt

About this user:
- Name: ${userName.isNotEmpty ? userName : 'friend'}
- $days days vape-free
- $cravingsBeaten cravings beaten so far
${userWeight > 0 ? '- Weight: ${userWeight.toStringAsFixed(0)} kg' : ''}
${userHeight > 0 ? '- Height: ${userHeight.toStringAsFixed(0)} cm' : ''}

Use their name occasionally. If weight/height is known, you can give personalized health tips (e.g., exercise suggestions, lung capacity). Match the user's language (Urdu, English, Hindi, Roman Urdu). Be warm and concise.''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ..._messages.take(10).map((m) => {'role': m['role'], 'content': m['content']}),
      {'role': 'user', 'content': userMessage},
    ];

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 500,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      // Log the actual error for debugging
      print('NVIDIA API Error: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      throw Exception('API error: ${response.statusCode}');
    }
  }

  // Track last fallback to avoid repetition
  static int _lastFallbackIndex = -1;

  String _getFallbackResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    final days = QuitService.getQuitDuration().inDays;
    final name = QuitService.getUserName();
    final greeting = name.isNotEmpty ? name.split(' ').first : 'friend';

    // Detect language - simple heuristic
    final isUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(userMessage);

    if (lower.contains('craving') || lower.contains('urge') || lower.contains('want')) {
      if (isUrdu) {
        return 'Craving ho rahi hai? Koi baat nahi! 💪 Ye sirf 3 minute me peak par jati hai phir kam ho jati hai.\n\nGehri saans lo... 4 second andar, 4 second roko, 4 second bahar. Tum $days din se strong ho — ye craving tumse badi nahi! 🔥';
      }
      return 'Having a craving? That\'s totally normal! 💪 Cravings peak at 3 minutes then fade.\n\nTry this: breathe in 4 seconds, hold 4, out 4. You\'ve been strong for $days days — this craving is NOT bigger than you! 🔥';
    }

    if (lower.contains('stress') || lower.contains('tension') || lower.contains('anxiet')) {
      if (isUrdu) {
        return 'Stress me smoking yaad aana natural hai. Lekin socho — kya cigarette ne kabhi tumhara stress khatam kiya? Nahi na!\n\n5 minute walk karo, pani piyo, ya mujhse baat karo. Me yahin hun! 🤗';
      }
      return 'Stress makes cravings worse, I know. But think — did smoking ever actually solve your stress? Nope!\n\nTake a 5-min walk, drink water, or just keep talking to me. I\'m here! 🤗';
    }

    if (lower.contains('relapse') || lower.contains('smoked') || lower.contains('vape') && lower.contains('did')) {
      if (isUrdu) {
        return 'Koi baat nahi, hota hai! 💛 Ek slip ka matlab ye nahi ke tum haar gaye.\n\n$days din ki mehnat zaya nahi hui. Abhi se dobara shuru karo — me tumhare saath hun! Kya tumhe trigger kiya tha?';
      }
      return 'Hey, it happens! 💛 One slip doesn\'t erase $days days of progress.\n\nRestart right now — I\'m with you! What triggered it? Let\'s figure it out together.';
    }

    // Default encouraging responses - varied and personalized, no repeats
    final defaults = isUrdu
        ? [
            '$greeting, tum $days din se vape-free ho — ye koi chhoti baat nahi! 🎉 Batao, aaj kaisa feel ho raha hai?',
            'Bohat khoob $greeting! 💪 Tumhari lungs har din heal ho rahi hain. Koi specific cheez pareshan kar rahi hai?',
            'Tumhari himmat dekh kar khushi hoti hai $greeting! 🌟 Cravings ke bare me baat karna chahte ho ya health tips chahiye?',
            '$days din! Tum already jeet rahe ho $greeting! 🏆 Batao, me tumhari kis tarah madad kar sakta hun?',
            'Yaad rakho $greeting — har craving sirf 3 minute ki hoti hai! ⏱️ Tum is se zyada strong ho. Kya chal raha hai?',
          ]
        : [
            '$greeting, you\'re $days days vape-free — that\'s HUGE! 🎉 How are you feeling today?',
            'Amazing progress $greeting! 💪 Your lungs are healing every single day. What\'s on your mind?',
            'Your strength inspires me $greeting! 🌟 Want to talk about cravings or get some health tips?',
            '$days days! You\'re already winning $greeting! 🏆 How can I help you right now?',
            'Remember $greeting — every craving lasts just 3 minutes! ⏱️ You\'re stronger than that. What\'s going on?',
          ];

    // Pick a different response than last time
    int index;
    do {
      index = DateTime.now().millisecond % defaults.length;
    } while (index == _lastFallbackIndex && defaults.length > 1);
    _lastFallbackIndex = index;

    return defaults[index];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = QuitService.isPremium();
    final isUnlocked = QuitService.isItemUnlocked('ai_coach');

    if (!isPremium && !isUnlocked) {
      return Scaffold(
        backgroundColor: AppStyle.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👨‍⚕️ AI Quit Coach', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApiConfigured ? AppStyle.emerald.withOpacity(0.2) : AppStyle.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isApiConfigured ? '● LIVE' : '● OFFLINE',
                  style: TextStyle(
                    color: isApiConfigured ? AppStyle.emerald : AppStyle.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.3), Colors.purple.withOpacity(0.1)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('👨‍⚕️', style: TextStyle(fontSize: 60))),
                ),
                const SizedBox(height: 24),
                const Text('Meet Your AI Quit Coach',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text('A personal coach that talks to you 24/7 in YOUR language. Share feelings, beat cravings, stay motivated.',
                    style: TextStyle(color: AppStyle.textDim, fontSize: 15, height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppStyle.gradientEmerald,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text('👑 Unlock with Premium',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Or unlock with 1500 QuitCoins in the shop 🪙',
                    style: TextStyle(color: AppStyle.textFaint, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1310),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.4), Colors.purple.withOpacity(0.2)]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('👨‍⚕️', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Quit Coach', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                Row(
                  children: [
                    Icon(Icons.circle, color: isApiConfigured ? AppStyle.emerald : AppStyle.red, size: 8),
                    const SizedBox(width: 4),
                    Text(isApiConfigured ? 'Online • AI Live 🟢' : 'Offline • Limited replies 🔴',
                        style: const TextStyle(color: AppStyle.textDim, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return _buildMessage(msg['content']!, isUser);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          gradient: isUser ? AppStyle.gradientEmerald : null,
          color: isUser ? null : AppStyle.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFF1E2A24)),
        ),
        child: Text(text,
            style: TextStyle(
                color: isUser ? Colors.black : Colors.white, fontSize: 15, height: 1.45)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppStyle.cardBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: const Color(0xFF1E2A24)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('👨‍⚕️ ', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            SizedBox(
              width: 40,
              child: Text('...', style: TextStyle(color: AppStyle.textDim, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1310),
        border: Border(top: BorderSide(color: Color(0xFF1E2A24))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              decoration: BoxDecoration(
                color: AppStyle.cardBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF1E2A24)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Apne dil ki baat kaho... 💬',
                  hintStyle: TextStyle(color: AppStyle.textFaint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _isListening ? AppStyle.red : AppStyle.cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isListening ? AppStyle.red : const Color(0xFF1E2A24),
                  width: 2,
                ),
                boxShadow: _isListening
                    ? [BoxShadow(color: AppStyle.red.withOpacity(0.4), blurRadius: 12)]
                    : null,
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? Colors.white : AppStyle.emerald,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppStyle.gradientEmerald,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppStyle.emerald.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
