import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class CravingGameScreen extends StatefulWidget {
  const CravingGameScreen({super.key});

  @override
  State<CravingGameScreen> createState() => _CravingGameScreenState();
}

class _CravingGameScreenState extends State<CravingGameScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  final List<_Bubble> _bubbles = [];
  int _score = 0;
  int _timeLeft = 60; // 60 second game
  Timer? _gameTimer;
  Timer? _spawnTimer;
  bool _gameOver = false;
  int _combo = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 60;
      _gameOver = false;
      _bubbles.clear();
      _combo = 0;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _endGame();
      }
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_bubbles.length < 8) {
        setState(() {
          _bubbles.add(_Bubble(
            id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
            x: _random.nextDouble(),
            y: _random.nextDouble() * 0.7 + 0.1,
            size: 50 + _random.nextDouble() * 40,
            color: [AppStyle.emerald, AppStyle.gold, Colors.blue, Colors.purple][_random.nextInt(4)],
            emoji: ['💨', '🚭', '💪', '🧠', '❤️'][_random.nextInt(5)],
          ));
        });
      }
    });
  }

  void _popBubble(_Bubble bubble) {
    setState(() {
      _bubbles.removeWhere((b) => b.id == bubble.id);
      _combo++;
      final points = 10 + (_combo ~/ 5) * 5; // Combo bonus
      _score += points;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() => _gameOver = true);

    // Award coins based on score
    final coinsEarned = (_score ~/ 10).clamp(5, 50);
    QuitService.addCoins(coinsEarned);
    QuitService.incrementCravingsResisted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🎮 Pop the Craving!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: _gameOver ? _buildGameOver() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: AppStyle.card(),
                child: Row(
                  children: [
                    const Text('🏆 ', style: TextStyle(fontSize: 18)),
                    Text('$_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10 ? AppStyle.red.withOpacity(0.2) : AppStyle.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _timeLeft <= 10 ? AppStyle.red : const Color(0xFF1E2A24)),
                ),
                child: Row(
                  children: [
                    const Text('⏱️ ', style: TextStyle(fontSize: 18)),
                    Text('$_timeLeft s',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _timeLeft <= 10 ? AppStyle.red : Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_combo >= 5)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppStyle.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('🔥 Combo x${_combo ~/ 5 + 1}!',
                style: const TextStyle(color: AppStyle.gold, fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  const Center(
                    child: Text(
                      'Tap the bubbles!\nPop your craving away! 💨',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppStyle.textFaint, fontSize: 16),
                    ),
                  ),
                  ..._bubbles.map((bubble) => Positioned(
                        left: bubble.x * (constraints.maxWidth - bubble.size),
                        top: bubble.y * (constraints.maxHeight - bubble.size),
                        child: GestureDetector(
                          onTap: () => _popBubble(bubble),
                          child: Container(
                            width: bubble.size,
                            height: bubble.size,
                            decoration: BoxDecoration(
                              color: bubble.color.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(color: bubble.color, width: 2),
                              boxShadow: [
                                BoxShadow(color: bubble.color.withOpacity(0.3), blurRadius: 12),
                              ],
                            ),
                            child: Center(
                              child: Text(bubble.emoji, style: TextStyle(fontSize: bubble.size * 0.4)),
                            ),
                          ),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '💡 Cravings last ~3 minutes. Keep popping!',
            style: TextStyle(color: AppStyle.textDim, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    final coinsEarned = (_score ~/ 10).clamp(5, 50);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text('Craving Beaten!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('You scored $_score points!',
                style: const TextStyle(color: AppStyle.textDim, fontSize: 16)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppStyle.gradientGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text('+$coinsEarned coins!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientEmerald,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Play Again 🎮',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  final int id;
  final double x;
  final double y;
  final double size;
  final Color color;
  final String emoji;

  _Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.emoji,
  });
}
