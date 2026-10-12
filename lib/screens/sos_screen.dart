import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/craving_screen.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/screens/ai_coach_screen.dart';
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppStyle.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Craving SOS', style: TextStyle(fontWeight: FontWeight.bold, color: AppStyle.ink)),
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
                  const Icon(Icons.emoji_events_outlined,
                      size: 18, color: AppStyle.primary),
                  const SizedBox(width: 8),
                  Text('$cravingsBeaten cravings beaten',
                      style: const TextStyle(color: AppStyle.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTool(
              context,
              icon: Icons.smart_toy_outlined,
              title: 'AI Quit Coach',
              desc: 'Chat 24/7 in your language',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AICoachScreen())),
            ),
            _buildTool(
              context,
              icon: Icons.air_outlined,
              title: 'Guided breathing',
              desc: '4-4-4-4 box breathing to settle',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CravingScreen())),
            ),
            _buildTool(
              context,
              icon: Icons.timer_outlined,
              title: 'Craving timer',
              desc: 'Ride out the 3-minute peak',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CravingScreen())),
            ),
            _buildTool(
              context,
              icon: Icons.sports_esports_outlined,
              title: 'Beat the craving game',
              desc: 'A quick tap game to ride it out',
              onTap: () => _showComingSoon(context),
              isPremium: true,
            ),
            _buildTool(
              context,
              icon: Icons.spa_outlined,
              title: 'Grounding',
              desc: '5-4-3-2-1 senses reset',
              onTap: () => _showComingSoon(context),
              isPremium: true,
            ),
            _buildTool(
              context,
              icon: Icons.favorite_outline,
              title: 'Your reasons',
              desc: 'Why you started this',
              onTap: () => _showReasons(context),
            ),
            _buildTool(
              context,
              icon: Icons.savings_outlined,
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
      {required IconData icon, required String title, required String desc, required VoidCallback onTap, bool isPremium = false}) {
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
                color: AppStyle.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppStyle.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyle.ink)),
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
            const Row(
              children: [
                Icon(Icons.favorite_outline,
                    color: AppStyle.red, size: 22),
                SizedBox(width: 10),
                Text('Your Reasons',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppStyle.ink)),
              ],
            ),
            const SizedBox(height: 16),
            _reason(Icons.air_outlined, 'Breathe freely again'),
            _reason(Icons.savings_outlined, 'Save thousands every year'),
            _reason(Icons.family_restroom_outlined, 'Be there for your family'),
            _reason(Icons.bolt_outlined, 'Take control of your life'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _reason(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppStyle.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppStyle.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 16, color: AppStyle.ink)),
          ),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppStyle.redSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.savings_outlined,
                  color: AppStyle.red, size: 32),
            ),
            const SizedBox(height: 12),
            const Text('One relapse costs you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyle.ink)),
            const SizedBox(height: 8),
            Text('${QuitService.getCurrency()}${costPerDay.toStringAsFixed(2)} per day',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppStyle.red)),
            const SizedBox(height: 8),
            Text(
                'That\'s ${QuitService.getCurrency()}${(costPerDay * 365).toStringAsFixed(0)} per year!',
                style: const TextStyle(color: AppStyle.textDim, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyle.primaryButton(),
                child: const Text('Stay strong',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
