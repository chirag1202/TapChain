import 'dart:ui';

import '../level_config.dart';
import 'level_4.dart';

// A raised run-up drops the ball onto a floor spring. The spring sends it to
// the upper lane, whose ball rolls off to the ground target.
final level9 = LevelConfig(
  id: 9,
  name: 'Springboard',
  hint: 'Send the ball off the ledge onto the spring.',
  theme: neonTheme,
  baseReward: 400,
  objects: [
    ObjectSpec.platform(2.45, 9.3, 4.1),
    ObjectSpec.box(0.85, 9.3, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.6, surfaceY: 9.3, count: 4),
    ObjectSpec.ball(4.05, 9.3),
    ObjectSpec.jumper(4.9, kGroundY, w: 1.1),
    ObjectSpec.platform(4.9, 7.2, 4.8),
    ...ObjectSpec.dominoRow(fromX: 3.25, surfaceY: 7.2, count: 5),
    ObjectSpec.ball(6.4, 7.2),
    ObjectSpec.target(7.65, kGroundY, radius: 0.5),
  ],
);
