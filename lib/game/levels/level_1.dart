import 'dart:ui';

import '../level_config.dart';

const gardenTheme = LevelTheme(
  id: ThemeId.garden,
  name: 'Sunny Garden',
  emoji: '🌱',
  skyTop: Color(0xFF5BB8F5),
  skyBottom: Color(0xFFDDF5FF),
  ground: Color(0xFF8A5A2B),
  groundTop: Color(0xFF5DBB3B),
  platform: Color(0xFFB9824A),
  platformEdge: Color(0xFF7C4F25),
  domino: Color(0xFFFF6B6B),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFFFFC53D),
  box: Color(0xFFC98B4E),
  boxEdge: Color(0xFF8A5A2B),
  target: Color(0xFFE63946),
  accent: Color(0xFFFFE066),
);

final level1 = LevelConfig(
  id: 1,
  name: 'First Fall',
  hint: 'One tap, one chain.',
  theme: gardenTheme,
  baseReward: 50,
  objects: [
    ...ObjectSpec.dominoRow(
      fromX: 1.3,
      surfaceY: kGroundY,
      count: 10,
      spacing: 0.6,
      firstIsStarter: true,
    ),
    ObjectSpec.target(7.9, kGroundY),
  ],
);
