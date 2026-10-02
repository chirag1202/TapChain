import 'dart:ui';

import '../level_config.dart';

const constructionTheme = LevelTheme(
  id: ThemeId.construction,
  name: 'Construction Site',
  emoji: '🚧',
  skyTop: Color(0xFFFFA94D),
  skyBottom: Color(0xFFFFE8A3),
  ground: Color(0xFF6E6E78),
  groundTop: Color(0xFF8D8D97),
  platform: Color(0xFF4A4A55),
  platformEdge: Color(0xFF2B2B33),
  domino: Color(0xFFFFD60A),
  dominoDot: Color(0xFF2B2B33),
  ball: Color(0xFF3D9BFF),
  box: Color(0xFFC9904A),
  boxEdge: Color(0xFF8A5A2B),
  target: Color(0xFFFF5A36),
  accent: Color(0xFFFFD60A),
);

final level3 = LevelConfig(
  id: 3,
  name: 'Heavy Impact',
  hint: 'Drop from one platform to the next.',
  theme: constructionTheme,
  baseReward: 100,
  objects: [
    ObjectSpec.platform(2.8, 8.4, 5.4),
    ObjectSpec.box(0.85, 8.4, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.7, surfaceY: 8.4, count: 4),
    ObjectSpec.ball(4.35, 8.4),
    ObjectSpec.platform(6.4, 11.1, 5.2),
    ...ObjectSpec.dominoRow(fromX: 4.7, surfaceY: 11.1, count: 5, spacing: 0.5),
    ObjectSpec.ball(7.5, 11.1),
    ObjectSpec.target(8.5, 11.1, radius: 0.48),
  ],
);
