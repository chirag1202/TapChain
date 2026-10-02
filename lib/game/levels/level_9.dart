import 'dart:ui';

import '../level_config.dart';
import 'level_4.dart';

// A ground chain powers a spring that throws the ball onto a high switchback.
final level9 = LevelConfig(
  id: 9,
  name: 'Springboard',
  hint: 'Start below and bounce up to the slope.',
  theme: neonTheme,
  baseReward: 400,
  objects: [
    ObjectSpec.box(0.85, kGroundY, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.6, surfaceY: kGroundY, count: 4),
    ObjectSpec.ball(4.05, kGroundY),
    ObjectSpec.jumper(4.9, kGroundY, w: 1.1),
    ObjectSpec.platform(4.9, 7.2, 4.6),
    ...ObjectSpec.dominoRow(fromX: 3.35, surfaceY: 7.2, count: 5),
    ObjectSpec.ball(6.55, 7.2),
    ObjectSpec.platform(7.3, 9.35, 3.0, angle: 0.2),
    for (var i = 0; i < 4; i++)
      ObjectSpec.domino(6.25 + i * 0.58, 9.14 + i * 0.12, angle: 0.2),
    ObjectSpec.platform(7.5, 11.4, 3.0, angle: -0.2),
    ObjectSpec.domino(8.3, 11.24, angle: -0.2),
    ObjectSpec.domino(7.72, 11.36, angle: -0.2),
    ObjectSpec.domino(7.14, 11.48, angle: -0.2),
    ObjectSpec.target(6.15, kGroundY, radius: 0.5),
  ],
);
