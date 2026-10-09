import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = QuitService.getQuitDuration().inDays;
    final cravingsBeaten = QuitService.getCravingsResisted();
    final checkInStreak = QuitService.getCheckInStreak();

    final rewards = [
      {'emoji': '🌱', 'name': 'Day One', 'desc': 'Started your journey', 'earned': days >= 1},
      {'emoji': '🍃', 'name': 'Finding Feet', 'desc': '3 days strong', 'earned': days >= 3},
      {'emoji': '🌳', 'name': 'One Week', 'desc': '7 days free', 'earned': days >= 7},
      {'emoji': '🛡️', 'name': 'Fortnight', 'desc': '14 days free', 'earned': days >= 14},
      {'emoji': '🏅', 'name': 'Month Warrior', 'desc': '30 days free', 'earned': days >= 30},
      {'emoji': '🏆', 'name': 'Quarter Champ', 'desc': '90 days free', 'earned': days >= 90},
      {'emoji': '💪', 'name': 'Fighter', 'desc': 'Beat 5 cravings', 'earned': cravingsBeaten >= 5},
      {'emoji': '🔥', 'name': 'On Fire', 'desc': 'Beat 20 cravings', 'earned': cravingsBeaten >= 20},
      {'emoji': '📅', 'name': 'Consistent', 'desc': '3-day check-in streak', 'earned': checkInStreak >= 3},
      {'emoji': '⭐', 'name': 'Dedicated', 'desc': '7-day check-in streak', 'earned': checkInStreak >= 7},
      {'emoji': '💎', 'name': 'Diamond', 'desc': '180 days free', 'earned': days >= 180},
      {'emoji': '👑', 'name': 'Legend', 'desc': '365 days free', 'earned': days >= 365},
    ];

    final earnedCount = rewards.where((r) => r['earned'] as bool).length;
    final coins = QuitService.getCoins();
    final canClaim = QuitService.canClaimDailyCoins();
    final isPremium = QuitService.isPremium();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rewards', style: AppStyle.headline(size: 26)),
          const SizedBox(height: 4),
          Text('$earnedCount of ${rewards.length} unlocked', style: AppStyle.subtext()),
          const SizedBox(height: 16),

          // Quit & Earn coins card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFB800).withOpacity(0.2), const Color(0xFFFF8A00).withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppStyle.gold.withOpacity(0.35), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$coins',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                        const Text('QuitCoins earned', style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('≈ \$${QuitService.getCoinsValue().toStringAsFixed(2)} in rewards value',
                    style: const TextStyle(color: AppStyle.gold, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (canClaim)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppStyle.gradientGold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppStyle.gold.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final earned = await QuitService.claimDailyCoins();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 +$earned QuitCoins claimed! Keep going!'),
                                backgroundColor: const Color(0xFFB87D00),
                              ),
                            );
                            (context as Element).markNeedsBuild();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Claim Daily Reward: +${QuitService.getDailyCoinReward()} 🪙',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black)),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('✅ Claimed today! Come back tomorrow 🌅',
                          style: TextStyle(color: AppStyle.textDim, fontSize: 14)),
                    ),
                  ),
                if (!isPremium) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppStyle.emerald.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppStyle.emerald.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Text('👑', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Premium members earn 2.5x coins (25/day)!',
                              style: TextStyle(color: AppStyle.emerald, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppStyle.gold.withOpacity(0.15), AppStyle.gold.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppStyle.gold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$earnedCount Rewards Earned',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: earnedCount / rewards.length,
                          backgroundColor: const Color(0xFF1E2A24),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppStyle.gold),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: rewards.length,
            itemBuilder: (context, i) {
              final r = rewards[i];
              final earned = r['earned'] as bool;
              return Opacity(
                opacity: earned ? 1.0 : 0.4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyle.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: earned ? AppStyle.gold.withOpacity(0.4) : const Color(0xFF1E2A24),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(r['emoji'] as String, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(r['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(r['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: AppStyle.textDim)),
                      if (!earned) const SizedBox(height: 4),
                      if (!earned) const Text('🔒', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
