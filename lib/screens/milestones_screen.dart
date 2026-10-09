import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = QuitService.getMilestones();

    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Health Milestones')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: milestones.length,
        itemBuilder: (context, i) {
          final m = milestones[i];
          final achieved = m['achieved'] as bool;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: achieved ? Colors.green.shade50 : null,
            child: ListTile(
              leading: Text(m['icon'] as String, style: const TextStyle(fontSize: 32)),
              title: Text(m['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(m['desc'] as String),
              trailing: achieved
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                  : const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
