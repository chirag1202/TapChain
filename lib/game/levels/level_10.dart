import 'dart:ui';

import '../level_config.dart';
import 'level_2.dart';

// A long raised run-up drops onto a low spring, then the ball sweeps a raised
// domino lane into the target.
final level10 = LevelConfig(
  id: 10,
  name: 'High Voltage',
  hint: 'Let the ball fall onto the spring, then follow the long row.',
  theme: workshopTheme,
  baseReward: 500,
  objects: [
    ObjectSpec.platform(2.1, 9.3, 3.6),
    ObjectSpec.box(0.85, 9.3, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.45, surfaceY: 9.3, count: 4, spacing: 0.5),
    ObjectSpec.ball(3.55, 9.3),
    ObjectSpec.jumper(6.7, kGroundY, w: 1.2),
    ObjectSpec.platform(8.1, 7.2, 1.8),
    ...ObjectSpec.dominoRow(fromX: 8.4, surfaceY: 7.2, count: 3, spacing: -0.5),
    ObjectSpec.target(6.4, 7.2, radius: 0.48),
  ],
);
