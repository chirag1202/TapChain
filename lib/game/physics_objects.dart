import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:forge2d/forge2d.dart';

import 'level_config.dart';

class PhysicsObject {
  PhysicsObject(this.spec, this.body)
    : initialPosition = body.position.clone(),
      initialAngle = body.angle,
      _px = body.position.x,
      _py = body.position.y,
      _pa = body.angle;
 
  final ObjectSpec spec;
  final Body body;
  bool gone = false;
  bool activated = false;
  bool running = false;
  bool open = false;
  bool touched = false;
  double flash = -1; // seconds since the target was hit, <0 means never
  final Vector2 initialPosition;
  final double initialAngle;

  double _px, _py, _pa;

  bool get isTarget => spec.kind == ObjectKind.target;
  bool get isJumper => spec.kind == ObjectKind.jumper;
  bool get isButton => spec.kind == ObjectKind.button;
  bool get isGate => spec.kind == ObjectKind.gate;
  bool get isCharacter => spec.kind == ObjectKind.cat || spec.kind == ObjectKind.dog;

  bool get hasFallen {
    if (!spec.isDynamic) return false;
    if (gone) return true;
    final displacement = body.position.distanceTo(initialPosition);
    final tipped =
        spec.kind == ObjectKind.domino &&
        (body.angle - initialAngle).abs() > 0.25;
    return displacement > 0.45 || tipped;
  }

  void savePrevious() {
    _px = body.position.x;
    _py = body.position.y;
    _pa = body.angle;
  }

  double renderX(double t) => _px + (body.position.x - _px) * t;
  double renderY(double t) => _py + (body.position.y - _py) * t;
  double renderAngle(double t) => _pa + (body.angle - _pa) * t;
}

/// Material tuning kept in one place so levels behave consistently.
class Materials {
  static FixtureDef domino(Shape s) =>
      FixtureDef(s, density: 1.0, friction: 0.45, restitution: 0.02);

  static FixtureDef ball(Shape s) =>
      FixtureDef(s, density: 1.0, friction: 0.35, restitution: 0.45);

  // Heavy, grippy, no bounce: hard to roll, strong when it lands.
  static FixtureDef box(Shape s) =>
      FixtureDef(s, density: 4.0, friction: 0.8, restitution: 0.0);

  static FixtureDef platform(Shape s) =>
      FixtureDef(s, density: 0, friction: 0.5, restitution: 0.1);

  static FixtureDef target(Shape s) =>
      FixtureDef(s, density: 0, isSensor: true);

  static FixtureDef jumper(Shape s) =>
      FixtureDef(s, density: 0, friction: 0.2, restitution: 0.85);

  static FixtureDef character(Shape s) =>
      FixtureDef(s, density: 1.2, friction: 0.75, restitution: 0);

  static FixtureDef plank(Shape s) =>
      FixtureDef(s, density: 1.5, friction: 0.65, restitution: 0.02);

  static FixtureDef ramp(Shape s) =>
      FixtureDef(s, density: 0, friction: 0.65, restitution: 0.02);

  static FixtureDef button(Shape s) => FixtureDef(s, density: 0, isSensor: true);

  static FixtureDef gate(Shape s) =>
      FixtureDef(s, density: 0, friction: 0.5, restitution: 0);
}

/// Draws one object centred on the origin of [c]; caller applies translate and rotate.
void paintObject(
  Canvas c,
  LevelTheme t,
  ObjectKind kind, {
  double w = 0,
  double h = 0,
  double radius = 0,
  double flash = -1,
  double time = 0,
  bool active = false,
  bool running = false,
}) {
  switch (kind) {
    case ObjectKind.domino:
      _paintDomino(c, t, w, h);
    case ObjectKind.ball:
      _paintBall(c, t, radius);
    case ObjectKind.box:
      _paintBox(c, t, w, h);
    case ObjectKind.platform:
      _paintPlatform(c, t, w, h);
    case ObjectKind.jumper:
      _paintJumper(c, t, w, h, flash, time);
    case ObjectKind.target:
      _paintTarget(c, t, radius, flash, time);
    case ObjectKind.cat:
      _paintCharacter(c, t, w, h, active, running, time, cat: true);
    case ObjectKind.dog:
      _paintCharacter(c, t, w, h, active, running, time, cat: false);
    case ObjectKind.ramp:
      _paintRamp(c, t, w, h);
    case ObjectKind.button:
      _paintButton(c, t, w, h, active);
    case ObjectKind.gate:
      _paintGate(c, t, w, h, active);
    case ObjectKind.plank:
      _paintPlank(c, t, w, h);
  }
}

void _paintCharacter(Canvas c, LevelTheme t, double w, double h, bool startled, bool running, double time, {required bool cat}) {
  final stride = running ? math.sin(time * 18) * h * 0.08 : 0.0;
  final bodyColor = cat ? const Color(0xFFFFB45C) : const Color(0xFFB8794B);
  c.drawOval(Rect.fromCenter(center: Offset(0, h * 0.05), width: w * 0.86, height: h * 0.62), Paint()..color = bodyColor);
  c.drawCircle(Offset(w * 0.27, -h * 0.16), h * 0.28, Paint()..color = bodyColor);
  if (cat) {
    final ears = Paint()..color = bodyColor;
    c.drawPath(Path()..moveTo(w * 0.12, -h * 0.3)..lineTo(w * 0.17, -h * 0.55)..lineTo(w * 0.3, -h * 0.31)..close(), ears);
    c.drawPath(Path()..moveTo(w * 0.3, -h * 0.31)..lineTo(w * 0.4, -h * 0.53)..lineTo(w * 0.47, -h * 0.2)..close(), ears);
  } else {
    c.drawOval(Rect.fromCenter(center: Offset(w * 0.4, -h * 0.04), width: w * 0.28, height: h * 0.24), Paint()..color = bodyColor);
  }
  c.drawCircle(Offset(w * 0.36, -h * 0.18), h * 0.035, Paint()..color = const Color(0xFF241A17));
  final leg = Paint()..color = const Color(0xFF49352D)..strokeWidth = h * 0.09..strokeCap = StrokeCap.round;
  for (final x in [-w * 0.2, w * 0.18]) {
    c.drawLine(Offset(x, h * 0.25), Offset(x + stride, h * 0.45), leg);
  }
  if (startled && !running) {
    final p = Paint()..color = const Color(0xFFFFD23F)..strokeWidth = h * 0.06..strokeCap = StrokeCap.round;
    c.drawLine(Offset(w * 0.38, -h * 0.62), Offset(w * 0.38, -h * 0.82), p);
    c.drawCircle(Offset(w * 0.38, -h * 0.91), h * 0.025, p);
  }
}

void _paintRamp(Canvas c, LevelTheme t, double w, double h) {
  final path = Path()..moveTo(-w / 2, h / 2)..lineTo(w / 2, -h / 2)..lineTo(w / 2, h / 2)..close();
  c.drawPath(path, Paint()..color = t.platform);
  c.drawLine(Offset(-w / 2, h / 2), Offset(w / 2, -h / 2), Paint()..color = t.accent..strokeWidth = h * 0.2..strokeCap = StrokeCap.round);
}

void _paintButton(Canvas c, LevelTheme t, double w, double h, bool active) {
  final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), Radius.circular(h * 0.35));
  c.drawRRect(rect, Paint()..color = active ? const Color(0xFF43D17A) : const Color(0xFFE24A63));
  c.drawRRect(rect.deflate(h * 0.18), Paint()..color = Colors.white.withValues(alpha: 0.7));
}

void _paintGate(Canvas c, LevelTheme t, double w, double h, bool open) {
  final shift = open ? -h * 0.48 : 0.0;
  final rect = Rect.fromCenter(center: Offset(0, shift), width: w, height: open ? h * 0.12 : h);
  c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(w * 0.16)), Paint()..color = open ? const Color(0xFF43D17A) : const Color(0xFF596273));
  final stripe = Paint()..color = t.accent..strokeWidth = w * 0.2;
  for (var y = rect.top + w; y < rect.bottom; y += w * 2.2) { c.drawLine(Offset(-w * 0.3, y), Offset(w * 0.3, y + w), stripe); }
}

void _paintPlank(Canvas c, LevelTheme t, double w, double h) {
  final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), Radius.circular(h * 0.2));
  c.drawRRect(rect, Paint()..color = t.box);
  c.drawRRect(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = h * 0.1..color = t.boxEdge);
  for (var x = -w / 2 + h * 0.6; x < w / 2; x += h * 0.7) { c.drawLine(Offset(x, -h * 0.3), Offset(x, h * 0.3), Paint()..color = t.boxEdge.withValues(alpha: 0.8)..strokeWidth = h * 0.06); }
}

void _glowStroke(Canvas c, Path p, Color color, double width) {
  c.drawPath(
    p,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 3.2
      ..color = color.withValues(alpha: 0.16),
  );
  c.drawPath(
    p,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 1.8
      ..color = color.withValues(alpha: 0.3),
  );
}

void _paintDomino(Canvas c, LevelTheme t, double w, double h) {
  final r = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: w, height: h),
    Radius.circular(w * 0.28),
  );
  if (t.glow) {
    _glowStroke(c, Path()..addRRect(r), t.domino, 0.05);
  }
  c.drawRRect(r, Paint()..color = t.domino);
  c.drawRRect(
    r.deflate(0.02),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.025
      ..color = Colors.white.withValues(alpha: 0.55),
  );
  final pip = Paint()..color = t.dominoDot;
  c.drawLine(
    Offset(-w * 0.32, 0),
    Offset(w * 0.32, 0),
    Paint()
      ..strokeWidth = 0.02
      ..color = t.dominoDot.withValues(alpha: 0.7),
  );
  for (final dy in [-h * 0.3, -h * 0.17, h * 0.17, h * 0.3]) {
    c.drawCircle(Offset(0, dy), w * 0.13, pip);
  }
}

void _paintBall(Canvas c, LevelTheme t, double r) {
  if (t.glow) {
    c.drawCircle(
      Offset.zero,
      r * 1.6,
      Paint()..color = t.ball.withValues(alpha: 0.14),
    );
    c.drawCircle(
      Offset.zero,
      r * 1.25,
      Paint()..color = t.ball.withValues(alpha: 0.28),
    );
  }
  c.drawCircle(Offset.zero, r, Paint()..color = t.ball);
  c.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035
      ..color = Colors.black.withValues(alpha: 0.25),
  );
  // Stripe shows rotation as the ball rolls.
  c.drawArc(
    Rect.fromCircle(center: Offset.zero, radius: r * 0.7),
    -0.3,
    1.4,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.75),
  );
}

void _paintBox(Canvas c, LevelTheme t, double w, double h) {
  final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
  final r = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.08));
  if (t.glow) {
    _glowStroke(c, Path()..addRRect(r), t.box, 0.06);
  }
  c.drawRRect(r, Paint()..color = t.box);
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.07
    ..color = t.boxEdge;
  c.drawRRect(r.deflate(0.035), edge);
  final brace = Paint()
    ..strokeWidth = 0.06
    ..color = t.boxEdge.withValues(alpha: 0.85);
  final inner = rect.deflate(0.07);
  c.drawLine(inner.topLeft, inner.bottomRight, brace);
  c.drawLine(inner.topRight, inner.bottomLeft, brace);
}

void _paintPlatform(Canvas c, LevelTheme t, double w, double h) {
  final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
  final r = RRect.fromRectAndRadius(rect, Radius.circular(h * 0.25));
  switch (t.id) {
    case ThemeId.garden:
      c.drawRRect(r, Paint()..color = t.platform);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, w, h * 0.38),
          Radius.circular(h * 0.2),
        ),
        Paint()..color = t.groundTop,
      );
    case ThemeId.workshop:
      c.drawRRect(r, Paint()..color = t.platform);
      final grain = Paint()
        ..strokeWidth = 0.02
        ..color = t.platformEdge.withValues(alpha: 0.5);
      c.drawLine(
        Offset(rect.left + 0.2, 0),
        Offset(rect.right - 0.2, 0),
        grain,
      );
      final screw = Paint()..color = t.platformEdge;
      c.drawCircle(Offset(rect.left + h * 0.5, 0), h * 0.12, screw);
      c.drawCircle(Offset(rect.right - h * 0.5, 0), h * 0.12, screw);
    case ThemeId.construction:
      c.drawRRect(r, Paint()..color = t.platform);
      c.save();
      c.clipRRect(r);
      final stripe = Paint()..color = t.accent;
      for (var x = rect.left - h; x < rect.right; x += h * 1.6) {
        c.drawPath(
          Path()
            ..moveTo(x, rect.bottom)
            ..lineTo(x + h * 0.8, rect.bottom)
            ..lineTo(x + h * 1.6, rect.top)
            ..lineTo(x + h * 0.8, rect.top)
            ..close(),
          stripe,
        );
      }
      c.restore();
    case ThemeId.neon:
      c.drawRRect(r, Paint()..color = const Color(0xFF12123A));
      _glowStroke(c, Path()..addRRect(r), t.accent, 0.05);
      c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05
          ..color = t.accent,
      );
    case ThemeId.space:
      c.drawRRect(r, Paint()..color = t.platform);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + 0.1,
            rect.top + h * 0.35,
            w - 0.2,
            h * 0.14,
          ),
          Radius.circular(h * 0.07),
        ),
        Paint()..color = t.accent,
      );
    case ThemeId.ocean:
      c.drawRRect(r, Paint()..color = t.platform);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, w, h * 0.34),
          Radius.circular(h * 0.2),
        ),
        Paint()..color = t.accent.withValues(alpha: 0.55),
      );
      final dot = Paint()..color = Colors.white.withValues(alpha: 0.5);
      for (var x = rect.left + 0.3; x < rect.right - 0.1; x += 0.55) {
        c.drawCircle(Offset(x, h * 0.12), h * 0.07, dot);
      }
    case ThemeId.volcano:
      c.drawRRect(r, Paint()..color = t.platform);
      final crack = Path()..moveTo(rect.left + 0.1, h * 0.05);
      var zig = 0;
      for (var x = rect.left + 0.1; x < rect.right - 0.1; x += 0.3) {
        crack.lineTo(x + 0.15, zig.isEven ? 0 : h * 0.25);
        zig++;
      }
      _glowStroke(c, crack, t.accent, 0.03);
      c.drawPath(
        crack,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.035
          ..color = t.accent,
      );
  }
  if (t.id != ThemeId.neon) {
    c.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03
        ..color = t.platformEdge,
    );
  }
}

void _paintTarget(Canvas c, LevelTheme t, double r, double flash, double time) {
  final pulse = 1 + 0.04 * math.sin(time * 4);
  final flashing = flash >= 0 && flash < 0.8;
  if (t.glow || flashing) {
    final a = flashing ? (1 - flash / 0.8) : 0.25;
    c.drawCircle(
      Offset.zero,
      r * (1.3 + (flashing ? flash * 2.5 : 0)),
      Paint()..color = t.target.withValues(alpha: 0.35 * a + 0.1),
    );
  }
  c.drawCircle(Offset.zero, r * pulse, Paint()..color = t.target);
  c.drawCircle(Offset.zero, r * 0.72 * pulse, Paint()..color = Colors.white);
  c.drawCircle(Offset.zero, r * 0.46 * pulse, Paint()..color = t.target);
  c.drawCircle(Offset.zero, r * 0.2 * pulse, Paint()..color = Colors.white);
  c.drawCircle(
    Offset.zero,
    r * pulse,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.04
      ..color = Colors.black.withValues(alpha: 0.25),
  );
}

void _paintJumper(
  Canvas c,
  LevelTheme t,
  double w,
  double h,
  double flash,
  double time,
) {
  final activated = flash >= 0 && flash < 0.28;
  final pulse = activated ? (1 - flash / 0.28) : 0.0;
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(0, h * 0.28), width: w, height: h * 0.42),
    Radius.circular(h * 0.12),
  );
  if (t.glow || activated) {
    c.drawRRect(
      body,
      Paint()
        ..color = t.accent.withValues(alpha: activated ? 0.5 * pulse : 0.18),
    );
  }
  c.drawRRect(body, Paint()..color = t.platformEdge);

  final spring = Path()..moveTo(-w * 0.26, h * 0.2);
  const coils = 4;
  for (var i = 0; i <= coils; i++) {
    final x = i.isEven ? -w * 0.2 : w * 0.2;
    final y = h * 0.12 - i * h * 0.27;
    spring.lineTo(x, y);
  }
  c.drawPath(
    spring,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = t.accent,
  );

  final plate = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(0, -h * 0.48),
      width: w * 0.9,
      height: h * 0.18,
    ),
    Radius.circular(h * 0.08),
  );
  c.drawRRect(plate, Paint()..color = t.domino);
  c.drawRRect(
    plate,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.035
      ..color = Colors.white.withValues(alpha: 0.75),
  );

  if (activated) {
    final arrowY = -h * (0.85 + pulse * 0.3);
    final arrowPaint = Paint()
      ..color = t.accent.withValues(alpha: pulse)
      ..strokeWidth = h * 0.08
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(0, -h * 0.7), Offset(0, arrowY), arrowPaint);
    c.drawLine(
      Offset(0, arrowY),
      Offset(-h * 0.16, arrowY + h * 0.17),
      arrowPaint,
    );
    c.drawLine(
      Offset(0, arrowY),
      Offset(h * 0.16, arrowY + h * 0.17),
      arrowPaint,
    );
  } else {
    final arrowPaint = Paint()
      ..color = t.accent.withValues(alpha: 0.8 + 0.2 * math.sin(time * 3))
      ..strokeWidth = h * 0.07
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(0, -h * 0.63), Offset(0, -h * 0.95), arrowPaint);
    c.drawLine(Offset(0, -h * 0.95), Offset(-h * 0.13, -h * 0.81), arrowPaint);
    c.drawLine(Offset(0, -h * 0.95), Offset(h * 0.13, -h * 0.81), arrowPaint);
  }
}
