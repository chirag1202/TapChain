import 'dart:ui';

import '../level_config.dart';
import 'level_2.dart';

// Two drops bracket the jumper: first onto the spring, then off the raised
// lane and across a second domino run to the target.
final level10 = LevelConfig(
  id: 10,
  name: 'High Voltage',
  hint: 'Drop onto the spring, then follow both domino runs.',
  theme: workshopTheme,
  baseReward: 500,
  objects: [
    ObjectSpec.platform(2.45, 9.3, 4.1),
    ObjectSpec.box(0.85, 9.3, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.6, surfaceY: 9.3, count: 4),
    ObjectSpec.ball(4.05, 9.3),
    ObjectSpec.jumper(4.9, kGroundY, w: 1.1),
    ObjectSpec.platform(4.9, 6.4, 4.8),
    ...ObjectSpec.dominoRow(fromX: 3.25, surfaceY: 6.4, count: 5),
    ObjectSpec.ball(6.4, 6.4),
    ObjectSpec.platform(6.5, 9.5, 4.0),
    ...ObjectSpec.dominoRow(fromX: 7.6, surfaceY: 9.5, count: 4, spacing: -0.6),
    ObjectSpec.ball(5.0, 9.5),
    ObjectSpec.target(4.0, kGroundY, radius: 0.5),
  ],
);
