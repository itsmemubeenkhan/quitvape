import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = QuitService.getMilestones();
    final isPremium = QuitService.isPremium();
    final achievedCount = milestones.where((m) => m['achieved'] as bool).length;

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Health Milestones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppStyle.emerald.withOpacity(0.2), AppStyle.emerald.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppStyle.emerald.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Text('🫁', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$achievedCount/${milestones.length} Milestones',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: achievedCount / milestones.length,
                            backgroundColor: const Color(0xFF1E2A24),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppStyle.emerald),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...milestones.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              final achieved = m['achieved'] as bool;
              final isLocked = !isPremium && i > 5;

              return GestureDetector(
                onTap: isLocked
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()))
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppStyle.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: achieved ? AppStyle.emerald.withOpacity(0.3) : const Color(0xFF1E2A24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: achieved
                              ? AppStyle.emerald.withOpacity(0.15)
                              : isLocked
                                  ? const Color(0xFF1A221E)
                                  : AppStyle.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(isLocked ? '🔒' : m['icon'] as String,
                              style: const TextStyle(fontSize: 28)),
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
                                  child: Text(m['title'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                ),
                                if (isLocked)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        gradient: AppStyle.gradientGold,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: const Text('PRO',
                                        style: TextStyle(
                                            fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLocked ? 'Unlock with Premium 👑' : m['desc'] as String,
                              style: const TextStyle(color: AppStyle.textDim, fontSize: 13),
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
                            gradient: AppStyle.gradientEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
