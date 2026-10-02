import 'dart:ui';

import '../level_config.dart';

const neonTheme = LevelTheme(
  id: ThemeId.neon,
  name: 'Neon Night',
  emoji: '🌃',
  skyTop: Color(0xFF07072B),
  skyBottom: Color(0xFF3A0CA3),
  ground: Color(0xFF14143F),
  groundTop: Color(0xFF00F5D4),
  platform: Color(0xFF12123A),
  platformEdge: Color(0xFF00F5D4),
  domino: Color(0xFFFF2E93),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFF00E5FF),
  box: Color(0xFFB5179E),
  boxEdge: Color(0xFFF72585),
  target: Color(0xFFFFEE32),
  accent: Color(0xFF00F5D4),
  glow: true,
);

// Only the top-right row is triggered; the rest are decoys.
final level4 = LevelConfig(
  id: 4,
  name: 'The Trick',
  hint: 'Decoys everywhere. Follow the real path.',
  theme: neonTheme,
  baseReward: 125,
  objects: [
    ...ObjectSpec.dominoRow(
      fromX: 5.0,
      surfaceY: kGroundY,
      count: 3,
      spacing: 0.6,
    ),
    ObjectSpec.domino(8.0, kGroundY),
    ObjectSpec.domino(8.6, kGroundY),
    ObjectSpec.platform(1.4, 11.0, 2.2),
    ObjectSpec.ball(1.4, 11.0),
    ObjectSpec.box(3.8, kGroundY, w: 0.9, h: 1.3),
    ObjectSpec.platform(3.1, 8.0, 5.6),
    ...ObjectSpec.dominoRow(fromX: 1.8, surfaceY: 8.0, count: 3, spacing: 0.6),
    ObjectSpec.target(0.9, 8.0, radius: 0.5),
    ObjectSpec.platform(7.05, 4.6, 3.3),
    ObjectSpec.domino(8.0, 4.6, starter: true, push: const Offset(-0.35, 0)),
    ObjectSpec.domino(7.4, 4.6),
    ObjectSpec.domino(6.8, 4.6),
    ObjectSpec.ball(6.0, 4.6),
  ],
);
