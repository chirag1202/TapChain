import 'dart:math' as math;
import 'dart:ui';

import 'level_config.dart';

double _rnd(int i, [int salt = 0]) {
  final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

Paint _p(Color c) => Paint()..color = c;

void _sky(Canvas c, Size s, LevelTheme t) {
  c.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), [
        t.skyTop,
        t.skyBottom,
      ]),
  );
}

void _gear(Canvas c, Offset o, double r, int teeth, double angle, Color color) {
  final path = Path();
  final n = teeth * 2;
  for (var i = 0; i < n; i++) {
    final a = angle + i * math.pi / teeth;
    final rr = i.isEven ? r : r * 0.8;
    final p = o + Offset(math.cos(a), math.sin(a)) * rr;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  path.close();
  c.drawPath(path, _p(color));
  c.drawCircle(o, r * 0.3, _p(const Color(0x55000000)));
}

void _cloud(Canvas c, Offset o, double r, Color color) {
  c.drawCircle(o, r, _p(color));
  c.drawCircle(o + Offset(r * 0.9, r * 0.2), r * 0.75, _p(color));
  c.drawCircle(o + Offset(-r * 0.9, r * 0.25), r * 0.65, _p(color));
  c.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx - r * 1.5, o.dy + r * 0.2, r * 3, r * 0.8),
      Radius.circular(r * 0.4),
    ),
    _p(color),
  );
}

/// Screen-space backdrop, unique per level. [t] is elapsed seconds.
void paintBackground(Canvas c, Size s, LevelTheme theme, double t) {
  _sky(c, s, theme);
  switch (theme.id) {
    case ThemeId.garden:
      _garden(c, s, t);
    case ThemeId.workshop:
      _workshop(c, s, t);
    case ThemeId.construction:
      _construction(c, s, t);
    case ThemeId.neon:
      _neon(c, s, t);
    case ThemeId.space:
      _space(c, s, t);
    case ThemeId.ocean:
      _ocean(c, s, t);
    case ThemeId.volcano:
      _volcano(c, s, t);
  }
}

void _ocean(Canvas c, Size s, double t) {
  for (var i = 0; i < 4; i++) {
    final x = s.width * (0.1 + 0.25 * i);
    final path = Path()
      ..moveTo(x - 30, 0)
      ..lineTo(x + 30, 0)
      ..lineTo(x + 90 + 20 * math.sin(t * 0.4 + i), s.height * 0.8)
      ..lineTo(x - 50, s.height * 0.8)
      ..close();
    c.drawPath(path, _p(const Color(0x12FFFFFF)));
  }
  for (var i = 0; i < 5; i++) {
    final x = s.width * (0.05 + 0.22 * i);
    final h = s.height * (0.12 + 0.08 * _rnd(i));
    final base = s.height * 0.8;
    final sway = math.sin(t * 1.2 + i) * 8;
    final weed = Path()..moveTo(x, base);
    weed.quadraticBezierTo(x + sway, base - h * 0.5, x + sway * 1.5, base - h);
    c.drawPath(
      weed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x6600B894),
    );
  }
  for (var i = 0; i < 3; i++) {
    final x =
        ((_rnd(i, 3) * s.width * 1.5 + t * (18 + i * 8)) % (s.width * 1.5)) -
        s.width * 0.25;
    final y = s.height * (0.2 + 0.18 * i);
    final fish = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x + 14, y - 9, x + 28, y)
      ..quadraticBezierTo(x + 14, y + 9, x, y)
      ..moveTo(x, y)
      ..lineTo(x - 9, y - 7)
      ..lineTo(x - 9, y + 7)
      ..close();
    c.drawPath(fish, _p(const Color(0x88FFB703)));
  }
  for (var i = 0; i < 26; i++) {
    final x = _rnd(i) * s.width + math.sin(t + i) * 6;
    final y =
        s.height -
        ((_rnd(i, 4) * s.height + t * (14 + 12 * _rnd(i, 6))) % s.height);
    c.drawCircle(
      Offset(x, y),
      2 + 4 * _rnd(i, 8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x88FFFFFF),
    );
  }
}

void _volcano(Canvas c, Size s, double t) {
  final cone = Path()
    ..moveTo(s.width * 0.05, s.height * 0.8)
    ..lineTo(s.width * 0.38, s.height * 0.3)
    ..lineTo(s.width * 0.5, s.height * 0.3)
    ..lineTo(s.width * 0.85, s.height * 0.8)
    ..close();
  c.drawPath(cone, _p(const Color(0xFF2A0F10)));
  final glow = 0.5 + 0.5 * math.sin(t * 2);
  c.drawCircle(
    Offset(s.width * 0.44, s.height * 0.3),
    s.width * (0.16 + 0.02 * glow),
    _p(const Color(0x33FF8A00)),
  );
  c.drawOval(
    Rect.fromCenter(
      center: Offset(s.width * 0.44, s.height * 0.3),
      width: s.width * 0.16,
      height: s.height * 0.025,
    ),
    _p(const Color(0xFFFFB703)),
  );
  final lava = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xCCFF5A1F);
  c.drawLine(
    Offset(s.width * 0.42, s.height * 0.31),
    Offset(s.width * 0.3, s.height * 0.6),
    lava,
  );
  c.drawLine(
    Offset(s.width * 0.47, s.height * 0.31),
    Offset(s.width * 0.62, s.height * 0.66),
    lava,
  );
  for (var i = 0; i < 5; i++) {
    final x =
        s.width * 0.44 + math.sin(t * 0.3 + i * 2) * s.width * 0.1 + i * 8;
    final y = s.height * 0.28 - ((t * 25 + i * 70) % (s.height * 0.28));
    c.drawCircle(Offset(x, y), 14 + i * 4, _p(Color.fromARGB(40, 90, 70, 70)));
  }
  for (var i = 0; i < 28; i++) {
    final x = _rnd(i) * s.width;
    final y =
        s.height -
        ((_rnd(i, 4) * s.height + t * (20 + 30 * _rnd(i, 6))) % s.height);
    c.drawCircle(
      Offset(x + math.sin(t * 2 + i) * 6, y),
      1.2 + 2 * _rnd(i, 8),
      _p(Color.fromARGB(200, 255, 140 + (i * 7) % 80, 40)),
    );
  }
}

void _garden(Canvas c, Size s, double t) {
  final sun = Offset(s.width * 0.82, s.height * 0.12);
  c.drawCircle(sun, s.width * 0.2, _p(const Color(0x33FFF3B0)));
  c.drawCircle(sun, s.width * 0.13, _p(const Color(0x66FFF3B0)));
  c.drawCircle(sun, s.width * 0.085, _p(const Color(0xFFFFE066)));
  for (var i = 0; i < 4; i++) {
    final speed = 6 + i * 3.0;
    final x =
        ((_rnd(i) * s.width * 1.4 + t * speed) % (s.width * 1.4)) -
        s.width * 0.2;
    final y = s.height * (0.08 + 0.12 * i + 0.04 * _rnd(i, 3));
    _cloud(
      c,
      Offset(x, y),
      s.width * (0.05 + 0.02 * _rnd(i, 5)),
      const Color(0xCCFFFFFF),
    );
  }
  for (var layer = 0; layer < 2; layer++) {
    final base = s.height * (0.72 - layer * 0.04);
    final path = Path()..moveTo(0, s.height);
    for (var x = 0.0; x <= s.width; x += 8) {
      final y =
          base -
          math.sin(x / s.width * math.pi * (2 + layer) + layer) *
              s.height *
              0.035;
      path.lineTo(x, y);
    }
    path.lineTo(s.width, s.height);
    c.drawPath(
      path,
      _p(layer == 0 ? const Color(0xFF9BDB7C) : const Color(0xFF7CC55C)),
    );
  }
}

void _workshop(Canvas c, Size s, double t) {
  final dot = _p(const Color(0x22A0622B));
  for (var y = s.height * 0.05; y < s.height; y += s.width * 0.1) {
    for (var x = s.width * 0.05; x < s.width; x += s.width * 0.1) {
      c.drawCircle(Offset(x, y), 3, dot);
    }
  }
  final shelf = Paint()
    ..color = const Color(0x558D5A2B)
    ..strokeWidth = 8;
  c.drawLine(Offset(0, s.height * 0.3), Offset(s.width, s.height * 0.3), shelf);
  c.drawLine(
    Offset(0, s.height * 0.62),
    Offset(s.width, s.height * 0.62),
    shelf,
  );
  _gear(
    c,
    Offset(s.width * 0.88, s.height * 0.2),
    s.width * 0.12,
    10,
    t * 0.3,
    const Color(0x55E0A45E),
  );
  _gear(
    c,
    Offset(s.width * 0.1, s.height * 0.47),
    s.width * 0.09,
    8,
    -t * 0.4,
    const Color(0x55D9803A),
  );
  _gear(
    c,
    Offset(s.width * 0.8, s.height * 0.55),
    s.width * 0.07,
    7,
    t * 0.5,
    const Color(0x55C48A52),
  );
  c.drawCircle(
    Offset(s.width * 0.5, 0),
    s.width * 0.5,
    _p(const Color(0x22FFE9A8)),
  );
  c.drawLine(
    Offset(s.width * 0.5, 0),
    Offset(s.width * 0.5, s.height * 0.05),
    Paint()
      ..strokeWidth = 3
      ..color = const Color(0xFF8D5A2B),
  );
  c.drawCircle(
    Offset(s.width * 0.5, s.height * 0.06),
    s.width * 0.03,
    _p(const Color(0xFFFFE066)),
  );
}

void _construction(Canvas c, Size s, double t) {
  final steel = _p(const Color(0x446E6E78));
  for (var i = 0; i < 4; i++) {
    final x = s.width * (0.05 + i * 0.26);
    final h = s.height * (0.3 + 0.12 * _rnd(i));
    c.drawRect(Rect.fromLTWH(x, s.height * 0.78 - h, s.width * 0.2, h), steel);
    for (var f = 1; f < 5; f++) {
      c.drawLine(
        Offset(x, s.height * 0.78 - h * f / 5),
        Offset(x + s.width * 0.2, s.height * 0.78 - h * f / 5),
        Paint()
          ..color = const Color(0x556E6E78)
          ..strokeWidth = 3,
      );
    }
  }
  final crane = Paint()
    ..color = const Color(0xAAFFD60A)
    ..strokeWidth = 5;
  final cx = s.width * 0.82;
  c.drawLine(Offset(cx, s.height * 0.78), Offset(cx, s.height * 0.12), crane);
  final sway = math.sin(t * 0.5) * 6;
  c.drawLine(
    Offset(cx - s.width * 0.5, s.height * 0.12),
    Offset(cx + s.width * 0.1, s.height * 0.12),
    crane,
  );
  c.drawLine(
    Offset(cx - s.width * 0.45, s.height * 0.12),
    Offset(cx - s.width * 0.45 + sway, s.height * 0.2),
    Paint()
      ..color = const Color(0xAA2B2B33)
      ..strokeWidth = 2,
  );
  c.drawRect(
    Rect.fromCenter(
      center: Offset(cx - s.width * 0.45 + sway, s.height * 0.21),
      width: 22,
      height: 16,
    ),
    _p(const Color(0xAAFF5A36)),
  );
  final pipe = Paint()
    ..color = const Color(0x667E7E88)
    ..strokeWidth = 14;
  c.drawLine(
    Offset(0, s.height * 0.5),
    Offset(s.width * 0.35, s.height * 0.5),
    pipe,
  );
  c.drawLine(
    Offset(s.width * 0.35, s.height * 0.5),
    Offset(s.width * 0.35, s.height * 0.4),
    pipe,
  );
}

void _neon(Canvas c, Size s, double t) {
  final moon = Offset(s.width * 0.75, s.height * 0.14);
  c.drawCircle(moon, s.width * 0.14, _p(const Color(0x22FF8AD8)));
  c.drawCircle(moon, s.width * 0.08, _p(const Color(0xFFFFD6F6)));
  for (var i = 0; i < 9; i++) {
    final w = s.width * (0.09 + 0.05 * _rnd(i));
    final h = s.height * (0.18 + 0.25 * _rnd(i, 2));
    final x = i * s.width * 0.115;
    c.drawRect(
      Rect.fromLTWH(x, s.height * 0.8 - h, w, h),
      _p(const Color(0xFF0E0A33)),
    );
    for (var wy = 0; wy < h / 22; wy++) {
      if (_rnd(i * 31 + wy, 7) > 0.55) {
        c.drawRect(
          Rect.fromLTWH(
            x + 6 + (wy % 2) * w * 0.4,
            s.height * 0.8 - h + 8 + wy * 22,
            6,
            8,
          ),
          _p(const Color(0xAA00E5FF)),
        );
      }
    }
  }
  final grid = Paint()
    ..color = const Color(0x2200F5D4)
    ..strokeWidth = 1.5;
  for (var i = 0; i <= 8; i++) {
    c.drawLine(
      Offset(s.width * i / 8, s.height * 0.8),
      Offset(s.width * (i - 4) / 2 + s.width / 2, s.height),
      grid,
    );
  }
  for (var i = 0; i < 24; i++) {
    final x = _rnd(i) * s.width;
    final y = (_rnd(i, 4) * s.height - t * (6 + i % 5 * 3)) % s.height;
    c.drawCircle(
      Offset(x, y),
      1.5 + _rnd(i, 9) * 1.5,
      _p(Color.fromARGB(150, 255, 46, 147)),
    );
  }
}

void _space(Canvas c, Size s, double t) {
  for (var i = 0; i < 70; i++) {
    final tw = 0.5 + 0.5 * math.sin(t * (1 + _rnd(i, 2) * 2) + i);
    c.drawCircle(
      Offset(_rnd(i) * s.width, _rnd(i, 1) * s.height),
      0.6 + _rnd(i, 3) * 1.4,
      _p(Color.fromARGB((80 + 150 * tw).round(), 255, 255, 255)),
    );
  }
  c.drawCircle(
    Offset(s.width * 0.2, s.height * 0.2),
    s.width * 0.3,
    _p(const Color(0x1A7B2CBF)),
  );
  final planet = Offset(s.width * 0.8, s.height * 0.22);
  c.drawCircle(planet, s.width * 0.13, _p(const Color(0xFF3A2F7A)));
  c.drawCircle(
    planet + Offset(-s.width * 0.03, -s.width * 0.03),
    s.width * 0.09,
    _p(const Color(0xFF5A4BB0)),
  );
  c.save();
  c.translate(planet.dx, planet.dy);
  c.rotate(-0.4);
  c.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: s.width * 0.42,
      height: s.width * 0.1,
    ),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0x884CC9F0),
  );
  c.restore();
  final strut = Paint()
    ..color = const Color(0x334CC9F0)
    ..strokeWidth = 3;
  c.drawLine(
    Offset(0, s.height * 0.4),
    Offset(s.width * 0.3, s.height * 0.46),
    strut,
  );
  c.drawLine(
    Offset(s.width, s.height * 0.62),
    Offset(s.width * 0.7, s.height * 0.68),
    strut,
  );
  final drift = (t * 14) % (s.width + 60);
  c.drawCircle(
    Offset(drift - 30, s.height * 0.35),
    3,
    _p(const Color(0xAA80FFDB)),
  );
}

/// Ground slab drawn in screen space below [topY] (screen y of kGroundY).
void paintGround(
  Canvas c,
  Size s,
  double topY,
  double scale,
  LevelTheme t,
  double time,
) {
  final rect = Rect.fromLTRB(0, topY, s.width, s.height);
  c.drawRect(rect, _p(t.ground));
  c.drawRect(Rect.fromLTWH(0, topY, s.width, scale * 0.28), _p(t.groundTop));
  switch (t.id) {
    case ThemeId.garden:
      for (var i = 0; i < 16; i++) {
        final x = _rnd(i, 11) * s.width;
        final stem = Paint()
          ..color = const Color(0xFF3F8F2A)
          ..strokeWidth = 2;
        c.drawLine(Offset(x, topY), Offset(x, topY - scale * 0.22), stem);
        c.drawCircle(
          Offset(x, topY - scale * 0.26),
          scale * 0.07,
          _p(
            i % 3 == 0
                ? const Color(0xFFFF8FAB)
                : i % 3 == 1
                ? const Color(0xFFFFE066)
                : const Color(0xFFFFFFFF),
          ),
        );
      }
    case ThemeId.workshop:
      final plank = Paint()
        ..color = const Color(0x44000000)
        ..strokeWidth = 2;
      for (var x = 0.0; x < s.width; x += scale * 1.4) {
        c.drawLine(Offset(x, topY + scale * 0.28), Offset(x, s.height), plank);
      }
    case ThemeId.construction:
      final stripe = _p(const Color(0xFFFFD60A));
      for (var x = -scale; x < s.width; x += scale * 1.2) {
        c.drawPath(
          Path()
            ..moveTo(x, topY + scale * 0.28)
            ..lineTo(x + scale * 0.35, topY + scale * 0.28)
            ..lineTo(x + scale * 0.7, topY + scale * 0.6)
            ..lineTo(x + scale * 0.35, topY + scale * 0.6)
            ..close(),
          stripe,
        );
      }
    case ThemeId.neon:
      final line = Paint()
        ..color = const Color(0x6600F5D4)
        ..strokeWidth = 8;
      c.drawLine(Offset(0, topY + 2), Offset(s.width, topY + 2), line);
      c.drawLine(
        Offset(0, topY + 2),
        Offset(s.width, topY + 2),
        Paint()
          ..color = t.accent
          ..strokeWidth = 3,
      );
    case ThemeId.space:
      c.drawLine(
        Offset(0, topY + 2),
        Offset(s.width, topY + 2),
        Paint()
          ..color = t.accent
          ..strokeWidth = 3,
      );
      for (var i = 0; i < 6; i++) {
        c.drawCircle(
          Offset(s.width * (i + 0.5) / 6, topY + scale * 0.8),
          4,
          _p(i % 2 == 0 ? t.accent : const Color(0xFFFFB703)),
        );
      }
    case ThemeId.ocean:
      for (var i = 0; i < 9; i++) {
        final x = _rnd(i, 21) * s.width;
        c.drawCircle(
          Offset(x, topY + scale * (0.5 + 0.5 * _rnd(i, 22))),
          scale * 0.06,
          _p(const Color(0x55FFFFFF)),
        );
      }
      for (var i = 0; i < 4; i++) {
        final x = s.width * (0.12 + 0.25 * i);
        c.drawArc(
          Rect.fromCenter(
            center: Offset(x, topY + 2),
            width: scale * 0.6,
            height: scale * 0.5,
          ),
          math.pi,
          math.pi,
          true,
          _p(const Color(0xFFFF8FAB)),
        );
      }
    case ThemeId.volcano:
      final glow = 0.5 + 0.5 * math.sin(time * 3);
      c.drawRect(
        Rect.fromLTWH(0, topY - 3, s.width, 12),
        _p(Color.fromARGB((70 + 60 * glow).round(), 255, 120, 20)),
      );
      c.drawLine(
        Offset(0, topY + 2),
        Offset(s.width, topY + 2),
        Paint()
          ..color = t.accent
          ..strokeWidth = 4,
      );
      for (var i = 0; i < 6; i++) {
        final x = s.width * (i + 0.5) / 6;
        c.drawLine(
          Offset(x - scale * 0.4, topY + scale * 0.9),
          Offset(x + scale * 0.4, topY + scale * 0.5),
          Paint()
            ..color = const Color(0xAAFF5A1F)
            ..strokeWidth = 3,
        );
      }
  }
}
