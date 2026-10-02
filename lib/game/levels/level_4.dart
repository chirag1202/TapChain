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

// A side-to-side chain drops from the upper row onto a lower target lane.
final level4 = LevelConfig(
  id: 4,
  name: 'The Relay',
  hint: 'Follow the ball down to the lower row.',
  theme: neonTheme,
  baseReward: 125,
  objects: [
    ObjectSpec.platform(6.3, 7.4, 5.2),
    ObjectSpec.domino(8.2, 7.4, starter: true, push: const Offset(-0.35, 0)),
    ...ObjectSpec.dominoRow(fromX: 7.6, surfaceY: 7.4, count: 4, spacing: -0.6),
    ObjectSpec.ball(5.0, 7.4),
    ObjectSpec.platform(2.5, 10.3, 6.0),
    ...ObjectSpec.dominoRow(
      fromX: 4.8,
      surfaceY: 10.3,
      count: 6,
      spacing: -0.6,
    ),
    ObjectSpec.target(0.9, 10.3, radius: 0.48),
  ],
);
