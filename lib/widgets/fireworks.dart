import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class _Rocket {
  _Rocket(this.x0, this.y0, this.x1, this.y1, this.color);
  final double x0, y0, x1, y1;
  final Color color;
  double t = 0;
}

class _Spark {
  _Spark(this.x, this.y, this.vx, this.vy, this.life, this.color)
    : maxLife = life,
      px = x,
      py = y;
  double x, y, px, py, vx, vy, life;
  final double maxLife;
  final Color color;
}

/// Celebration shells: rockets climb, burst into sparks, and fall with gravity.
class Fireworks extends StatefulWidget {
  const Fireworks({super.key, this.duration = const Duration(seconds: 7)});

  /// How long new shells keep launching; sparks finish fading afterwards.
  final Duration duration;

  @override
  State<Fireworks> createState() => _FireworksState();
}

class _FireworksState extends State<Fireworks>
    with SingleTickerProviderStateMixin {
  static const _palette = [
    Color(0xFFFFC93C),
    Color(0xFFFF6B9D),
    Color(0xFF4DD0E1),
    Color(0xFF9BF06A),
    Color(0xFFFF8A3D),
    Color(0xFFFFFFFF),
    Color(0xFFB388FF),
  ];

  late final Ticker _ticker;
  final math.Random _rng = math.Random();
  final List<_Rocket> _rockets = [];
  final List<_Spark> _sparks = [];
  final ValueNotifier<int> _frame = ValueNotifier(0);
  Duration _last = Duration.zero;
  double _spawnIn = 0;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = math.min(0.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    if (_size.isEmpty) return;

    if (elapsed < widget.duration) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _launch();
        _spawnIn = 0.28 + _rng.nextDouble() * 0.3;
      }
    }

    for (var i = _rockets.length - 1; i >= 0; i--) {
      final r = _rockets[i];
      r.t += dt / 0.8;
      if (r.t >= 1) {
        _burst(r);
        _rockets.removeAt(i);
      }
    }

    for (var i = _sparks.length - 1; i >= 0; i--) {
      final s = _sparks[i];
      s.life -= dt;
      if (s.life <= 0) {
        _sparks.removeAt(i);
        continue;
      }
      s.px = s.x;
      s.py = s.y;
      s.vx *= 0.985;
      s.vy = s.vy * 0.985 + 160 * dt;
      s.x += s.vx * dt;
      s.y += s.vy * dt;
    }

    _frame.value++;
  }

  void _launch() {
    final w = _size.width;
    final h = _size.height;
    final x1 = w * (0.12 + _rng.nextDouble() * 0.76);
    _rockets.add(
      _Rocket(
        w * 0.5 + (x1 - w * 0.5) * 0.3,
        h,
        x1,
        h * (0.12 + _rng.nextDouble() * 0.36),
        _palette[_rng.nextInt(_palette.length)],
      ),
    );
  }

  void _burst(_Rocket r) {
    final n = _sparks.length > 260 ? 24 : 44;
    final speed = 150 + _rng.nextDouble() * 120;
    final second = _palette[_rng.nextInt(_palette.length)];
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2 + _rng.nextDouble() * 0.1;
      final v = speed * (0.55 + 0.45 * _rng.nextDouble());
      _sparks.add(
        _Spark(
          r.x1,
          r.y1,
          math.cos(a) * v,
          math.sin(a) * v,
          0.9 + _rng.nextDouble() * 0.7,
          i.isEven ? r.color : second,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          _size = box.biggest;
          return CustomPaint(
            size: box.biggest,
            painter: _FireworksPainter(this, _frame),
          );
        },
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter(this.state, Listenable repaint) : super(repaint: repaint);

  final _FireworksState state;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;
    for (final r in state._rockets) {
      final e = Curves.easeOut.transform(r.t);
      final x = r.x0 + (r.x1 - r.x0) * e;
      final y = r.y0 + (r.y1 - r.y0) * e;
      final e0 = Curves.easeOut.transform(math.max(0, r.t - 0.08));
      final tx = r.x0 + (r.x1 - r.x0) * e0;
      final ty = r.y0 + (r.y1 - r.y0) * e0;
      paint.color = r.color.withValues(alpha: 0.9);
      canvas.drawLine(Offset(tx, ty), Offset(x, y), paint);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
    for (final s in state._sparks) {
      final a = (s.life / s.maxLife).clamp(0.0, 1.0);
      paint.color = s.color.withValues(alpha: a);
      canvas.drawLine(Offset(s.px, s.py), Offset(s.x, s.y), paint);
      canvas.drawCircle(
        Offset(s.x, s.y),
        2.2 * a + 0.6,
        Paint()..color = s.color.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter old) => false;
}
