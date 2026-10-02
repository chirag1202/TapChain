import 'dart:ui';

import '../level_config.dart';

const workshopTheme = LevelTheme(
  id: ThemeId.workshop,
  name: 'Toy Workshop',
  emoji: '🧸',
  skyTop: Color(0xFFFFD9A0),
  skyBottom: Color(0xFFFFF1D6),
  ground: Color(0xFF9C6B3C),
  groundTop: Color(0xFFC48A52),
  platform: Color(0xFFE0A45E),
  platformEdge: Color(0xFF8D5A2B),
  domino: Color(0xFF3FA7D6),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFFE94F4F),
  box: Color(0xFF7BC96F),
  boxEdge: Color(0xFF3F8F3A),
  target: Color(0xFF9B5DE5),
  accent: Color(0xFFFFC53D),
);

final level2 = LevelConfig(
  id: 2,
  name: 'The Drop',
  hint: 'Dominoes nudge the ball.',
  theme: workshopTheme,
  baseReward: 75,
  objects: [
    ObjectSpec.platform(2.3, 6.0, 3.8),
    ...ObjectSpec.dominoRow(
      fromX: 0.8,
      surfaceY: 6.0,
      count: 5,
      spacing: 0.6,
      firstIsStarter: true,
    ),
    ObjectSpec.ball(3.8, 6.0),
    ObjectSpec.platform(6.4, 9.5, 4.8),
    ...ObjectSpec.dominoRow(fromX: 5.6, surfaceY: 9.5, count: 4, spacing: 0.6),
    ObjectSpec.target(8.3, 9.5, radius: 0.5),
  ],
);
