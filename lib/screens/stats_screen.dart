import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/milestones_screen.dart';
import 'package:quitvape/main.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moneySaved = QuitService.getMoneySaved();
    final days = QuitService.getQuitDuration().inDays;
    final hours = QuitService.getQuitDuration().inHours;
    final puffsAvoided = QuitService.getCigsAvoided() * 10; // ~10 puffs per cig
    final cravingsBeaten = QuitService.getCravingsResisted();

    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(gradient: AppStyle.gradientGold, shape: BoxShape.circle),
                    child: const Center(child: Text('😎', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Champion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Quarter champion', style: TextStyle(color: AppStyle.gold, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Settings navigates to profile (which has all settings)
                      // Since we're in a tab, we can't easily switch tabs from here
                      // For now, show a settings bottom sheet
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppStyle.cardBg,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => _buildSettingsSheet(context),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppStyle.card(),
                      child: const Icon(Icons.settings_rounded, color: AppStyle.textDim, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  Expanded(child: _buildStatCard('🕐', '${days}d ${hours % 24}h', 'Vape-free', AppStyle.emerald)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('💵', '\$${moneySaved.toStringAsFixed(0)}', 'Money saved', AppStyle.gold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('💨', _formatNumber(puffsAvoided), 'Puffs avoided', Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('🔥', '$days', 'Day streak', AppStyle.red)),
                ],
              ),
              const SizedBox(height: 24),

              // Rewards section
              const Text('REWARDS EARNED',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppStyle.textDim, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyle.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildReward('🌱', 'Day one', days >= 1),
                        _buildReward('🍃', 'Finding your\nfeet', days >= 3),
                        _buildReward('🌳', 'One week\nstrong', days >= 7),
                        _buildReward('🛡️', 'Fortnight free', days >= 14),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('EARNED THROUGH ACTION',
                        style: TextStyle(fontSize: 11, color: AppStyle.textFaint, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildReward('📅', 'Consistent', QuitService.getCheckInStreak() >= 3),
                        _buildReward('⭐', 'Committed', QuitService.hasPledgedToday()),
                        _buildReward('🔒', 'Devoted', false),
                        _buildReward('🏅', 'Fighter', cravingsBeaten >= 5),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Health milestones link
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestonesScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppStyle.card(),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppStyle.emerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('❤️', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Health milestones',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('See your full recovery roadmap.',
                                style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppStyle.textFaint, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color accent) {
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
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppStyle.textDim, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReward(String emoji, String label, bool earned) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: earned ? AppStyle.emerald.withOpacity(0.12) : const Color(0xFF1A221E),
              borderRadius: BorderRadius.circular(18),
              border: earned ? Border.all(color: AppStyle.emerald.withOpacity(0.3)) : null,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppStyle.textDim, height: 1.3)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K'.replaceAll('.0K', 'K');
    return '$n';
  }

  Widget _buildSettingsSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _settingsItem(
            context,
            Icons.notifications_rounded,
            'Notifications',
            QuitService.areNotificationsEnabled() ? 'ON' : 'OFF',
            () async {
              final current = QuitService.areNotificationsEnabled();
              await QuitService.setNotificationsEnabled(!current);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(!current ? '🔔 Notifications ON' : '🔕 Notifications OFF')),
              );
            },
          ),
          _settingsItem(
            context,
            Icons.person_rounded,
            'Edit Profile',
            'Name & preferences',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('👤 Go to Profile tab to edit your name')),
              );
            },
          ),
          _settingsItem(
            context,
            Icons.privacy_tip_rounded,
            'Privacy Policy',
            'How we handle data',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📄 Privacy policy: all data stays on your device')),
              );
            },
          ),
          _settingsItem(
            context,
            Icons.info_rounded,
            'About',
            'QuitVape v1.0.0',
            () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _settingsItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A221E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppStyle.emerald, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  Text(subtitle, style: const TextStyle(color: AppStyle.textDim, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppStyle.textFaint, size: 16),
          ],
        ),
      ),
    );
  }
}
