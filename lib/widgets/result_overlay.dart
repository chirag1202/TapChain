import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/level_model.dart';
import '../services/audio_service.dart';
import 'common.dart';

class ResultOverlay extends StatefulWidget {
  const ResultOverlay({
    super.key,
    required this.result,
    required this.hasNext,
    required this.onNext,
    required this.onReplay,
    required this.onLevels,
  });

  final LevelResult result;
  final bool hasNext;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onLevels;

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  final List<bool> _starSounded = [false, false, false];
  bool _coinSounded = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(_sounds);
    _c.forward();
  }

  void _sounds() {
    for (var i = 0; i < widget.result.stars; i++) {
      if (!_starSounded[i] && _c.value >= 0.3 + i * 0.12) {
        _starSounded[i] = true;
        AudioService.instance.coin();
      }
    }
    if (!_coinSounded && _c.value >= 0.5) {
      _coinSounded = true;
      AudioService.instance.coin();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _step(double from, double to, [Curve curve = Curves.easeOut]) =>
      curve.transform(((_c.value - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pop = _step(0, 0.2, Curves.elasticOut);
        final count = (r.reward * _step(0.45, 0.8)).round();
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Transform.scale(
                scale: pop.clamp(0.0, 1.2),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFC93C),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OutlinedText(
                        '🎉 CHAIN COMPLETE!',
                        size: 28,
                        fill: Color(0xFFFFC93C),
                        stroke: Color(0xFF7A2E0E),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        'TIME LEFT',
                        '${r.timeLeft.toStringAsFixed(1)} SEC',
                        0.2,
                      ),
                      _row(
                        'MULTIPLIER',
                        LevelResult.formatMultiplier(r.multiplier),
                        0.27,
                      ),
                      _row(
                        'OBJECTS MOVED',
                        '${r.fallenObjects}/${r.totalObjects}',
                        0.34,
                      ),
                      _row('BASE SCORE', '${r.baseScore}', 0.4),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: _step(0.4, 0.5),
                        child: Column(
                          children: [
                            const Text(
                              'REWARD',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5A6280),
                                letterSpacing: 2,
                              ),
                            ),
                            OutlinedText(
                              '+$count 🪙',
                              size: 44,
                              fill: const Color(0xFFFFC93C),
                              stroke: const Color(0xFF7A2E0E),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 3; i++) _star(i, i < r.stars),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (widget.hasNext)
                        GameButton(
                          label: 'NEXT LEVEL',
                          fontSize: 24,
                          width: double.infinity,
                          onTap: widget.onNext,
                        )
                      else
                        GameButton(
                          label: 'LEVELS',
                          fontSize: 24,
                          width: double.infinity,
                          onTap: widget.onLevels,
                        ),
                      const SizedBox(height: 12),
                      GameButton(
                        label: 'REPLAY',
                        fontSize: 20,
                        width: double.infinity,
                        color: const Color(0xFFFFB02E),
                        dark: const Color(0xFFB36A00),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onTap: widget.onReplay,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _CoinBurstPainter(_step(0.45, 1.0, Curves.easeOut)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value, double at) {
    final p = _step(at, at + 0.1);
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, (1 - p) * 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5A6280),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Color(0xFF1B2A6B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _star(int i, bool earned) {
    final p = earned
        ? _step(0.3 + i * 0.12, 0.42 + i * 0.12, Curves.elasticOut)
        : 1.0;
    return Transform.scale(
      scale: p.clamp(0.0, 1.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.star_rounded,
          size: 54,
          color: earned ? const Color(0xFFFFC93C) : const Color(0xFFD6D6D6),
        ),
      ),
    );
  }
}

class _CoinBurstPainter extends CustomPainter {
  _CoinBurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas c, Size s) {
    if (t <= 0 || t >= 1) return;
    final origin = Offset(s.width / 2, s.height * 0.52);
    for (var i = 0; i < 16; i++) {
      final a = -math.pi / 2 + (i - 7.5) * 0.28;
      final v = 180.0 + (i % 4) * 60;
      final x = origin.dx + math.cos(a) * v * t;
      final y = origin.dy + math.sin(a) * v * t + 520 * t * t;
      final paint = Paint()
        ..color = const Color(0xFFFFC93C).withValues(alpha: 1 - t);
      c.drawCircle(Offset(x, y), 8, paint);
      c.drawCircle(
        Offset(x, y),
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF7A2E0E).withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_CoinBurstPainter old) => old.t != t;
}

class FailOverlay extends StatefulWidget {
  const FailOverlay({
    super.key,
    required this.onReplay,
    required this.onLevels,
  });

  final VoidCallback onReplay;
  final VoidCallback onLevels;

  @override
  State<FailOverlay> createState() => _FailOverlayState();
}

class _FailOverlayState extends State<FailOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pop = Curves.elasticOut.transform(_c.value).clamp(0.0, 1.2);
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black.withValues(alpha: 0.5 * _c.value)),
            Center(
              child: Transform.scale(
                scale: pop,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OutlinedText(
                        'CHAIN FAILED',
                        size: 32,
                        fill: Color(0xFFFF6B6B),
                        stroke: Color(0xFF6B1414),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You missed the target!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5A6280),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GameButton(
                        label: 'TRY AGAIN',
                        fontSize: 26,
                        width: double.infinity,
                        onTap: widget.onReplay,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: widget.onLevels,
                        child: const Text(
                          'LEVELS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5A6280),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
