import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/screens/home_screen.dart';
import 'package:quitvape/main.dart';

/// Clean multi-step onboarding:
/// welcome → why quit → profile → quit date → daily use → spend →
/// triggers → motivation → education → projection → reminders →
/// paywall → notifications → home.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  static const int _totalSteps = 12;

  // Step 1: reasons
  final Set<String> _reasons = {};
  // Step 2: profile
  final TextEditingController _nameController = TextEditingController();
  int _age = 25;
  // Step 3: quit date
  DateTime _quitDate = DateTime.now();
  // Step 4: daily use
  double _unitsPerDay = 1;
  String _unit = 'Pods';
  // Step 5: spend
  final TextEditingController _spendController =
      TextEditingController(text: '60');
  String _currency = '\$';
  // Step 6: triggers
  final Set<String> _triggers = {};
  // Step 10: reminders
  final Map<String, TimeOfDay> _reminderTimes = {};
  final Map<String, bool> _reminderEnabled = {};

  final List<String> _currencies = const ['\$', '€', '£', '₹', 'Rs', '₺'];
  final List<String> _units = const ['Pods', 'Puffs', 'mL'];

  static const List<Map<String, dynamic>> _reasonOptions = [
    {'label': 'Save money', 'icon': Icons.savings_outlined},
    {'label': 'Breathe easier', 'icon': Icons.air_outlined},
    {'label': 'Better health', 'icon': Icons.favorite_outline},
    {'label': 'Family', 'icon': Icons.family_restroom_outlined},
    {'label': 'Look better', 'icon': Icons.face_outlined},
    {'label': 'More energy', 'icon': Icons.bolt_outlined},
  ];

  static const List<Map<String, dynamic>> _triggerOptions = [
    {'label': 'Stress', 'icon': Icons.psychology_outlined},
    {'label': 'Boredom', 'icon': Icons.hourglass_empty_outlined},
    {'label': 'After meals', 'icon': Icons.restaurant_outlined},
    {'label': 'Social situations', 'icon': Icons.groups_outlined},
    {'label': 'Driving', 'icon': Icons.drive_eta_outlined},
    {'label': 'Coffee', 'icon': Icons.coffee_outlined},
    {'label': 'Alcohol', 'icon': Icons.wine_bar_outlined},
    {'label': 'Waking up', 'icon': Icons.wb_sunny_outlined},
  ];

  @override
  void initState() {
    super.initState();
    for (final r in QuitService.reminderTypes) {
      final saved = QuitService.getReminder(r['id']!);
      final parts = (saved['time'] as String).split(':');
      _reminderTimes[r['id']!] = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 7,
        minute: int.tryParse(parts[1]) ?? 0,
      );
      _reminderEnabled[r['id']!] = saved['enabled'] as bool;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _spendController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _monthlySpend =>
      double.tryParse(_spendController.text.trim()) ?? 0;

  Future<void> _openPaywall() async {
    await _saveProfile();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaywallScreen(isOnboarding: true),
        fullscreenDialog: true,
      ),
    );
    // After paywall closes (subscribed or skipped), go to notifications step
    if (mounted) {
      _pageController.animateToPage(
        _totalSteps - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await QuitService.setUserName(name);
    await QuitService.setUserAge(_age);
    await QuitService.setQuitReasons(_reasons.toList());
    await QuitService.setTriggers(_triggers.toList());
    await QuitService.setVapeProfile(
      unitsPerDay: _unitsPerDay,
      monthlySpend: _monthlySpend,
      currency: _currency,
      quitDate: _quitDate,
    );
    for (final r in QuitService.reminderTypes) {
      final id = r['id']!;
      final t = _reminderTimes[id]!;
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      await QuitService.setReminder(id, '$hh:$mm', _reminderEnabled[id]!);
    }
  }

  Future<void> _finish() async {
    await _saveProfile();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _enableNotifications() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      final android =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await QuitService.setNotificationsEnabled(true);
    } catch (_) {
      // best effort
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step > 0 && _step < _totalSteps - 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppStyle.ink),
                onPressed: _back,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _buildWelcome(),
                  _buildWhyQuit(),
                  _buildProfile(),
                  _buildQuitDate(),
                  _buildDailyUse(),
                  _buildSpend(),
                  _buildTriggers(),
                  _buildMotivation(),
                  _buildEducation(),
                  _buildProjection(),
                  _buildReminders(),
                  _buildNotifications(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_step + 1) / _totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: AppStyle.line,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppStyle.primary),
        ),
      ),
    );
  }

  // ---------- Step 0: Welcome ----------
  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(18),
            child: Image.asset('assets/logo.png'),
          ),
          const SizedBox(height: 40),
          Text('Quit vaping\nfor good',
              textAlign: TextAlign.center,
              style: AppStyle.headline(size: 36)),
          const SizedBox(height: 16),
          Text(
            'Track your progress, beat cravings,\nand watch your health and savings grow.',
            textAlign: TextAlign.center,
            style: AppStyle.subtext().copyWith(fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: AppStyle.primaryButton(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get started'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Step 1: Why quit ----------
  Widget _buildWhyQuit() {
    return _stepScaffold(
      icon: Icons.flag_outlined,
      title: 'Why do you want\nto quit vaping?',
      subtitle: "Pick what matters to you. We'll remind you when it's tough.",
      child: Column(
        children: _reasonOptions
            .map((r) => _selectCard(
                  label: r['label'] as String,
                  icon: r['icon'] as IconData,
                  selected: _reasons.contains(r['label']),
                  onTap: () => setState(() {
                    final l = r['label'] as String;
                    if (_reasons.contains(l)) {
                      _reasons.remove(l);
                    } else {
                      _reasons.add(l);
                    }
                  }),
                ))
            .toList(),
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 2: Profile ----------
  Widget _buildProfile() {
    return _stepScaffold(
      icon: Icons.person_outline,
      title: "Let's get to\nknow you",
      subtitle: 'Your progress is personal. This stays on your device.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What should we call you?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppStyle.ink)),
          const SizedBox(height: 10),
          Container(
            decoration: AppStyle.card(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: AppStyle.ink, fontSize: 17),
              decoration: const InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(color: AppStyle.textFaint),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('How old are you?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppStyle.ink)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: AppStyle.card(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stepperButton(Icons.remove, () {
                  setState(() => _age = (_age - 1).clamp(13, 100));
                }),
                Text('$_age',
                    style: AppStyle.headline(size: 44)),
                _stepperButton(Icons.add, () {
                  setState(() => _age = (_age + 1).clamp(13, 100));
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.lock_outline,
                  size: 15, color: AppStyle.textFaint),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your privacy matters. We never share your personal information.',
                  style: TextStyle(
                      color: AppStyle.textFaint, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 3: Quit date ----------
  Widget _buildQuitDate() {
    return _stepScaffold(
      icon: Icons.calendar_month_outlined,
      title: 'When did you\nquit vaping?',
      subtitle: "If you haven't quit yet, pick when you plan to.",
      child: Column(
        children: [
          _dateTimeCard(
            label: 'Date',
            value: _formatDate(_quitDate),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _quitDate,
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _quitDate = DateTime(
                    picked.year, picked.month, picked.day,
                    _quitDate.hour, _quitDate.minute,
                  );
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _dateTimeCard(
            label: 'Time',
            value: _formatTime(_quitDate),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_quitDate),
              );
              if (picked != null) {
                setState(() {
                  _quitDate = DateTime(
                    _quitDate.year, _quitDate.month, _quitDate.day,
                    picked.hour, picked.minute,
                  );
                });
              }
            },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _quitDate = DateTime.now()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppStyle.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_outlined,
                      size: 16, color: AppStyle.primary),
                  SizedBox(width: 8),
                  Text('Use current date & time',
                      style: TextStyle(
                          color: AppStyle.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 4: Daily use ----------
  Widget _buildDailyUse() {
    return _stepScaffold(
      icon: Icons.show_chart_outlined,
      title: 'How much did you\nvape per day?',
      subtitle: 'This helps us calculate your savings.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: AppStyle.card(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stepperButton(Icons.remove, () {
                  setState(() {
                    _unitsPerDay = (_unitsPerDay - (_unit == 'mL' ? 1 : 0.5))
                        .clamp(0.5, 999);
                  });
                }),
                Column(
                  children: [
                    Text(
                      _unitsPerDay % 1 == 0
                          ? _unitsPerDay.toInt().toString()
                          : _unitsPerDay.toStringAsFixed(1),
                      style: AppStyle.headline(size: 52),
                    ),
                    Text(_unit.toLowerCase(),
                        style: AppStyle.subtext()
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                _stepperButton(Icons.add, () {
                  setState(() {
                    _unitsPerDay = (_unitsPerDay + (_unit == 'mL' ? 1 : 0.5))
                        .clamp(0.5, 999);
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: _units.map((u) => _chip(u, _unit == u, () {
              setState(() {
                _unit = u;
                if (u == 'Puffs' && _unitsPerDay < 10) _unitsPerDay = 200;
                if (u != 'Puffs' && _unitsPerDay > 50) _unitsPerDay = 2;
              });
            })).toList(),
          ),
        ],
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 5: Monthly spend ----------
  Widget _buildSpend() {
    return _stepScaffold(
      icon: Icons.account_balance_wallet_outlined,
      title: "What was your\nmonthly vape spend?",
      subtitle: 'Include devices, pods, and e-liquid.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppStyle.card(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: TextBaseline.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_currency,
                    style: AppStyle.headline(size: 40)
                        .copyWith(color: AppStyle.textFaint)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _spendController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.center,
                    style: AppStyle.headline(size: 48),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _currencies
                .map((c) => _chip(c, _currency == c, () {
                      setState(() => _currency = c);
                    }))
                .toList(),
          ),
        ],
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 6: Triggers ----------
  Widget _buildTriggers() {
    return _stepScaffold(
      icon: Icons.warning_amber_outlined,
      title: 'What triggers\nyour cravings?',
      subtitle: 'Knowing your patterns helps us suggest the right tools.',
      child: Column(
        children: _triggerOptions
            .map((t) => _selectCard(
                  label: t['label'] as String,
                  icon: t['icon'] as IconData,
                  selected: _triggers.contains(t['label']),
                  onTap: () => setState(() {
                    final l = t['label'] as String;
                    if (_triggers.contains(l)) {
                      _triggers.remove(l);
                    } else {
                      _triggers.add(l);
                    }
                  }),
                ))
            .toList(),
      ),
      buttonLabel: 'Next',
      onNext: _next,
    );
  }

  // ---------- Step 7: Motivational interstitial ----------
  Widget _buildMotivation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppStyle.goldSoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.emoji_events_outlined,
                size: 52, color: AppStyle.gold),
          ),
          const SizedBox(height: 36),
          Text('Recovery starts\nwith day one',
              textAlign: TextAlign.center,
              style: AppStyle.headline(size: 32)),
          const SizedBox(height: 16),
          Text(
            'Thousands of people with the same habit reach their 30-day milestone every month. Can you see yourself reaching it too?',
            textAlign: TextAlign.center,
            style: AppStyle.subtext().copyWith(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: AppStyle.primaryButton(),
              child: const Text('Yes, I can do it!'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _next,
            child: const Text('Not sure yet',
                style: TextStyle(color: AppStyle.textDim, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ---------- Step 8: Educational interstitial ----------
  Widget _buildEducation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.science_outlined,
                size: 52, color: AppStyle.primary),
          ),
          const SizedBox(height: 36),
          Text('Your brain\ncan rewire itself',
              textAlign: TextAlign.center,
              style: AppStyle.headline(size: 32)),
          const SizedBox(height: 16),
          Text(
            'Research shows that after just weeks without nicotine, reward pathways begin to reset. Heart rate steadies within hours, breathing improves within days, and lung function climbs within weeks.',
            textAlign: TextAlign.center,
            style: AppStyle.subtext().copyWith(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: AppStyle.primaryButton(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Step 9: Projection ----------
  Widget _buildProjection() {
    final saved = _monthlySpend;
    final units = (_unitsPerDay * 30).round();
    return _stepScaffold(
      icon: Icons.emoji_events_outlined,
      title: 'Your first month\nvape-free',
      subtitle: "Here's what you're working toward.",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.savings_outlined,
                  QuitService.formatMoney(saved),
                  'money saved',
                  AppStyle.primarySoft,
                  AppStyle.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.block_outlined,
                  '$units',
                  '$_unit avoided',
                  AppStyle.goldSoft,
                  AppStyle.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.card(),
            child: const Row(
              children: [
                Icon(Icons.favorite_outline,
                    color: AppStyle.red, size: 26),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Within weeks, your breathing, taste, and energy start to recover.',
                    style: TextStyle(
                        color: AppStyle.textDim, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      buttonLabel: 'Continue',
      onNext: _next,
    );
  }

  // ---------- Step 10: Reminders ----------
  Widget _buildReminders() {
    return _stepScaffold(
      icon: Icons.notifications_outlined,
      title: 'Set your daily\nreminders',
      subtitle: 'Gentle nudges keep your streak alive.',
      child: Column(
        children: QuitService.reminderTypes.map((r) {
          final id = r['id']!;
          final t = _reminderTimes[id]!;
          final enabled = _reminderEnabled[id]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: AppStyle.card(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['label']!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppStyle.ink)),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: t,
                          );
                          if (picked != null) {
                            setState(
                                () => _reminderTimes[id] = picked);
                          }
                        },
                        child: Text(
                          t.format(context),
                          style: const TextStyle(
                              fontSize: 15,
                              color: AppStyle.primary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: enabled,
                  activeColor: AppStyle.primary,
                  onChanged: (v) =>
                      setState(() => _reminderEnabled[id] = v),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      buttonLabel: 'Continue',
      onNext: _openPaywall,
    );
  }

  // ---------- Step 11: Notifications ----------
  Widget _buildNotifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.notifications_outlined,
                size: 52, color: AppStyle.primary),
          ),
          const SizedBox(height: 36),
          Text('Stay on track',
              textAlign: TextAlign.center,
              style: AppStyle.headline(size: 32)),
          const SizedBox(height: 12),
          Text(
            'Daily motivation and milestone reminders\nkeep your quit streak alive.',
            textAlign: TextAlign.center,
            style: AppStyle.subtext().copyWith(fontSize: 15),
          ),
          const SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enableNotifications,
              style: AppStyle.primaryButton(),
              child: const Text('Enable reminders'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _finish,
            child: const Text('Maybe later',
                style: TextStyle(color: AppStyle.textDim, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ---------- Shared builders ----------
  Widget _selectCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppStyle.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppStyle.primary : AppStyle.line,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E1B14).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppStyle.primary.withOpacity(0.15)
                    : AppStyle.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected
                      ? AppStyle.primary
                      : AppStyle.textDim,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: AppStyle.ink)),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppStyle.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppStyle.primary : AppStyle.line,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepScaffold({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    required String buttonLabel,
    required VoidCallback onNext,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 30, color: AppStyle.primary),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppStyle.headline(size: 32)),
          const SizedBox(height: 10),
          Text(subtitle, style: AppStyle.subtext().copyWith(fontSize: 15)),
          const SizedBox(height: 28),
          child,
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: AppStyle.primaryButton(),
              child: Text(buttonLabel),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _dateTimeCard({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: AppStyle.card(),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppStyle.textDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: AppStyle.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined,
                size: 18, color: AppStyle.textFaint),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppStyle.bg,
          shape: BoxShape.circle,
          border: Border.all(color: AppStyle.line),
        ),
        child: Icon(icon, color: AppStyle.ink, size: 24),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppStyle.ink : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? AppStyle.ink : AppStyle.line, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppStyle.textDim,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color bg,
      Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: AppStyle.headline(size: 26),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label, style: AppStyle.subtext()),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}
