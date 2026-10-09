import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';

class CravingScreen extends StatefulWidget {
  const CravingScreen({super.key});

  @override
  State<CravingScreen> createState() => _CravingScreenState();
}

class _CravingScreenState extends State<CravingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _secondsLeft = 300; // 5 minutes
  late Timer _timer;
  bool _completed = false;
  String _breathPhase = 'Breathe in...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.addStatusListener((status) {
      if (mounted) {
        setState(() {
          _breathPhase = status == AnimationStatus.forward || status == AnimationStatus.completed
              ? 'Breathe in...'
              : 'Breathe out...';
        });
      }
    });
    _controller.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _completed = true;
            t.cancel();
            _controller.stop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧘 Beat the Craving'),
        centerTitle: true,
      ),
      body: _completed ? _buildCompleted() : _buildBreathing(minutes, seconds),
    );
  }

  Widget _buildBreathing(int minutes, int seconds) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cravings last 5 minutes.\nYou are stronger! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 40),
            // Breathing circle - properly centered
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🫁', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        _breathPhase,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Timer - centered
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'remaining',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Focus on your breathing.\nThe urge will pass.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleted() {
    // Show paywall after beating craving (emotional high = best conversion moment)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !QuitService.isPremium() && !QuitService.hasSeenPostCravingPaywall()) {
        QuitService.markPostCravingPaywallSeen();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaywallScreen(),
                fullscreenDialog: true,
              ),
            );
          }
        });
      }
    });

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'You beat the craving!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Every craving you resist\nmakes you stronger.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await QuitService.incrementCravingsResisted();
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('I Did It! 💪', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
