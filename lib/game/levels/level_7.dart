import 'dart:ui';

import '../level_config.dart';

const volcanoTheme = LevelTheme(
  id: ThemeId.volcano,
  name: 'Volcano Lair',
  emoji: '🌋',
  skyTop: Color(0xFF1A0505),
  skyBottom: Color(0xFF7A1E0E),
  ground: Color(0xFF2B1210),
  groundTop: Color(0xFF5A2A20),
  platform: Color(0xFF3B1F1C),
  platformEdge: Color(0xFF1A0A09),
  domino: Color(0xFFFFE08A),
  dominoDot: Color(0xFF7A1E0E),
  ball: Color(0xFFFF7A1A),
  box: Color(0xFF5E5E6E),
  boxEdge: Color(0xFF9A9AAE),
  target: Color(0xFF4DF0FF),
  accent: Color(0xFFFF8A00),
  glow: true,
);

// Mirror image of the Space Station layout with a lava-lit twist.
final level7 = LevelConfig(
  id: 7,
  name: 'Lava Rush',
  hint: 'One tap, seven stages.',
  theme: volcanoTheme,
  baseReward: 300,
  objects: [
    ObjectSpec.platform(7.05, 3.8, 3.3),
    ObjectSpec.domino(8.2, 3.8, starter: true, push: const Offset(-0.35, 0)),
    ObjectSpec.domino(7.6, 3.8),
    ObjectSpec.domino(7.0, 3.8),
    ObjectSpec.domino(6.4, 3.8),
    ObjectSpec.ball(5.8, 3.8),
    ObjectSpec.platform(3.5, 6.6, 5.0),
    ObjectSpec.domino(4.0, 6.6),
    ObjectSpec.domino(3.4, 6.6),
    ObjectSpec.domino(2.8, 6.6),
    ObjectSpec.domino(2.2, 6.6),
    ObjectSpec.ball(1.6, 6.6),
    ObjectSpec.platform(2.4, 9.6, 4.8, angle: 0.25),
    ObjectSpec.platform(5.1, 10.9, 1.4),
    ObjectSpec.box(5.79, 10.9),
    ObjectSpec.domino(7.5, kGroundY),
    ObjectSpec.domino(6.9, kGroundY),
    ObjectSpec.domino(6.3, kGroundY),
    ObjectSpec.target(8.35, kGroundY, radius: 0.5),
  ],
);
