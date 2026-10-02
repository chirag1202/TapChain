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

// Two ball drops feed three connected domino runs down to the target.
final level6 = LevelConfig(
  id: 6,
  name: 'Deep Dive',
  hint: 'Start midway and follow both drops.',
  theme: oceanTheme,
  baseReward: 250,
  objects: [
    ObjectSpec.platform(2.7, 8.0, 5.0),
    ObjectSpec.domino(0.95, 8.0, starter: true, push: const Offset(0.35, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.55, surfaceY: 8.0, count: 4),
    ObjectSpec.ball(4.15, 8.0),
    ObjectSpec.platform(6.0, 10.7, 4.4),
    ...ObjectSpec.dominoRow(
      fromX: 4.4,
      surfaceY: 10.7,
      count: 5,
      spacing: 0.58,
    ),
    ObjectSpec.ball(7.4, 10.7),
    ...ObjectSpec.dominoRow(
      fromX: 5.2,
      surfaceY: kGroundY,
      count: 5,
      spacing: 0.6,
    ),
    ObjectSpec.target(8.35, kGroundY, radius: 0.48),
  ],
);
