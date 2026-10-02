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
  hint: 'Crates hit hard.',
  theme: constructionTheme,
  baseReward: 100,
  objects: [
    ObjectSpec.platform(3.1, 5.0, 5.6),
    ObjectSpec.box(1.3, 5.0, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(
      fromX: 2.2,
      surfaceY: 5.0,
      count: 4,
      spacing: 0.75,
      h: 1.3,
    ),
    ObjectSpec.ball(5.8, 5.0),
    ObjectSpec.platform(6.45, 8.5, 5.0, angle: -0.2),
    ObjectSpec.platform(1.9, 11.2, 3.2),
    ...ObjectSpec.dominoRow(fromX: 1.2, surfaceY: 11.2, count: 2, spacing: 0.6),
    ObjectSpec.target(0.5, 11.2, radius: 0.45),
  ],
);
