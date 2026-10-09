import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/stats_screen.dart';
import 'package:quitvape/screens/sos_screen.dart';
import 'package:quitvape/screens/checkin_screen.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/screens/rewards_screen.dart';
import 'package:quitvape/screens/profile_screen.dart';
import 'package:quitvape/main.dart';

class HomeScreen extends StatefulWidget {
  final bool showPaywallOnStart;
  const HomeScreen({super.key, this.showPaywallOnStart = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showPaywallOnStart && !QuitService.isPremium()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: const [
            HomeTab(),
            StatsScreen(),
            RewardsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1310),
        border: Border(top: BorderSide(color: Color(0xFF1E2A24))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.bar_chart_rounded, 'Stats'),
              _buildSOSNavButton(),
              _buildNavItem(2, Icons.emoji_events_rounded, 'Rewards'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppStyle.emerald : AppStyle.textFaint, size: 26),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isActive ? AppStyle.emerald : AppStyle.textFaint,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSNavButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSScreen())),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppStyle.gradientEmerald,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppStyle.emerald.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Icon(Icons.support_rounded, color: Colors.black, size: 28),
      ),
    );
  }
}

// Home tab content (separate widget to keep timer alive)
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) {
        final duration = QuitService.getQuitDuration();
        final days = duration.inDays;
        final hours = duration.inHours % 24;
        final minutes = duration.inMinutes % 60;
        final seconds = duration.inSeconds % 60;
        final checkInStreak = QuitService.getCheckInStreak();
        final hasCheckedInToday = QuitService.hasCheckedInToday();
        final hasPledgedToday = QuitService.hasPledgedToday();
        final userName = QuitService.getUserName();

        String championTitle = 'GETTING STARTED';
        if (days >= 90) {
          championTitle = 'QUARTER CHAMPION';
        } else if (days >= 30) {
          championTitle = 'MONTH WARRIOR';
        } else if (days >= 14) {
          championTitle = 'FORTNIGHT FIGHTER';
        } else if (days >= 7) {
          championTitle = 'WEEK WINNER';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Go to profile tab - handled by parent
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppStyle.gradientGold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          userName.isEmpty ? '🔥' : userName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName.isEmpty ? 'Champion' : userName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Keep going strong! 💪', style: TextStyle(color: AppStyle.textDim, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  if (!QuitService.isPremium())
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppStyle.gradientGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text('👑', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text('GO PRO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppStyle.heroCard(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppStyle.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text('🏆', style: TextStyle(fontSize: 30))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppStyle.gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(championTitle,
                                    style: const TextStyle(
                                        color: AppStyle.gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                              ),
                              const SizedBox(height: 6),
                              Text('$days days free',
                                  style: const TextStyle(
                                      fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildWeeklyDots(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(
                          days >= 180
                              ? 'You are a Half-year hero!'
                              : '${180 - days} days to Half-year hero',
                          style: const TextStyle(color: AppStyle.textDim, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Timer row
              Row(
                children: [
                  Expanded(child: _buildTimeBox('$days', 'DAYS')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeBox(hours.toString().padLeft(2, '0'), 'HRS')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeBox(minutes.toString().padLeft(2, '0'), 'MIN')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeBox(seconds.toString().padLeft(2, '0'), 'SEC')),
                ],
              ),
              const SizedBox(height: 16),

              // SOS Button
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: AppStyle.gradientRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppStyle.red.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🛟', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text('SOS — I\'m craving',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Check-in card
              GestureDetector(
                onTap: hasCheckedInToday
                    ? null
                    : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen()))
                        .then((_) => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                        child: Icon(
                          hasCheckedInToday ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
                          color: AppStyle.emerald,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasCheckedInToday ? 'Checked in today' : 'Daily check-in',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(
                              hasCheckedInToday
                                  ? '$checkInStreak-day check-in streak 🔥'
                                  : 'How are you feeling today?',
                              style: const TextStyle(color: AppStyle.textDim, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (hasCheckedInToday)
                        const Icon(Icons.check_circle, color: AppStyle.emerald, size: 28),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Daily pledge card
              Container(
                padding: const EdgeInsets.all(20),
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
                      child: const Center(child: Text('🤝', style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily pledge',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Commit to staying vape-free today.',
                              style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (!hasPledgedToday) {
                          await QuitService.makePledge();
                          setState(() {});
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🤝 Pledge made! You\'ve got this!'),
                                backgroundColor: Color(0xFF00B87D),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: hasPledgedToday ? null : AppStyle.gradientEmerald,
                          color: hasPledgedToday ? const Color(0xFF1E2A24) : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          hasPledgedToday ? '✓ Pledged' : 'I pledge',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: hasPledgedToday ? AppStyle.emerald : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyDots() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final quitDate = QuitService.getStartDate();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = startOfWeek.add(Duration(days: i));
        final isActive = !day.isAfter(now) && !day.isBefore(DateTime(quitDate.year, quitDate.month, quitDate.day));
        final isToday = day.day == now.day && day.month == now.month;
        const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppStyle.emerald.withOpacity(0.15) : const Color(0xFF1A221E),
                borderRadius: BorderRadius.circular(12),
                border: isToday ? Border.all(color: AppStyle.emerald, width: 1.5) : null,
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppStyle.emerald : const Color(0xFF2A3530),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(dayLabels[i],
                style: TextStyle(
                    fontSize: 11,
                    color: isToday ? AppStyle.emerald : AppStyle.textFaint,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
          ],
        );
      }),
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppStyle.card(),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppStyle.textDim, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
