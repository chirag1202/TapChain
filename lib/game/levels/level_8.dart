import 'dart:ui';

import '../level_config.dart';
import 'level_1.dart';

// A low side-to-side route with a long domino run and a ball finish.
final level8 = LevelConfig(
  id: 8,
  name: 'Crosscurrent',
  hint: 'Set the long row in motion.',
  theme: gardenTheme,
  baseReward: 350,
  objects: [
    ObjectSpec.platform(4.5, 9.5, 8.1),
    ObjectSpec.box(0.95, 9.5, starter: true, push: const Offset(14, 0)),
    ...ObjectSpec.dominoRow(
      fromX: 1.75,
      surfaceY: 9.5,
      count: 9,
      spacing: 0.6,
    ),
    ObjectSpec.ball(7.25, 9.5),
    ObjectSpec.target(8.2, 9.5, radius: 0.5),
  ],
);
