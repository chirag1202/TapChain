import 'dart:math' as math;

import 'package:flutter/material.dart';

double _r(int i, int salt) {
  final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

/// Lively physics-themed backdrop with three parallax layers.
class PhysicsBackground extends StatefulWidget {
  const PhysicsBackground({super.key, this.child});

  final Widget? child;

  @override
  State<PhysicsBackground> createState() => _PhysicsBackgroundState();
}

class _PhysicsBackgroundState extends State<PhysicsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(painter: _BgPainter(_c), isComplex: true),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.anim) : super(repaint: anim);

  final AnimationController anim;

  @override
  void paint(Canvas c, Size s) {
    final t = anim.value * 40; // seconds
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4B6CFF), Color(0xFF8E5BFF), Color(0xFFFF8FB1)],
        ).createShader(Offset.zero & s),
    );

    // Far layer: big soft platforms.
    for (var i = 0; i < 4; i++) {
      final y = s.height * (0.15 + 0.22 * i + 0.03 * _r(i, 1));
      final x = ((_r(i, 2) * s.width + t * 4) % (s.width + 200)) - 100;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, s.width * 0.5, 14),
          const Radius.circular(7),
        ),
        Paint()..color = const Color(0x22FFFFFF),
      );
    }

    // Mid layer: dominoes tumbling slowly.
    for (var i = 0; i < 9; i++) {
      final speed = 10 + 8 * _r(i, 3);
      final x = _r(i, 4) * s.width + math.sin(t * 0.4 + i) * 12;
      final y = ((_r(i, 5) * s.height + t * speed) % (s.height + 80)) - 40;
      final w = 12 + 6 * _r(i, 6);
      c.save();
      c.translate(x, y);
      c.rotate(t * 0.3 * (i.isEven ? 1 : -1) + i);
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: w * 2.8),
        const Radius.circular(3),
      );
      c.drawRRect(
        r,
        Paint()
          ..color = [
            const Color(0x55FF6B6B),
            const Color(0x55FFC93C),
            const Color(0x554DD0E1),
          ][i % 3],
      );
      c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x55FFFFFF),
      );
      c.restore();
    }

    // Near layer: bouncing balls.
    for (var i = 0; i < 4; i++) {
      final x = s.width * (0.12 + 0.25 * i + 0.05 * _r(i, 7));
      final period = 1.6 + _r(i, 8);
      final phase = ((t / period) + _r(i, 9)) % 1;
      final hop = (1 - math.pow(2 * phase - 1, 2)).toDouble();
      final floor = s.height * (0.9 - 0.04 * (i % 2));
      final y = floor - hop * s.height * 0.2;
      final r = 11.0 + 4 * _r(i, 10);
      c.drawCircle(
        Offset(x, floor + 2),
        r * (1 - hop * 0.5),
        Paint()..color = const Color(0x22000000),
      );
      c.drawCircle(Offset(x, y), r, Paint()..color = const Color(0xCCFFC93C));
      c.drawCircle(
        Offset(x - r * 0.3, y - r * 0.3),
        r * 0.28,
        Paint()..color = const Color(0x99FFFFFF),
      );
    }

    // Particles.
    for (var i = 0; i < 30; i++) {
      final x = _r(i, 11) * s.width;
      final y =
          s.height -
          ((_r(i, 12) * s.height + t * (8 + 14 * _r(i, 13))) % s.height);
      c.drawCircle(
        Offset(x, y),
        1.2 + 1.6 * _r(i, 14),
        Paint()..color = Color.fromARGB(90, 255, 255, 255),
      );
    }

    // Ground strip.
    c.drawRect(
      Rect.fromLTWH(0, s.height * 0.935, s.width, s.height * 0.065),
      Paint()..color = const Color(0x33000000),
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => false;
}
