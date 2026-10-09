import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int _mood = 3; // 0-4
  int _cravingStrength = 1; // 0-4
  final Set<String> _triggers = {};

  final List<String> _moods = ['😫', '😟', '😐', '🙂', '😄'];
  final List<String> _strengthEmojis = ['🟢', '🟡', '🟠', '🔴', '🔥'];
  final List<String> _strengthLabels = ['None', 'Mild', 'Medium', 'Strong', 'Intense'];

  final List<Map<String, String>> _triggerOptions = [
    {'icon': '⚡', 'label': 'Stress'},
    {'icon': '☕', 'label': 'Coffee'},
    {'icon': '😑', 'label': 'Boredom'},
    {'icon': '🍽️', 'label': 'After meals'},
    {'icon': '🚗', 'label': 'Driving'},
    {'icon': '👥', 'label': 'Social'},
    {'icon': '🍺', 'label': 'Alcohol'},
    {'icon': '🌅', 'label': 'Waking up'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Check-in', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How's your mood?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final selected = _mood == i;
                return GestureDetector(
                  onTap: () => setState(() => _mood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: selected ? AppStyle.emerald.withOpacity(0.15) : AppStyle.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected ? AppStyle.emerald : const Color(0xFF1E2A24),
                          width: selected ? 2 : 1),
                    ),
                    child: Center(child: Text(_moods[i], style: const TextStyle(fontSize: 30))),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('How strong are cravings?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final selected = _cravingStrength == i;
                return GestureDetector(
                  onTap: () => setState(() => _cravingStrength = i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: selected ? AppStyle.emerald.withOpacity(0.15) : AppStyle.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: selected ? AppStyle.emerald : const Color(0xFF1E2A24),
                              width: selected ? 2 : 1),
                        ),
                        child: Center(child: Text(_strengthEmojis[i], style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(height: 4),
                      Text(_strengthLabels[i],
                          style: TextStyle(
                              fontSize: 10,
                              color: selected ? AppStyle.emerald : AppStyle.textFaint,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('What triggered it? (optional)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _triggerOptions.map((t) {
                final selected = _triggers.contains(t['label']);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _triggers.remove(t['label']);
                    } else {
                      _triggers.add(t['label']!);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppStyle.emerald.withOpacity(0.15) : AppStyle.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: selected ? AppStyle.emerald : const Color(0xFF1E2A24),
                          width: selected ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t['icon']!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(t['label']!,
                            style: TextStyle(
                                color: selected ? Colors.white : AppStyle.textDim,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientEmerald,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppStyle.emerald.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Save check-in ✅',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveCheckIn() async {
    await QuitService.saveCheckIn(mood: _mood, cravingStrength: _cravingStrength, triggers: _triggers.toList());
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Checked in! Streak growing strong! 🔥'),
          backgroundColor: Color(0xFF00B87D),
        ),
      );
    }
  }
}
