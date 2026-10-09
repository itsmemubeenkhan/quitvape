import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cravingsBeaten = QuitService.getCravingsResisted();
    final days = QuitService.getQuitDuration().inDays;
    final moneySaved = QuitService.getMoneySaved();

    // Simulated data for charts
    final resistRate = days > 0 ? ((cravingsBeaten / (cravingsBeaten + 3)) * 100).clamp(0, 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('📊 Advanced Insights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppStyle.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$cravingsBeaten',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppStyle.emerald)),
                        const Text('Cravings beaten', style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppStyle.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$resistRate%',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppStyle.emerald)),
                        const Text('Resist rate', style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'Money saved',
              'Climbing every single day. 📈',
              '↑ Climbing',
              AppStyle.emerald,
              _buildLineChart(AppStyle.gold, [0.1, 0.25, 0.35, 0.5, 0.65, 0.8, 0.95]),
            ),
            _buildChartCard(
              'Cravings over time',
              'Watch them fade as you go.',
              '↓ Falling',
              AppStyle.emerald,
              _buildLineChart(AppStyle.emerald, [0.9, 0.7, 0.75, 0.45, 0.5, 0.25, 0.15]),
            ),
            _buildChartCard(
              'Your peak danger zones',
              'When cravings hit hardest:',
              '⚠️ Alert',
              AppStyle.gold,
              _buildDangerZones(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, String badge, Color badgeColor, Widget chart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppStyle.textDim, fontSize: 13)),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildLineChart(Color color, List<double> points) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: _LineChartPainter(points, color),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDangerZones() {
    final zones = [
      {'time': 'Morning coffee ☕', 'level': 0.8},
      {'time': 'After meals 🍽️', 'level': 0.9},
      {'time': 'Work stress 💼', 'level': 0.7},
      {'time': 'Evening relax 🛋️', 'level': 0.6},
    ];
    return Column(
      children: zones.map((z) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(z['time'] as String, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: z['level'] as double,
                  backgroundColor: const Color(0xFF1E2A24),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (z['level'] as double) > 0.75 ? AppStyle.red : AppStyle.gold,
                  ),
                  minHeight: 10,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _LineChartPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Dots
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
