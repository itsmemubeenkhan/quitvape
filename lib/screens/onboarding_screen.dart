import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/profile_setup_screen.dart';
import 'package:quitvape/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final _cigsController = TextEditingController(text: '20');
  final _costController = TextEditingController(text: '8.0');
  int _currentPage = 0;
  late PageController _pageController;
  late AnimationController _floatController;

  final List<Map<String, String>> _pages = [
    {
      'emoji': '🚭',
      'title': 'Quit vaping\nfor real this time',
      'desc': 'Join thousands who quit for good with science-backed tools',
    },
    {
      'emoji': '💰',
      'title': 'Watch your\nsavings stack up!',
      'desc': 'See exactly how much money you save every single day',
    },
    {
      'emoji': '📊',
      'title': 'Spot your patterns\nBeat them',
      'desc': 'Track cravings, moods & triggers with smart insights',
    },
    {
      'emoji': '🛟',
      'title': 'SOS tools when\ncravings hit',
      'desc': 'Guided breathing, games & grounding — ride out any urge',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _cigsController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: _currentPage < _pages.length ? _buildCarousel() : _buildSetup(),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => setState(() => _currentPage = _pages.length),
            child: const Text('Skip', style: TextStyle(color: AppStyle.textDim, fontSize: 16)),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final page = _pages[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatController.value * 16 - 8),
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppStyle.emerald.withOpacity(0.25), AppStyle.emerald.withOpacity(0.05)],
                              ),
                              border: Border.all(color: AppStyle.emerald.withOpacity(0.3), width: 2),
                              boxShadow: [
                                BoxShadow(color: AppStyle.emerald.withOpacity(0.2), blurRadius: 40, spreadRadius: 5),
                              ],
                            ),
                            child: Center(child: Text(page['emoji']!, style: const TextStyle(fontSize: 76))),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Text(page['title']!, textAlign: TextAlign.center, style: AppStyle.headline(size: 34)),
                    const SizedBox(height: 16),
                    Text(page['desc']!,
                        textAlign: TextAlign.center, style: AppStyle.subtext().copyWith(fontSize: 16)),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == i ? AppStyle.emerald : const Color(0xFF2A3530),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppStyle.gradientEmerald,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppStyle.emerald.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                  } else {
                    setState(() => _currentPage = _pages.length);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(_currentPage < _pages.length - 1 ? 'Next →' : "Let's Begin 🚀",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppStyle.emerald.withOpacity(0.15), AppStyle.emerald.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppStyle.emerald.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 40)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Almost there!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Tell us about your habit', style: TextStyle(color: AppStyle.textDim, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildInputCard(icon: '🚬', label: 'How many per day?', hint: 'Cigarettes or vapes', controller: _cigsController),
          const SizedBox(height: 14),
          _buildInputCard(icon: '💵', label: 'Cost per pack (\$)', hint: 'Average price', controller: _costController),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppStyle.gradientEmerald,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppStyle.emerald.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _startJourney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('I Quit Today! 🎉',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.black)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputCard(
      {required String icon, required String label, required String hint, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.card(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppStyle.emerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                Text(hint, style: const TextStyle(color: AppStyle.textDim, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 88,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A221E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startJourney() async {
    final cigs = int.tryParse(_cigsController.text) ?? 20;
    final cost = double.tryParse(_costController.text) ?? 8.0;
    await QuitService.startQuit(cigsPerDay: cigs, costPerPack: cost);
    if (mounted) {
      // New flow: Profile Setup → Paywall → App
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }
}
