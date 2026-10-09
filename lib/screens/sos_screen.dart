import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/craving_screen.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cravingsBeaten = QuitService.getCravingsResisted();

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Craving SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A craving peaks in about 3 minutes. Pick a tool and ride it out — you\'ll come out the other side.',
              style: AppStyle.subtext(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppStyle.emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppStyle.emerald.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('$cravingsBeaten cravings beaten',
                      style: const TextStyle(color: AppStyle.emerald, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTool(
              context,
              icon: '🌬️',
              title: 'Guided breathing',
              desc: '4-4-4-4 box breathing to settle',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CravingScreen())),
            ),
            _buildTool(
              context,
              icon: '⏳',
              title: 'Craving timer',
              desc: 'Ride out the 3-minute peak',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CravingScreen())),
            ),
            _buildTool(
              context,
              icon: '🎮',
              title: 'Pop the cravings',
              desc: 'A quick tap game to ride it out',
              onTap: () => _showComingSoon(context),
              isPremium: true,
            ),
            _buildTool(
              context,
              icon: '✋',
              title: 'Grounding',
              desc: '5-4-3-2-1 senses reset',
              onTap: () => _showComingSoon(context),
              isPremium: true,
            ),
            _buildTool(
              context,
              icon: '❤️',
              title: 'Your reasons',
              desc: 'Why you started this',
              onTap: () => _showReasons(context),
            ),
            _buildTool(
              context,
              icon: '💵',
              title: 'Money on the line',
              desc: 'What a relapse costs you',
              onTap: () => _showMoneyCost(context),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I vaped anyway',
                    style: TextStyle(color: AppStyle.textFaint, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTool(BuildContext context,
      {required String icon, required String title, required String desc, required VoidCallback onTap, bool isPremium = false}) {
    final locked = isPremium && !QuitService.isPremium();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: AppStyle.card(),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppStyle.emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (locked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              gradient: AppStyle.gradientGold, borderRadius: BorderRadius.circular(6)),
                          child: const Text('PRO',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: AppStyle.textDim, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppStyle.textFaint, size: 18),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    if (!QuitService.isPremium()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon in the next update! 🚀')),
    );
  }

  void _showReasons(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('❤️ Your Reasons', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _reason('🫁', 'Breathe freely again'),
            _reason('💰', 'Save thousands of dollars'),
            _reason('👨‍👩‍👧', 'Be there for your family'),
            _reason('💪', 'Take control of your life'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _reason(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  void _showMoneyCost(BuildContext context) {
    final costPerDay = QuitService.getDailyCost();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('One relapse costs you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('\$${costPerDay.toStringAsFixed(2)} per day',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppStyle.red)),
            const SizedBox(height: 8),
            Text('That\'s \$${(costPerDay * 365).toStringAsFixed(0)} per year!',
                style: const TextStyle(color: AppStyle.textDim, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.emerald,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Stay Strong! 💪', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
