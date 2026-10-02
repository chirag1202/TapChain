import 'dart:ui';

import '../level_config.dart';
import 'level_4.dart';

// The first chain drops a ball onto a floor spring; it lands on a raised row
// that topples toward the target at the far edge.
final level9 = LevelConfig(
  id: 9,
  name: 'Springboard',
  hint: 'Send the ball off the ledge onto the spring.',
  theme: neonTheme,
  baseReward: 400,
  objects: [
    ObjectSpec.platform(2.0, 9.3, 3.8),
    ObjectSpec.box(0.85, 9.3, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(fromX: 1.45, surfaceY: 9.3, count: 4, spacing: 0.5),
    ObjectSpec.ball(3.55, 9.3),
    ObjectSpec.jumper(6.0, kGroundY, w: 1.2),
    ObjectSpec.platform(8.1, 7.2, 1.8),
    ...ObjectSpec.dominoRow(fromX: 8.4, surfaceY: 7.2, count: 3, spacing: -0.5),
    ObjectSpec.target(6.4, 7.2, radius: 0.48),
  ],
);
