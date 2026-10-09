import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class CoinShopScreen extends StatefulWidget {
  const CoinShopScreen({super.key});

  @override
  State<CoinShopScreen> createState() => _CoinShopScreenState();
}

class _CoinShopScreenState extends State<CoinShopScreen> {
  @override
  Widget build(BuildContext context) {
    final coins = QuitService.getCoins();
    final items = QuitService.getShopItems();
    final isPremium = QuitService.isPremium();

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Coin Shop 🛍️', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFB800).withOpacity(0.25), const Color(0xFFFF8A00).withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppStyle.gold.withOpacity(0.35), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text('$coins',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Text('Your QuitCoins balance', style: TextStyle(color: AppStyle.textDim, fontSize: 14)),
                  if (!isPremium) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppStyle.gradientEmerald,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text('👑 Go Premium = Earn 2.5x faster!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Redeem coins for premium features:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildShopItem(item)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(Map<String, dynamic> item) {
    final coins = QuitService.getCoins();
    final isUnlocked = QuitService.isItemUnlocked(item['id'] as String);
    final canAfford = coins >= (item['cost'] as int);
    final isPremium = QuitService.isPremium();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppStyle.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? AppStyle.emerald.withOpacity(0.4) : const Color(0xFF1E2A24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (isUnlocked ? AppStyle.emerald : AppStyle.gold).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(item['desc'] as String, style: const TextStyle(color: AppStyle.textDim, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppStyle.emerald.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text('✓ Owned', style: TextStyle(color: AppStyle.emerald, fontWeight: FontWeight.bold, fontSize: 13)),
            )
          else if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppStyle.gradientGold,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text('👑 Free', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            )
          else
            GestureDetector(
              onTap: canAfford ? () => _buyItem(item) : null,
              child: Opacity(
                opacity: canAfford ? 1.0 : 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: canAfford ? AppStyle.gradientGold : null,
                    color: canAfford ? null : const Color(0xFF1E2A24),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text('🪙 ${item['cost']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: canAfford ? Colors.black : AppStyle.textFaint)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _buyItem(Map<String, dynamic> item) async {
    final success = await QuitService.purchaseWithCoins(item['id'] as String, item['cost'] as int);
    if (success) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${item['name']} unlocked!'),
            backgroundColor: const Color(0xFFB87D00),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough coins! Keep your streak going 🪙')),
        );
      }
    }
  }
}
