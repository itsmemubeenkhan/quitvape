import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = QuitService.getMilestones();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = QuitService.isPremium();

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
          child: Column(
            children: [
              // Custom app bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: AppStyle.cardDecoration(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Health Journey', style: AppStyle.headline(context).copyWith(fontSize: 22)),
                  ],
                ),
              ),
              // Progress header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppStyle.gradientSuccess,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppStyle.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🫁', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${milestones.where((m) => m['achieved'] as bool).length}/${milestones.length} Milestones',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: milestones.where((m) => m['achieved'] as bool).length / milestones.length,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Milestones list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: milestones.length,
                  itemBuilder: (context, i) {
                    final m = milestones[i];
                    final achieved = m['achieved'] as bool;
                    // Lock milestones beyond index 5 for free users
                    final isLocked = !isPremium && i > 5;

                    return GestureDetector(
                      onTap: isLocked
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PaywallScreen()),
                              )
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyle.cardDecoration(context).copyWith(
                          border: achieved
                              ? Border.all(color: AppStyle.accent.withOpacity(0.4), width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: achieved
                                    ? AppStyle.gradientSuccess
                                    : isLocked
                                        ? null
                                        : AppStyle.gradientPrimary,
                                color: isLocked ? Colors.grey.shade300 : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  isLocked ? '🔒' : m['icon'] as String,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          m['title'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      if (isLocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: AppStyle.gradientGold,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('PRO',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isLocked ? 'Unlock with Premium to see this milestone' : m['desc'] as String,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (achieved)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  gradient: AppStyle.gradientSuccess,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              )
                            else if (!isLocked)
                              Icon(Icons.lock_open, color: Colors.grey.shade300, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
