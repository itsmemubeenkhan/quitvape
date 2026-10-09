import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/home_screen.dart';
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
      'title': 'Break Free\nFrom Smoking',
      'desc': 'Join thousands who quit vaping & smoking for good with QuitVape',
    },
    {
      'emoji': '💰',
      'title': 'Watch Your\nSavings Grow',
      'desc': 'See exactly how much money you save every single day',
    },
    {
      'emoji': '❤️',
      'title': 'Heal Your\nBody Daily',
      'desc': 'Track real health milestones as your body recovers',
    },
    {
      'emoji': '🧘',
      'title': 'Crush Every\nCraving',
      'desc': 'Guided breathing exercises when urges hit hardest',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F0D1A), Color(0xFF1A1533)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF8F7FF), Color(0xFFEDE9FE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: _currentPage < _pages.length ? _buildCarousel() : _buildSetup(),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        // Skip button
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => setState(() => _currentPage = _pages.length),
            child: Text('Skip', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating emoji with glow
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatController.value * 16 - 8),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppStyle.gradientPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppStyle.primary.withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(page['emoji']!, style: const TextStyle(fontSize: 80)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page['title']!,
                      textAlign: TextAlign.center,
                      style: AppStyle.headline(context).copyWith(fontSize: 36, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page['desc']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Dots
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
                gradient: _currentPage == i ? AppStyle.gradientPrimary : null,
                color: _currentPage == i ? null : Colors.grey.shade300,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        // Next button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppStyle.gradientPrimary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppStyle.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    setState(() => _currentPage = _pages.length);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next →' : "Let's Begin 🚀",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppStyle.gradientPrimary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppStyle.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: const Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 40)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Almost there!',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Tell us about your habit',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInputCard(
            icon: '🚬',
            label: 'How many per day?',
            hint: 'Cigarettes or vapes',
            controller: _cigsController,
          ),
          const SizedBox(height: 16),
          _buildInputCard(
            icon: '💵',
            label: 'Cost per pack (\$)',
            hint: 'Average price',
            controller: _costController,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppStyle.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppStyle.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We\'ll calculate your savings and health progress from this',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppStyle.gradientSuccess,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppStyle.accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _startJourney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'I Quit Today! 🎉',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppStyle.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2545) : const Color(0xFFF5F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen(showPaywallOnStart: true)),
      );
    }
  }
}
