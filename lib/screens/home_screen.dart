import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/milestones_screen.dart';
import 'package:quitvape/screens/craving_screen.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class HomeScreen extends StatefulWidget {
  final bool showPaywallOnStart;
  const HomeScreen({super.key, this.showPaywallOnStart = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Timer _timer;
  Duration _duration = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDuration());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    if (widget.showPaywallOnStart && !QuitService.isPremium()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaywallScreen(showAtStart: true),
              fullscreenDialog: true,
            ),
          );
        }
      });
    }
  }

  void _updateDuration() {
    if (mounted) {
      setState(() {
        _duration = QuitService.getQuitDuration();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moneySaved = QuitService.getMoneySaved();
    final cigsAvoided = QuitService.getCigsAvoided();
    final cravings = QuitService.getCravingsResisted();
    final days = _duration.inDays;

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
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppStyle.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('🚭', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Text('QuitVape', style: AppStyle.headline(context).copyWith(fontSize: 22)),
                  ],
                ),
                actions: [
                  if (!QuitService.isPremium())
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaywallScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppStyle.gradientGold,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppStyle.gold.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Text('⭐', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('PRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Hero timer card
                      _buildHeroCard(days),
                      const SizedBox(height: 20),
                      // Stats grid
                      _buildStatsGrid(moneySaved, cigsAvoided, cravings),
                      const SizedBox(height: 24),
                      // SOS Button
                      _buildSOSButton(),
                      const SizedBox(height: 14),
                      // Milestones button
                      _buildMilestonesButton(),
                      const SizedBox(height: 14),
                      // Motivational quote
                      _buildQuoteCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(int days) {
    final hours = _duration.inHours % 24;
    final minutes = _duration.inMinutes % 60;
    final seconds = _duration.inSeconds % 60;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppStyle.gradientPrimary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppStyle.primary.withOpacity(0.35 + _pulseController.value * 0.1),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppStyle.accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('LIVE TRACKING',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('SMOKE-FREE FOR',
                  style: TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              // Time units
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeUnit('$days', 'DAYS'),
                  _buildTimeSeparator(),
                  _buildTimeUnit('$hours', 'HRS'),
                  _buildTimeSeparator(),
                  _buildTimeUnit('$minutes', 'MIN'),
                  _buildTimeSeparator(),
                  _buildTimeUnit('$seconds', 'SEC'),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  days == 0
                      ? '🎉 Day 1 — You\'ve got this!'
                      : days == 1
                          ? '🔥 1 day strong — Keep going!'
                          : '🏆 $days days of freedom!',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24, left: 4, right: 4),
      child: Text(':', style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsGrid(double moneySaved, int cigsAvoided, int cravings) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('💰', '\$${moneySaved.toStringAsFixed(0)}', 'Saved', AppStyle.gradientSuccess)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('🚫', '$cigsAvoided', 'Avoided', AppStyle.gradientFire)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('💪', '$cravings', 'Cravings Beat', AppStyle.gradientPrimary)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('❤️', '${(_duration.inHours * 11 / 24).round()}', 'Life Hours+', AppStyle.gradientGold)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CravingScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppStyle.gradientFire,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppStyle.warning.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: const Row(
          children: [
            Text('🆘', style: TextStyle(fontSize: 36)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Having a Craving?',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Tap for instant help 🧘',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MilestonesScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppStyle.cardDecoration(context),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppStyle.gradientSuccess,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('🏥', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Milestones',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('See your body healing ❤️',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white54 : Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    final quotes = [
      '"One day at a time. You\'ve already won today." 🌟',
      '"Your future self is thanking you right now." 🙏',
      '"Cravings are temporary. Freedom is forever." 💪',
      '"Every smoke-free breath is a victory." 🫁',
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppStyle.gradientDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text('💬', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
