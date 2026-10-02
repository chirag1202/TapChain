import 'dart:ui';

import '../level_config.dart';

const oceanTheme = LevelTheme(
  id: ThemeId.ocean,
  name: 'Deep Ocean',
  emoji: '🌊',
  skyTop: Color(0xFF48CAE4),
  skyBottom: Color(0xFF0A3D62),
  ground: Color(0xFFD9B26F),
  groundTop: Color(0xFFF4D58D),
  platform: Color(0xFF2A9D8F),
  platformEdge: Color(0xFF14645C),
  domino: Color(0xFFFF8FAB),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFFFFD60A),
  box: Color(0xFF9B5DE5),
  boxEdge: Color(0xFF5E2CA5),
  target: Color(0xFFFF4D6D),
  accent: Color(0xFF7FFFD4),
);

// Marble run: the starter ball rolls down reef ramps into a domino row.
final level6 = LevelConfig(
  id: 6,
  name: 'Deep Dive',
  hint: 'Let the pearl roll.',
  theme: oceanTheme,
  baseReward: 250,
  objects: [
    ObjectSpec.platform(1.7, 3.8, 2.8),
    ObjectSpec.ball(1.0, 3.8, starter: true, push: const Offset(0.9, 0)),
    ObjectSpec.platform(5.2, 6.0, 4.2, angle: 0.22),
    ObjectSpec.platform(6.0, 9.2, 5.6, angle: -0.2),
    ObjectSpec.platform(2.1, 11.5, 3.6),
    ...ObjectSpec.dominoRow(fromX: 1.4, surfaceY: 11.5, count: 2, spacing: 0.6),
    ObjectSpec.target(0.6, 11.5, radius: 0.45),
    ObjectSpec.box(8.0, kGroundY),
  ],
);
