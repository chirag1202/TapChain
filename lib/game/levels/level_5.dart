import 'dart:ui';

import '../level_config.dart';

const spaceTheme = LevelTheme(
  id: ThemeId.space,
  name: 'Space Station',
  emoji: '🚀',
  skyTop: Color(0xFF02030F),
  skyBottom: Color(0xFF1B1F4B),
  ground: Color(0xFF2B3350),
  groundTop: Color(0xFF4CC9F0),
  platform: Color(0xFF8D99AE),
  platformEdge: Color(0xFF4A5470),
  domino: Color(0xFFEDF2F4),
  dominoDot: Color(0xFF4CC9F0),
  ball: Color(0xFFFFB703),
  box: Color(0xFF7B2CBF),
  boxEdge: Color(0xFFC77DFF),
  target: Color(0xFF80FFDB),
  accent: Color(0xFF4CC9F0),
  glow: true,
);

// Starts halfway up, then chains through two drops and a downhill ramp.
final level5 = LevelConfig(
  id: 5,
  name: 'Chain Master',
  hint: 'Read the whole chain before you tap.',
  theme: spaceTheme,
  baseReward: 200,
  objects: [
    ObjectSpec.platform(1.95, 6.0, 3.3),
    ...ObjectSpec.dominoRow(
      fromX: 0.8,
      surfaceY: 6.0,
      count: 4,
      spacing: 0.6,
      firstIsStarter: true,
    ),
    ObjectSpec.ball(3.2, 6.0),
    ObjectSpec.platform(5.0, 8.8, 4.2),
    ...ObjectSpec.dominoRow(fromX: 3.5, surfaceY: 8.8, count: 4, spacing: 0.6),
    ObjectSpec.ball(6.0, 8.8),
    ObjectSpec.platform(6.6, 11.1, 4.8, angle: -0.25),
    ObjectSpec.platform(3.9, 12.3, 1.4),
    ObjectSpec.box(3.21, 12.3),
    ...ObjectSpec.dominoRow(
      fromX: 1.5,
      surfaceY: kGroundY,
      count: 3,
      spacing: 0.6,
    ),
    ObjectSpec.target(0.65, kGroundY, radius: 0.5),
  ],
);
