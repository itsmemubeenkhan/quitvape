import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class QuitPlanScreen extends StatelessWidget {
  const QuitPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = QuitService.getQuitDuration().inDays;
    final cigsPerDay = 20; // Could be from prefs

    final phases = [
      {
        'title': 'Phase 1: Foundation',
        'days': 'Days 1-7',
        'emoji': '🌱',
        'color': AppStyle.emerald,
        'tasks': [
          'Complete daily check-ins',
          'Use breathing exercises for cravings',
          'Identify your top 3 triggers',
          'Tell a friend about your quit',
        ],
      },
      {
        'title': 'Phase 2: Building Strength',
        'days': 'Days 8-21',
        'emoji': '💪',
        'color': Colors.blue,
        'tasks': [
          'Maintain check-in streak',
          'Try a new SOS tool each week',
          'Exercise 20 min daily',
          'Save your craving money visibly',
        ],
      },
      {
        'title': 'Phase 3: Mastery',
        'days': 'Days 22-30',
        'emoji': '🏆',
        'color': AppStyle.gold,
        'tasks': [
          'Help another quitter (share tips)',
          'Review your health milestones',
          'Plan your 1-month celebration',
          'Set your next 90-day goal',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('📋 Personal Quit Plan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppStyle.emerald.withOpacity(0.15), AppStyle.emerald.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppStyle.emerald.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your 30-Day Roadmap 🗺️',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Based on $cigsPerDay cigarettes/day habit • You\'re on day $days',
                      style: const TextStyle(color: AppStyle.textDim, fontSize: 14)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (days / 30).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF1E2A24),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppStyle.emerald),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${((days / 30 * 100).clamp(0, 100)).toInt()}% complete',
                      style: const TextStyle(color: AppStyle.emerald, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...phases.asMap().entries.map((e) {
              final phase = e.value;
              final isActive = _isPhaseActive(e.key, days);
              final isDone = _isPhaseDone(e.key, days);
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppStyle.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? (phase['color'] as Color).withOpacity(0.4) : const Color(0xFF1E2A24),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(phase['emoji'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(phase['title'] as String,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(phase['days'] as String,
                                  style: TextStyle(color: phase['color'] as Color, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (isDone)
                          const Icon(Icons.check_circle_rounded, color: AppStyle.emerald, size: 28)
                        else if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (phase['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('ACTIVE',
                                style: TextStyle(color: phase['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...(phase['tasks'] as List<String>).map((task) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isDone ? AppStyle.emerald : AppStyle.textFaint,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(task,
                                    style: TextStyle(
                                        color: isDone ? AppStyle.textDim : Colors.white,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool _isPhaseActive(int index, int days) {
    if (index == 0) return days < 7;
    if (index == 1) return days >= 7 && days < 21;
    return days >= 21 && days < 30;
  }

  bool _isPhaseDone(int index, int days) {
    if (index == 0) return days >= 7;
    if (index == 1) return days >= 21;
    return days >= 30;
  }
}
