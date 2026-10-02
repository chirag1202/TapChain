// Renders the launcher icon PNGs. Run: flutter test tool/icon_gen_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _s = 1024;

void _background(Canvas c) {
  final rect = const Rect.fromLTWH(0, 0, _s, _s);
  c.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(_s, _s),
        const [Color(0xFF3A5BFF), Color(0xFF8E3DFF), Color(0xFFFF5FA2)],
        const [0, 0.55, 1],
      ),
  );
  c.drawCircle(
    const Offset(_s / 2, _s * 0.46),
    _s * 0.62,
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(_s / 2, _s * 0.46),
        _s * 0.62,
        const [Color(0x55FFFFFF), Color(0x00FFFFFF)],
      ),
  );
  final ray = Paint()..color = const Color(0x14FFFFFF);
  for (var i = 0; i < 12; i++) {
    final a = i * math.pi / 6;
    final p = Path()
      ..moveTo(_s / 2, _s * 0.46)
      ..lineTo(
        _s / 2 + math.cos(a - 0.1) * _s,
        _s * 0.46 + math.sin(a - 0.1) * _s,
      )
      ..lineTo(
        _s / 2 + math.cos(a + 0.1) * _s,
        _s * 0.46 + math.sin(a + 0.1) * _s,
      )
      ..close();
    c.drawPath(p, ray);
  }
}

void _star(Canvas c, Offset o, double r, double alpha) {
  final p = Path();
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4 - math.pi / 2;
    final rr = i.isEven ? r : r * 0.28;
    final pt = o + Offset(math.cos(a), math.sin(a)) * rr;
    i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
  }
  p.close();
  c.drawPath(p, Paint()..color = Colors.white.withValues(alpha: alpha));
}

void _domino(
  Canvas c,
  double pivotX,
  double pivotY,
  double angle,
  Color color,
) {
  const w = 104.0;
  const h = 292.0;
  c.save();
  c.translate(pivotX, pivotY);
  c.rotate(angle);
  final r = RRect.fromRectAndRadius(
    const Rect.fromLTWH(-w, -h, w, h),
    const Radius.circular(26),
  );
  c.drawRRect(
    r.shift(const Offset(8, 10)),
    Paint()..color = const Color(0x44000000),
  );
  c.drawRRect(
    r,
    Paint()
      ..shader = ui.Gradient.linear(const Offset(-w, -h), const Offset(0, 0), [
        Color.lerp(color, Colors.white, 0.35)!,
        color,
      ]),
  );
  c.drawRRect(
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0xFF1B1F5E),
  );
  c.drawLine(
    const Offset(-w + 18, -h / 2),
    const Offset(-18, -h / 2),
    Paint()
      ..strokeWidth = 8
      ..color = const Color(0xAA1B1F5E),
  );
  final pip = Paint()..color = Colors.white;
  for (final dy in [-h * 0.8, -h * 0.65, -h * 0.35, -h * 0.2]) {
    c.drawCircle(Offset(-w / 2, dy), 11, pip);
  }
  c.restore();
}

void _foreground(Canvas c) {
  const floorY = 735.0;
  c.drawOval(
    Rect.fromCenter(
      center: const Offset(_s / 2, floorY + 62),
      width: 840,
      height: 54,
    ),
    Paint()..color = const Color(0x33000000),
  );
  final plat = RRect.fromRectAndRadius(
    const Rect.fromLTWH(84, floorY, 856, 54),
    const Radius.circular(27),
  );
  c.drawRRect(plat, Paint()..color = const Color(0xFF1B1F5E));
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(96, floorY + 6, 832, 16),
      const Radius.circular(8),
    ),
    Paint()..color = const Color(0x55FFFFFF),
  );

  const colors = [
    Color(0xFFFF5C6C),
    Color(0xFFFFC93C),
    Color(0xFF38D6E8),
    Color(0xFF7BE86B),
  ];
  const angles = [0.0, 0.16, 0.4, 0.74];
  for (var i = 0; i < 4; i++) {
    _domino(c, 232 + i * 150.0, floorY, angles[i], colors[i]);
  }

  const bc = Offset(846, floorY - 104);
  for (var i = 0; i < 3; i++) {
    c.drawLine(
      Offset(bc.dx + 120 + i * 0, bc.dy - 40 + i * 40),
      Offset(bc.dx + 190, bc.dy - 40 + i * 40),
      Paint()
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x88FFFFFF),
    );
  }
  c.drawCircle(
    bc + const Offset(8, 10),
    104,
    Paint()..color = const Color(0x44000000),
  );
  c.drawCircle(
    bc,
    104,
    Paint()
      ..shader = ui.Gradient.radial(
        bc + const Offset(-34, -40),
        150,
        const [Color(0xFFFFF3A0), Color(0xFFFFB703), Color(0xFFFF7A1A)],
        const [0, 0.55, 1],
      ),
  );
  c.drawCircle(
    bc,
    104,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0xFF1B1F5E),
  );
  c.drawCircle(
    bc + const Offset(-36, -42),
    22,
    Paint()..color = Colors.white.withValues(alpha: 0.9),
  );

  _star(c, const Offset(840, 250), 72, 0.95);
  _star(c, const Offset(180, 260), 46, 0.8);
  _star(c, const Offset(930, 440), 34, 0.7);
  _star(c, const Offset(120, 520), 28, 0.6);
}

Future<void> _save(String path, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(_s.toInt(), _s.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(Uint8List.view(data!.buffer));
}

void main() {
  testWidgets('render launcher icons', (tester) async {
    await tester.runAsync(() async {
      await _save('assets/icon/icon.png', (c) {
        _background(c);
        _foreground(c);
      });
      await _save('assets/icon/icon_bg.png', _background);
      // Adaptive icons crop to the centre; keep the art inside the safe zone.
      await _save('assets/icon/icon_fg.png', (c) {
        c.translate(_s / 2, _s / 2);
        c.scale(0.66);
        c.translate(-_s / 2, -_s / 2 + 20);
        _foreground(c);
      });
    });
  });
}
