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

// A full row of floor dominoes tips directly into the target.
final level5 = LevelConfig(
  id: 5,
  name: 'Chain Master',
  hint: 'Read the whole chain before you tap.',
  theme: spaceTheme,
  baseReward: 200,
  objects: [
    ...ObjectSpec.dominoRow(
      fromX: 1.3,
      surfaceY: kGroundY,
      count: 8,
      spacing: 0.6,
      firstIsStarter: true,
      push: const Offset(0.55, 0),
    ),
    ObjectSpec.target(6.8, kGroundY, radius: 0.5),
  ],
);
