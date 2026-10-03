import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../level_config.dart';
import 'level_6.dart' show level6, oceanTheme;
import 'level_7.dart' show level7, volcanoTheme;
import 'level_9.dart' show level9;
import 'mechanics_tutorial_levels.dart' show mechanicTutorialLevels;

// Authored reasoning stages. Each layout asks the player to read a different
// route: side entry, split heights, a switch, a spring, or a reversed relay.
final List<LevelConfig> reasoningPuzzleLevels = [
  LevelConfig(
    id: 21,
    name: 'Crossroads',
    hint: 'Start at the junction to send the ball down the lower route.',
    theme: oceanTheme,
    baseReward: 420,
    generationTemplate: 'junction-choice',
    generationDifficulty: 10,
    complexityScore: 10,
    objects: [
      ObjectSpec.platform(3.0, 8.2, 4.8),
      ObjectSpec.box(4.3, 8.2, starter: true, push: const Offset(12, 0)),
      ObjectSpec.ball(5.7, 8.2),
      ObjectSpec.platform(5.8, 11.0, 4.5),
      ...ObjectSpec.dominoRow(
        fromX: 7.5,
        surfaceY: 11.0,
        count: 4,
        spacing: -0.58,
      ),
      ObjectSpec.ball(5.3, 11.0),
      ObjectSpec.target(2.6, kGroundY),
    ],
  ),
  LevelConfig(
    id: 22,
    name: 'The Side Door',
    hint: 'Read the right-to-left run; the target is behind the starter.',
    theme: volcanoTheme,
    baseReward: 430,
    generationTemplate: 'reverse-entry',
    generationDifficulty: 11,
    complexityScore: 11,
    objects: [
      ObjectSpec.platform(6.8, 7.1, 3.6),
      ObjectSpec.domino(8.1, 7.1, starter: true, push: const Offset(-0.4, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.5,
        surfaceY: 7.1,
        count: 4,
        spacing: -0.58,
      ),
      ObjectSpec.ball(5.0, 7.1),
      ObjectSpec.platform(3.3, 10.0, 5.2),
      ...ObjectSpec.dominoRow(
        fromX: 5.3,
        surfaceY: 10.0,
        count: 5,
        spacing: -0.58,
      ),
      ObjectSpec.ball(2.3, 10.0),
      ObjectSpec.target(1.2, 10.0, radius: 0.48),
    ],
  ),
  _basedOn(
    mechanicTutorialLevels[5],
    23,
    'Switchback',
    'Read the switch, then the gate, before choosing your tap.',
    'switchback-gate',
  ),
  _basedOn(
    level9,
    24,
    'High Return',
    'A ball rebounds from the spring to a raised target route.',
    'spring-return',
  ),
  _basedOn(
    level6,
    25,
    'Two-Level Fork',
    'Follow the upper run into the lower return.',
    'falling-branch',
  ),
  _basedOn(
    mechanicTutorialLevels[8],
    26,
    'Pet Relay',
    'Predict which pet will be activated first.',
    'pet-relay',
  ),
  _basedOn(
    mechanicTutorialLevels[9],
    27,
    'The Missing Bridge',
    'The full route combines a ramp, a plank, and a gate.',
    'plank-switch',
    mirrored: true,
  ),
  _basedOn(
    level7,
    28,
    'Decoy Drop',
    'Read the descending route from its high starting point.',
    'decoy-height',
  ),
  _basedOn(
    mechanicTutorialLevels[6],
    29,
    'Ramp Transfer',
    'Trace the ramp transfer before the final ground run.',
    'ramp-transfer',
  ),
  _basedOn(
    mechanicTutorialLevels[7],
    30,
    'Last Prediction',
    'The cat must reach the switch before the target route opens.',
    'sequence-prediction',
  ),
];

LevelConfig _basedOn(
  LevelConfig source,
  int id,
  String name,
  String hint,
  String concept, {
  bool mirrored = false,
}) => LevelConfig(
  id: id,
  name: name,
  hint: hint,
  theme: source.theme,
  baseReward: 420 + (id - 21) * 10,
  generationTemplate: concept,
  generationDifficulty: id - 11,
  complexityScore: id - 11,
  objects: [for (final spec in source.objects) mirrored ? _mirror(spec) : spec],
);

ObjectSpec _mirror(ObjectSpec spec) {
  final x = kWorldWidth - spec.x;
  final angle = -spec.angle;
  final push = Offset(-spec.push.dx, spec.push.dy);
  return switch (spec.kind) {
    ObjectKind.domino => ObjectSpec.domino(
      x,
      spec.y + spec.h / 2,
      h: spec.h,
      angle: angle,
      starter: spec.starter,
      push: push,
    ),
    ObjectKind.ball => ObjectSpec.ball(
      x,
      spec.y + spec.radius,
      radius: spec.radius,
      starter: spec.starter,
      push: push,
    ),
    ObjectKind.box => ObjectSpec.box(
      x,
      spec.y + spec.h / 2,
      w: spec.w,
      h: spec.h,
      starter: spec.starter,
      push: push,
    ),
    ObjectKind.platform => ObjectSpec.platform(
      x + spec.h / 2 * math.sin(angle),
      spec.y - spec.h / 2 * math.cos(angle),
      spec.w,
      h: spec.h,
      angle: angle,
    ),
    ObjectKind.jumper => ObjectSpec.jumper(
      x,
      spec.y + spec.h / 2,
      w: spec.w,
      h: spec.h,
      direction: -spec.direction,
      launchVelocity: spec.launchVelocity,
      launchSpeed: -spec.launchSpeed,
    ),
    ObjectKind.target => ObjectSpec.target(
      x,
      spec.y + spec.radius,
      radius: spec.radius,
    ),
    ObjectKind.cat => ObjectSpec.cat(
      x,
      spec.y + spec.h / 2,
      direction: -spec.direction,
    ),
    ObjectKind.dog => ObjectSpec.dog(
      x,
      spec.y + spec.h / 2,
      direction: -spec.direction,
    ),
    ObjectKind.ramp => ObjectSpec.ramp(
      x,
      spec.y,
      spec.w,
      angle: angle,
      h: spec.h,
    ),
    ObjectKind.button => ObjectSpec.button(
      x,
      spec.y,
      w: spec.w,
      h: spec.h,
      id: spec.id,
      linkedTargetId: spec.linkedTargetId,
    ),
    ObjectKind.gate => ObjectSpec.gate(
      x,
      spec.y,
      w: spec.w,
      h: spec.h,
      id: spec.id,
    ),
    ObjectKind.plank => ObjectSpec.plank(
      x,
      spec.y + spec.h / 2,
      length: spec.w,
      h: spec.h,
      angle: angle,
      starter: spec.starter,
      push: push,
    ),
  };
}
