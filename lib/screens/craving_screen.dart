import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class CravingScreen extends StatefulWidget {
  const CravingScreen({super.key});

  @override
  State<CravingScreen> createState() => _CravingScreenState();
}

class _CravingScreenState extends State<CravingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _secondsLeft = 180; // 3 minutes (craving peak)
  late Timer _timer;
  bool _completed = false;
  String _breathPhase = 'Breathe in...';
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _controller.addStatusListener((status) {
      if (mounted && (status == AnimationStatus.completed || status == AnimationStatus.dismissed)) {
        setState(() {
          _breathCount++;
          _breathPhase = status == AnimationStatus.completed ? 'Hold...' : 'Breathe in...';
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && !_completed) {
            setState(() {
              _breathPhase = status == AnimationStatus.completed ? 'Breathe out...' : 'Breathe in...';
            });
          }
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
    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Guided Breathing', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: _completed ? _buildCompleted() : _buildBreathing(),
    );
  }

  Widget _buildBreathing() {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ride out the craving 🌊',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cravings peak at 3 minutes.\nBreathe with the circle.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppStyle.textDim, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppStyle.emerald.withOpacity(0.3), AppStyle.emerald.withOpacity(0.08)],
                        ),
                        border: Border.all(color: AppStyle.emerald.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(color: AppStyle.emerald.withOpacity(0.25), blurRadius: 40, spreadRadius: 8),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🫁', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 8),
                      Text(_breathPhase,
                          style: const TextStyle(fontSize: 15, color: AppStyle.emerald, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Breath $_breathCount',
                          style: const TextStyle(fontSize: 12, color: AppStyle.textFaint)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              decoration: AppStyle.card(),
              child: Column(
                children: [
                  Text('$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 46, fontWeight: FontWeight.w800, color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  const Text('until craving passes', style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress bar
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(color: const Color(0xFF1E2A24), borderRadius: BorderRadius.circular(4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1 - (_secondsLeft / 180),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: AppStyle.gradientEmerald, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !QuitService.isPremium() && !QuitService.hasSeenPostCravingPaywall()) {
        QuitService.markPostCravingPaywallSeen();
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true));
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppStyle.gradientEmerald,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppStyle.emerald.withOpacity(0.4), blurRadius: 40, spreadRadius: 8)],
              ),
              child: const Center(child: Text('🎉', style: TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 28),
            const Text('Craving crushed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('You just proved you\'re stronger\nthan any craving. 💪',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppStyle.textDim, fontSize: 16, height: 1.5)),
            const SizedBox(height: 40),
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
                  onPressed: () async {
                    await QuitService.incrementCravingsResisted();
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('I Did It! 🔥',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
