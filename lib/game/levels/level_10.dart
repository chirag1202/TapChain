import 'dart:ui';

import '../level_config.dart';
import 'level_2.dart';

// From a low platform, a jumper sends the chain up to a long downhill run.
final level10 = LevelConfig(
  id: 10,
  name: 'High Voltage',
  hint: 'Ride the spring, then follow the slope down.',
  theme: workshopTheme,
  baseReward: 500,
  objects: [
    ObjectSpec.platform(2.85, 12.3, 5.7),
    ObjectSpec.box(0.85, 12.3, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.65, surfaceY: 12.3, count: 4),
    ObjectSpec.ball(4.15, 12.3),
    ObjectSpec.jumper(4.95, 12.3, w: 1.1),
    ObjectSpec.platform(5.2, 5.7, 4.6),
    ObjectSpec.domino(6.7, 5.7),
    ObjectSpec.domino(6.12, 5.7),
    ObjectSpec.domino(5.54, 5.7),
    ObjectSpec.domino(4.96, 5.7),
    ObjectSpec.domino(4.38, 5.7),
    ObjectSpec.box(3.55, 5.7),
    ObjectSpec.platform(1.85, 7.35, 3.6, angle: -0.25),
    for (var i = 0; i < 4; i++)
      ObjectSpec.domino(3.0 - i * 0.55, 7.06 + i * 0.14, angle: -0.25),
    ObjectSpec.ball(0.75, 7.63),
    ObjectSpec.platform(1.55, 10.4, 2.5, angle: 0.2),
    ObjectSpec.domino(1.0, 10.29, angle: 0.2),
    ObjectSpec.domino(1.58, 10.4, angle: 0.2),
    ObjectSpec.domino(2.16, 10.52, angle: 0.2),
    ObjectSpec.target(3.0, kGroundY, radius: 0.5),
  ],
);
