import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quitvape/main.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String _phase = 'Get Ready...';
  int _breathCount = 0;
  int _totalBreaths = 5;
  bool _isActive = false;
  Timer? _phaseTimer;

  final List<Map<String, dynamic>> _phases = [
    {'text': 'Breathe In... 🫁', 'duration': 4},
    {'text': 'Hold... ⏸️', 'duration': 4},
    {'text': 'Breathe Out... 💨', 'duration': 4},
  ];
  int _currentPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _breathCount = 0;
      _currentPhaseIndex = 0;
    });
    _runPhase();
  }

  void _runPhase() {
    if (!mounted || !_isActive) return;

    final phase = _phases[_currentPhaseIndex];
    setState(() => _phase = phase['text']);

    // Animate circle
    if (_currentPhaseIndex == 0) {
      // Breathe in - expand
      _controller.duration = Duration(seconds: phase['duration']);
      _controller.forward(from: 0.6);
    } else if (_currentPhaseIndex == 2) {
      // Breathe out - shrink
      _controller.duration = Duration(seconds: phase['duration']);
      _controller.reverse(from: 1.0);
    }
    // Hold - keep as is

    _phaseTimer = Timer(Duration(seconds: phase['duration']), () {
      if (!mounted || !_isActive) return;

      setState(() {
        _currentPhaseIndex++;
        if (_currentPhaseIndex >= _phases.length) {
          _currentPhaseIndex = 0;
          _breathCount++;
          if (_breathCount >= _totalBreaths) {
            _complete();
            return;
          }
        }
      });
      _runPhase();
    });
  }

  void _complete() {
    setState(() {
      _isActive = false;
      _phase = 'Well done! 🎉';
    });
    _controller.animateTo(0.8);
  }

  void _stop() {
    _phaseTimer?.cancel();
    _controller.stop();
    setState(() {
      _isActive = false;
      _phase = 'Get Ready...';
      _breathCount = 0;
      _currentPhaseIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🫁 Breathing Exercise', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Breathing circle
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 200 * _animation.value,
                    height: 200 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppStyle.gradientLogo,
                      boxShadow: [
                        BoxShadow(
                          color: AppStyle.skyBlue.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isActive ? '${_breathCount + 1}/$_totalBreaths' : '🫁',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                _phase,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!_isActive && _breathCount >= _totalBreaths)
                const Text(
                  'You completed 5 deep breaths!\nCravings fade with every breath. 💪',
                  style: TextStyle(color: AppStyle.textDim, fontSize: 16),
                  textAlign: TextAlign.center,
                )
              else if (!_isActive)
                const Text(
                  'Deep breathing calms cravings in seconds.\nFollow the circle and breathe with it.',
                  style: TextStyle(color: AppStyle.textDim, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              if (!_isActive)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppStyle.gradientEmerald,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _startBreathing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Start Breathing 🫁',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _stop,
                  child: const Text('Stop', style: TextStyle(color: AppStyle.textDim, fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
