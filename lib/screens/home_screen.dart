import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/stats_screen.dart';
import 'package:quitvape/screens/sos_screen.dart';
import 'package:quitvape/screens/checkin_screen.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/screens/learn_screen.dart';
import 'package:quitvape/screens/profile_screen.dart';
import 'package:quitvape/screens/milestones_screen.dart';
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
            MaterialPageRoute(
                builder: (_) => const PaywallScreen(), fullscreenDialog: true),
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
          children: [
            HomeTab(onGoProfile: () => setState(() => _currentTab = 3)),
            const LearnScreen(),
            const StatsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppStyle.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.school_outlined, Icons.school, 'Learn'),
              _buildSOSNavButton(),
              _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'Stats'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? AppStyle.primary : AppStyle.textFaint,
                size: 26),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isActive ? AppStyle.primary : AppStyle.textFaint,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSNavButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SOSScreen())),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppStyle.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppStyle.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child:
            const Icon(Icons.support_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}

// ---------------- Home tab ----------------

class HomeTab extends StatefulWidget {
  final VoidCallback? onGoProfile;
  const HomeTab({super.key, this.onGoProfile});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin {
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
        final userName = QuitService.getUserName();
        final greeting = _greeting();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userName, greeting),
              const SizedBox(height: 20),
              _buildTimerCard(days, hours, minutes, seconds),
              const SizedBox(height: 16),
              _buildProgressCard(),
              const SizedBox(height: 16),
              _buildMilestoneCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Achievements'),
              const SizedBox(height: 12),
              _buildAchievements(),
              const SizedBox(height: 24),
              _buildSectionTitle('Health improvements'),
              const SizedBox(height: 12),
              _buildHealthTimeline(),
              const SizedBox(height: 24),
              _buildSectionTitle('Today'),
              const SizedBox(height: 12),
              _buildCheckInCard(),
              const SizedBox(height: 12),
              _buildPledgeCard(),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildMilestoneCard() {
    final milestones = QuitService.getMilestones();
    final hours = QuitService.getQuitDuration().inHours;
    Map<String, dynamic>? next;
    for (final m in milestones) {
      if (hours < (m['hours'] as int)) {
        next = m;
        break;
      }
    }
    next ??= milestones.last;
    final targetHours = next['hours'] as int;
    final progress = targetHours == 0
        ? 1.0
        : (hours / targetHours).clamp(0.0, 1.0);
    final remaining = targetHours - hours;
    final remainingLabel = remaining <= 0
        ? 'Reached!'
        : remaining < 24
            ? '$remaining hrs to go'
            : '${(remaining / 24).floor()} days to go';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 18, color: AppStyle.textDim),
              const SizedBox(width: 8),
              const Text('Next milestone',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppStyle.textDim)),
              const Spacer(),
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppStyle.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(next['title'] as String,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppStyle.ink)),
          const SizedBox(height: 4),
          Text(next['desc'] as String,
              style: const TextStyle(
                  fontSize: 14, color: AppStyle.textDim)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppStyle.line,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppStyle.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(remainingLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppStyle.textDim,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MilestonesScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View all',
                    style: TextStyle(
                        color: AppStyle.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppStyle.headline(size: 20));
  }

  Widget _buildHeader(String userName, String greeting) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onGoProfile,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppStyle.line),
            ),
            child: Center(
              child: Text(
                userName.isEmpty
                    ? greeting[0]
                    : userName[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: const TextStyle(
                    fontSize: 13, color: AppStyle.textDim)),
            Text(userName.isEmpty ? 'Welcome back' : userName,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.ink)),
          ],
        ),
        const Spacer(),
        if (!QuitService.isPremium())
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PaywallScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppStyle.ink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star_outline,
                      size: 15, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Go Premium',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimerCard(int days, int hours, int minutes, int seconds) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: AppStyle.heroCard(),
      child: Column(
        children: [
          const Text('VAPE-FREE FOR',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppStyle.textDim)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeUnit('$days', 'days'),
              _timeSep(),
              _timeUnit(hours.toString().padLeft(2, '0'), 'hrs'),
              _timeSep(),
              _timeUnit(minutes.toString().padLeft(2, '0'), 'min'),
              _timeSep(),
              _timeUnit(seconds.toString().padLeft(2, '0'), 'sec'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeUnit(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppStyle.ink,
                letterSpacing: -1,
                fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppStyle.textDim,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _timeSep() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(':',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppStyle.textFaint)),
    );
  }

  Widget _buildProgressCard() {
    final saved = QuitService.getMoneySaved();
    final units = QuitService.getUnitsAvoided();
    final cravings = QuitService.getCravingsResisted();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overall progress',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppStyle.ink)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _progressStat(Icons.savings_outlined,
                      QuitService.formatMoney(saved), 'saved')),
              Expanded(
                  child: _progressStat(Icons.block_outlined,
                      '$units', 'units avoided')),
              Expanded(
                  child: _progressStat(Icons.shield_outlined,
                      '$cravings', 'cravings\nresisted')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppStyle.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppStyle.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppStyle.ink)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 12, color: AppStyle.textDim)),
      ],
    );
  }

  Widget _buildAchievements() {
    final milestones = QuitService.getMilestones();
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: milestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final m = milestones[i];
          final achieved = m['achieved'] as bool;
          final next = !achieved &&
              (i == 0 || (milestones[i - 1]['achieved'] as bool));
          return Container(
            width: 132,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: achieved ? AppStyle.primarySoft : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: next ? AppStyle.primary : AppStyle.line,
                width: next ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (next)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppStyle.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('NEXT',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    const Spacer(),
                    Icon(
                      achieved
                          ? Icons.check_circle
                          : Icons.lock_outline,
                      size: 18,
                      color: achieved
                          ? AppStyle.primary
                          : AppStyle.textFaint,
                    ),
                  ],
                ),
                const Spacer(),
                Icon(_milestoneIcon(i),
                    size: 26,
                    color: achieved
                        ? AppStyle.primary
                        : AppStyle.textFaint),
                const SizedBox(height: 8),
                Text(m['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppStyle.ink)),
                Text(m['desc'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppStyle.textDim)),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _milestoneIcon(int i) {
    const icons = [
      Icons.flag_outlined,
      Icons.favorite_outline,
      Icons.air_outlined,
      Icons.wb_sunny_outlined,
      Icons.spa_outlined,
      Icons.bolt_outlined,
      Icons.fitness_center_outlined,
      Icons.bloodtype_outlined,
      Icons.self_improvement_outlined,
      Icons.pregnant_woman_outlined,
      Icons.eco_outlined,
      Icons.emoji_events_outlined,
    ];
    return icons[i % icons.length];
  }

  Widget _buildHealthTimeline() {
    final milestones = QuitService.getMilestones().skip(1).toList();
    final hours = QuitService.getQuitDuration().inHours;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.card(),
      child: Column(
        children: List.generate(milestones.length, (i) {
          final m = milestones[i];
          final achieved = m['achieved'] as bool;
          final isLast = i == milestones.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: achieved
                            ? AppStyle.primarySoft
                            : AppStyle.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achieved
                            ? Icons.check
                            : _milestoneIcon(i + 1),
                        size: 17,
                        color: achieved
                            ? AppStyle.primary
                            : AppStyle.textFaint,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin:
                              const EdgeInsets.symmetric(vertical: 4),
                          color: AppStyle.line,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['title'] as String,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: achieved
                                    ? AppStyle.ink
                                    : AppStyle.textFaint)),
                        const SizedBox(height: 2),
                        Text(m['desc'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                color: achieved
                                    ? AppStyle.textDim
                                    : AppStyle.textFaint)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCheckInCard() {
    final hasCheckedIn = QuitService.hasCheckedInToday();
    final streak = QuitService.getCheckInStreak();
    return GestureDetector(
      onTap: hasCheckedIn
          ? null
          : () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const CheckInScreen()))
                  .then((_) => setState(() {})),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppStyle.card(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppStyle.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasCheckedIn
                    ? Icons.check_circle
                    : Icons.calendar_today_outlined,
                color: AppStyle.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      hasCheckedIn
                          ? 'Checked in today'
                          : 'Daily check-in',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppStyle.ink)),
                  Text(
                    hasCheckedIn
                        ? '$streak-day streak — nice work'
                        : 'How are you feeling today?',
                    style: const TextStyle(
                        color: AppStyle.textDim, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppStyle.textFaint),
          ],
        ),
      ),
    );
  }

  Widget _buildPledgeCard() {
    final pledged = QuitService.hasPledgedToday();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.card(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppStyle.goldSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.handshake_outlined,
                color: AppStyle.gold, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily pledge',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppStyle.ink)),
                Text('Commit to staying vape-free today.',
                    style: TextStyle(
                        color: AppStyle.textDim, fontSize: 13)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (!pledged) {
                await QuitService.makePledge();
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Pledge made. You\'ve got this.')),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: pledged
                    ? AppStyle.primarySoft
                    : AppStyle.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pledged ? 'Pledged' : 'I pledge',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: pledged
                      ? AppStyle.primary
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
