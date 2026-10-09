import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = QuitService.getUserName();
    _notificationsEnabled = QuitService.areNotificationsEnabled();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = QuitService.getUserName();
    final days = QuitService.getQuitDuration().inDays;
    final moneySaved = QuitService.getMoneySaved();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppStyle.headline(size: 26)),
          const SizedBox(height: 20),

          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: AppStyle.heroCard(),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppStyle.gradientGold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.isEmpty ? '😎' : userName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(userName.isEmpty ? 'Champion' : userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$days days vape-free 🎉', style: const TextStyle(color: AppStyle.emerald, fontSize: 15)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMiniStat('\$${moneySaved.toStringAsFixed(0)}', 'Saved'),
                    Container(width: 1, height: 36, color: const Color(0xFF1E2A24), margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildMiniStat('${QuitService.getCravingsResisted()}', 'Cravings beat'),
                    Container(width: 1, height: 36, color: const Color(0xFF1E2A24), margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildMiniStat('${QuitService.getCheckInStreak()}', 'Day streak'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Edit name
          Text('Your name', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            decoration: AppStyle.card(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: AppStyle.textDim),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: AppStyle.textFaint),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _saveName(),
                  ),
                ),
                TextButton(
                  onPressed: _saveName,
                  child: const Text('Save', style: TextStyle(color: AppStyle.emerald, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notifications toggle
          Container(
            decoration: AppStyle.card(),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppStyle.emerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_rounded, color: AppStyle.emerald, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily motivation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      Text('Get inspired every morning 🌅', style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeColor: AppStyle.emerald,
                  onChanged: (v) async {
                    await QuitService.setNotificationsEnabled(v);
                    setState(() => _notificationsEnabled = v);
                    if (v) {
                      await QuitService.scheduleDailyMotivation();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🔔 Daily motivation ON!'), backgroundColor: Color(0xFF00B87D)),
                        );
                      }
                    } else {
                      await QuitService.cancelNotifications();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Premium
          if (!QuitService.isPremium())
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientGold,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Text('👑', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Go Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          Text('Unlock all features • 50% OFF', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 18),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Reset
          GestureDetector(
            onTap: () => _showResetDialog(),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppStyle.card(),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, color: AppStyle.red),
                  SizedBox(width: 14),
                  Text('Reset journey', style: TextStyle(color: AppStyle.red, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('QuitVape v1.0.0', style: TextStyle(color: AppStyle.textFaint, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppStyle.textDim)),
      ],
    );
  }

  void _saveName() async {
    await QuitService.setUserName(_nameController.text.trim());
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Name saved!'), backgroundColor: Color(0xFF00B87D)),
      );
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppStyle.cardBg,
        title: const Text('Reset journey?', style: TextStyle(color: Colors.white)),
        content: const Text('This will erase all your progress. Are you sure?',
            style: TextStyle(color: AppStyle.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppStyle.textDim)),
          ),
          TextButton(
            onPressed: () async {
              await QuitService.reset();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Journey reset. Fresh start! 💪')),
                );
                setState(() {});
              }
            },
            child: const Text('Reset', style: TextStyle(color: AppStyle.red)),
          ),
        ],
      ),
    );
  }
}
