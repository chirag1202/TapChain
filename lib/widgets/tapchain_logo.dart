import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'common.dart';

/// Animated TAPCHAIN wordmark with a falling domino, bouncing ball and sparks.
class TapChainLogo extends StatefulWidget {
  const TapChainLogo({super.key, this.width = 300});

  final double width;

  @override
  State<TapChainLogo> createState() => _TapChainLogoState();
}

class _TapChainLogoState extends State<TapChainLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final bounce = 1 + 0.035 * math.sin(_c.value * math.pi * 2);
        return SizedBox(
          width: w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: w,
                height: w * 0.36,
                child: CustomPaint(painter: _LogoArtPainter(_c.value)),
              ),
              Transform.scale(
                scale: bounce,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedText(
                        'TAP',
                        size: w * 0.2,
                        fill: const Color(0xFFFFC93C),
                        stroke: const Color(0xFF7A2E0E),
                      ),
                      OutlinedText(
                        'CHAIN',
                        size: w * 0.2,
                        fill: Colors.white,
                        stroke: const Color(0xFF1B2A6B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LogoArtPainter extends CustomPainter {
  _LogoArtPainter(this.t);

  final double t;

  @override
  void paint(Canvas c, Size s) {
    final base = s.height * 0.92;
    final dw = s.height * 0.16;
    final dh = s.height * 0.62;
    final gap = dw * 2.4;
    final startX = s.width * 0.18;
    final ground = Paint()
      ..color = const Color(0xFF1B2A6B)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(
      Offset(s.width * 0.08, base + 2),
      Offset(s.width * 0.92, base + 2),
      ground,
    );

    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFFFFC93C),
      Color(0xFF4DD0E1),
      Color(0xFF9B5DE5),
    ];
    for (var i = 0; i < 4; i++) {
      final fall = ((t * 1.25 - i * 0.12) / 0.22).clamp(0.0, 1.0);
      final ang = Curves.easeIn.transform(fall) * 1.15;
      final pivot = Offset(startX + i * gap + dw, base);
      c.save();
      c.translate(pivot.dx, pivot.dy);
      c.rotate(ang);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(-dw, -dh, dw, dh),
        Radius.circular(dw * 0.3),
      );
      c.drawRRect(r, Paint()..color = colors[i]);
      c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF1B2A6B),
      );
      c.drawCircle(
        Offset(-dw / 2, -dh * 0.75),
        dw * 0.16,
        Paint()..color = Colors.white,
      );
      c.drawCircle(
        Offset(-dw / 2, -dh * 0.25),
        dw * 0.16,
        Paint()..color = Colors.white,
      );
      c.restore();

      if (fall > 0 && fall < 1) {
        for (var k = 0; k < 3; k++) {
          final a = k * 2.1 + i;
          final d = fall * dh * 0.5;
          c.drawCircle(
            pivot + Offset(math.cos(a) * d, -dh * 0.5 + math.sin(a) * d),
            2.4 * (1 - fall),
            Paint()..color = const Color(0xFFFFE066),
          );
        }
      }
    }

    final r = s.height * 0.16;
    final bx = startX + 4 * gap + r * 2;
    final hop = (math.sin(t * math.pi * 4)).abs();
    final by = base - r - hop * s.height * 0.45;
    c.drawCircle(
      Offset(bx, base + 1),
      r * (1 - hop * 0.4),
      Paint()..color = const Color(0x33000000),
    );
    c.drawCircle(Offset(bx, by), r, Paint()..color = const Color(0xFFFFC93C));
    c.drawCircle(
      Offset(bx, by),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF7A2E0E),
    );
    c.drawArc(
      Rect.fromCircle(center: Offset(bx, by), radius: r * 0.6),
      -0.3,
      1.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_LogoArtPainter old) => old.t != t;
}
