import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

class CravingGameScreen extends StatefulWidget {
  const CravingGameScreen({super.key});

  @override
  State<CravingGameScreen> createState() => _CravingGameScreenState();
}

class _CravingGameScreenState extends State<CravingGameScreen> with TickerProviderStateMixin {
  final Random _random = Random();

  int _score = 0;
  int _lives = 3;
  int _timeLeft = 60;
  int _level = 1;
  int _combo = 0;
  int _bestCombo = 0;

  Timer? _gameTimer;
  Timer? _spawnTimer;

  bool _gameOver = false;
  bool _isPlaying = false;

  // Grid positions for vapes (3x4 grid)
  final List<_Target> _targets = [];
  int _targetId = 0;

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _timeLeft = 60;
      _level = 1;
      _combo = 0;
      _bestCombo = 0;
      _gameOver = false;
      _isPlaying = true;
      _targets.clear();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        // Level up every 20 seconds
        _level = 1 + ((60 - _timeLeft) ~/ 20);
      });
      if (_timeLeft <= 0) _endGame(true);
      if (_lives <= 0) _endGame(false);
    });

    _startSpawning();
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    // Faster spawn at higher levels
    final spawnMs = max(1000 - (_level * 150), 400);
    _spawnTimer = Timer.periodic(Duration(milliseconds: spawnMs), (timer) {
      if (_targets.length < 3 + _level && _isPlaying) {
        final rand = _random.nextDouble();
        setState(() {
          if (rand < 0.20) {
            // 20% - DECOY (healthy item, DON'T smash!)
            _targets.add(_Target(
              id: _targetId++,
              gridIndex: _random.nextInt(12),
              type: _TargetType.decoy,
              life: 1800 - (_level * 150),
            ));
          } else if (rand < 0.32) {
            // 12% - Golden (bonus)
            _targets.add(_Target(
              id: _targetId++,
              gridIndex: _random.nextInt(12),
              type: _TargetType.golden,
              life: 1500 - (_level * 150),
            ));
          } else {
            // Normal vape
            _targets.add(_Target(
              id: _targetId++,
              gridIndex: _random.nextInt(12),
              type: _TargetType.vape,
              life: 1800 - (_level * 200),
            ));
          }
        });
        final targetId = _targetId - 1;
        // Remove after life expires
        Future.delayed(Duration(milliseconds: 1800 - (_level * 150)), () {
          if (mounted && _isPlaying) {
            setState(() {
              final target = _targets.where((t) => t.id == targetId).firstOrNull;
              if (target != null) {
                _targets.remove(target);
                // Only lose life for missed VAPES, not decoys
                if (target.type == _TargetType.vape) {
                  _lives--;
                  _combo = 0;
                  if (_lives <= 0) _endGame(false);
                }
              }
            });
          }
        });
      }
    });
  }

  void _smashTarget(_Target target) {
    setState(() {
      _targets.remove(target);

      if (target.type == _TargetType.decoy) {
        // SMASHED A HEALTHY ITEM! Penalty!
        _combo = 0;
        _score = max(0, _score - 30);
        _lives--;
        if (_lives <= 0) _endGame(false);
        return;
      }

      _combo++;
      _bestCombo = max(_bestCombo, _combo);

      int points = target.type == _TargetType.golden ? 50 : 10;
      points += (_combo ~/ 5) * 10;
      points *= _level;

      _score += points;
    });
  }

  void _endGame(bool won) {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _gameOver = true;
      _targets.clear();
    });

    final coinsEarned = (_score ~/ 20).clamp(10, 100);
    QuitService.addCoins(coinsEarned);
    QuitService.incrementCravingsResisted();
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
        title: const Text('💥 Smash the Craving!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: !_isPlaying && !_gameOver ? _buildStart() : _gameOver ? _buildGameOver() : _buildGame(),
    );
  }

  Widget _buildStart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💥', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text('Smash the Craving!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            const Text(
              'Vapes pop up — smash them before they disappear!\n\n💨 Normal vape = 10 pts\n✨ Golden vape = 50 pts\n❤️ Miss 3 and game over!\n🔥 Combos multiply your score!',
              style: TextStyle(color: AppStyle.textDim, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientEmerald,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppStyle.emerald.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Start Smashing! 💥',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        // HUD
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _hudBox('🏆', '$_score'),
              _hudBox('⏱️', '${_timeLeft}s', isUrgent: _timeLeft <= 10),
              _hudBox('❤️', '$_lives'),
              _hudBox('📊', 'Lv$_level'),
            ],
          ),
        ),
        if (_combo >= 3)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppStyle.gold.withOpacity(0.3), AppStyle.gold.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppStyle.gold.withOpacity(0.5)),
            ),
            child: Text('🔥 ${_combo}x COMBO!',
                style: const TextStyle(color: AppStyle.gold, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        // Game grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final target = _targets.where((t) => t.gridIndex == index).firstOrNull;
                return _buildCell(target);
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('💡 Smashing vapes = crushing cravings!',
              style: TextStyle(color: AppStyle.textDim, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _hudBox(String emoji, String value, {bool isUrgent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? AppStyle.red.withOpacity(0.15) : AppStyle.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUrgent ? AppStyle.red : const Color(0xFF1E2A24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isUrgent ? AppStyle.red : Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCell(_Target? target) {
    String emoji = '';
    Color bgColor = AppStyle.cardBg.withOpacity(0.5);
    Color borderColor = const Color(0xFF1E2A24).withOpacity(0.5);

    if (target != null) {
      if (target.type == _TargetType.golden) {
        emoji = '✨';
        bgColor = AppStyle.gold.withOpacity(0.15);
        borderColor = AppStyle.gold;
      } else if (target.type == _TargetType.decoy) {
        // Healthy decoys - DON'T smash!
        final decoys = ['🍎', '💧', '🏃', '🥗', '😴'];
        emoji = decoys[target.id % decoys.length];
        bgColor = AppStyle.emerald.withOpacity(0.1);
        borderColor = AppStyle.emerald.withOpacity(0.4);
      } else {
        emoji = '🚬';
        bgColor = AppStyle.red.withOpacity(0.1);
        borderColor = AppStyle.red.withOpacity(0.5);
      }
    }

    return GestureDetector(
      onTap: target != null ? () => _smashTarget(target) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: target != null ? 2 : 1),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 40)),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final coinsEarned = (_score ~/ 20).clamp(10, 100);
    final won = _timeLeft <= 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(won ? '🎉' : '💔', style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(won ? 'Craving Crushed!' : 'Game Over!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Score: $_score  •  Best combo: ${_bestCombo}x',
                style: const TextStyle(color: AppStyle.textDim, fontSize: 16)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFB800), Color(0xFFFF8A00)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppStyle.gold.withOpacity(0.3), blurRadius: 20),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text('+$coinsEarned coins!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientEmerald,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Play Again 💥',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TargetType { vape, golden, decoy }

class _Target {
  final int id;
  final int gridIndex;
  final _TargetType type;
  final int life;

  _Target({
    required this.id,
    required this.gridIndex,
    required this.type,
    required this.life,
  });

  bool get isGolden => type == _TargetType.golden;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
