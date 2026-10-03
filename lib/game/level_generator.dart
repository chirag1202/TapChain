import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:forge2d/forge2d.dart';

import 'chain_simulation.dart';
import 'level_config.dart';
import 'levels/level_3.dart' as drop_template;
import 'levels/level_9.dart' as spring_template;
import 'levels/level_6.dart' as cascade_template;
import 'levels/level_7.dart' as slope_template;
import 'logical_puzzle.dart';

const int currentGeneratorVersion = 1;

enum LevelTemplate { auto, simpleRelay, drop, spring, cascade, mechanism, slope, jumper }

/// Request parameters for an offline developer-side generation run.
class LevelGenerationRequest {
  const LevelGenerationRequest({
    required this.count,
    required this.difficulty,
    required this.seed,
    required this.theme,
    this.template = LevelTemplate.auto,
    this.firstLevelId = 100,
    this.maxAttemptsPerLevel = 40,
    this.progressiveDifficulty = false,
  });

  final int count;
  final int difficulty;
  final int seed;
  final LevelTheme theme;
  final LevelTemplate template;
  final int firstLevelId;
  final int maxAttemptsPerLevel;
  final bool progressiveDifficulty;
}

class GeometryReport {
  const GeometryReport(this.errors);
  final List<String> errors;
  bool get valid => errors.isEmpty;
}

class PhysicsValidationReport {
  const PhysicsValidationReport({
    required this.starterActivated,
    required this.chainBegan,
    required this.targetHit,
    required this.settled,
    required this.allDynamicObjectsFell,
    required this.interactionCount,
    required this.settleTime,
    required this.diagnostics,
  });

  final bool starterActivated;
  final bool chainBegan;
  final bool targetHit;
  final bool settled;
  final bool allDynamicObjectsFell;
  final int interactionCount;
  final double settleTime;
  final List<String> diagnostics;

  bool get valid =>
      starterActivated &&
      chainBegan &&
      targetHit &&
      settled &&
      allDynamicObjectsFell;
}

class TapCandidateOutcome {
  const TapCandidateOutcome({
    required this.objectId,
    required this.kind,
    required this.targetHit,
    required this.allDynamicObjectsTouched,
    required this.settled,
    required this.touchedObjects,
    required this.totalDynamicObjects,
    required this.simulationSeconds,
  });

  final String objectId;
  final ObjectKind kind;
  final bool targetHit;
  final bool allDynamicObjectsTouched;
  final bool settled;
  final int touchedObjects;
  final int totalDynamicObjects;
  final double simulationSeconds;
}

class TapChoiceAudit {
  const TapChoiceAudit({
    required this.levelId,
    required this.outcomes,
    required this.profile,
    required this.explicitCandidates,
    required this.physicsOnlyObjects,
  });

  final int levelId;
  final List<TapCandidateOutcome> outcomes;
  final TapChoiceProfile? profile;
  final bool explicitCandidates;
  final List<String> physicsOnlyObjects;

  int get successfulTaps => outcomes.where((o) => o.targetHit).length;
  int get fullTouchSolutions =>
      outcomes.where((o) => o.targetHit && o.allDynamicObjectsTouched).length;
  int get failedTaps => outcomes.length - successfulTaps;
  bool get profileSatisfied =>
      profile == null || profile!.accepts(successfulTaps);

  String format() {
    final winners = outcomes.where((o) => o.targetHit).toList();
    final failures = outcomes.where((o) => !o.targetHit).toList();
    return [
      'Level $levelId',
      'Tap candidates: ${outcomes.length}',
      'Candidate policy: ${explicitCandidates ? 'explicit allowlist' : 'legacy all-dynamic'}',
      'Successful: $successfulTaps',
      'Failed: $failedTaps',
      'Full-touch solutions: $fullTouchSolutions',
      if (profile != null)
        'Profile: ${profile!.name} (${profile!.description}) ${profileSatisfied ? 'PASS' : 'FAIL'}',
      'Physics-only (not directly tappable): ${physicsOnlyObjects.isEmpty ? 'none' : physicsOnlyObjects.join(', ')}',
      'SUCCESS:',
      if (winners.isEmpty) '- none',
      for (final outcome in winners)
        '- ${outcome.objectId} (${outcome.kind.name})',
      'FAIL:',
      if (failures.isEmpty) '- none',
      for (final outcome in failures)
        '- ${outcome.objectId} (${outcome.kind.name})',
    ].join('\n');
  }
}

class GeneratedCandidate {
  const GeneratedCandidate({
    required this.definition,
    required this.geometry,
    required this.physics,
  });

  final GeneratedLevelDefinition definition;
  final GeometryReport geometry;
  final PhysicsValidationReport physics;

  bool get valid => geometry.valid && physics.valid;
}

class GenerationResult {
  const GenerationResult({
    required this.candidates,
    required this.attempts,
    required this.rejections,
  });

  final List<GeneratedCandidate> candidates;
  final int attempts;
  final Map<String, int> rejections;
}

/// Builds deterministic relay, drop, spring, cascade, and character-switch
/// candidates and vets them with the same Forge2D simulation used by gameplay.
/// This is deliberately offline and does not touch player state or the game timer.
class LevelGenerator {
  const LevelGenerator();

  GenerationResult generateLevels(LevelGenerationRequest request) {
    if (request.count < 1) throw ArgumentError.value(request.count, 'count');
    if (request.difficulty < 1 || request.difficulty > 20) {
      throw ArgumentError.value(request.difficulty, 'difficulty', 'Use 1–20.');
    }
    final finalDifficulty =
        request.difficulty +
        (request.progressiveDifficulty ? request.count - 1 : 0);
    if (finalDifficulty > 20) {
      throw ArgumentError.value(
        finalDifficulty,
        'difficulty progression',
        'The final generated difficulty must be 20 or less.',
      );
    }
    if (request.maxAttemptsPerLevel < 1) {
      throw ArgumentError.value(
        request.maxAttemptsPerLevel,
        'maxAttemptsPerLevel',
      );
    }
    final random = _SeededRandom(request.seed);
    final accepted = <GeneratedCandidate>[];
    final rejections = <String, int>{};
    final maxAttempts = request.count * request.maxAttemptsPerLevel;
    var attempts = 0;
    while (accepted.length < request.count && attempts < maxAttempts) {
      attempts++;
      final candidateSeed = random.nextInt(0x7fffffff);
      final candidateDifficulty =
          request.difficulty +
          (request.progressiveDifficulty ? accepted.length : 0);
      final candidate = _candidate(
        request,
        candidateSeed,
        accepted.length,
        candidateDifficulty,
      );
      final geometry = validateGeometry(candidate.level, candidate.puzzle);
      if (!geometry.valid) {
        _count(rejections, geometry.errors.first);
        continue;
      }
      final physics = validatePhysics(candidate.level, candidate.puzzle);
      if (!physics.valid) {
        _count(rejections, physics.diagnostics.first);
        continue;
      }
      accepted.add(
        GeneratedCandidate(
          definition: candidate,
          geometry: geometry,
          physics: physics,
        ),
      );
    }
    return GenerationResult(
      candidates: List.unmodifiable(accepted),
      attempts: attempts,
      rejections: Map.unmodifiable(rejections),
    );
  }

  GeneratedLevelDefinition _candidate(
    LevelGenerationRequest request,
    int seed,
    int acceptedIndex,
    int difficulty,
  ) {
    final random = _SeededRandom(seed);
    final selectedTemplate = request.template == LevelTemplate.auto
        ? switch ((difficulty - 1) % 6) {
            0 => LevelTemplate.slope,
            1 => LevelTemplate.jumper,
            2 => LevelTemplate.mechanism,
            3 => LevelTemplate.cascade,
            4 => LevelTemplate.drop,
            _ => LevelTemplate.spring,
          }
        : request.template;
    final mirrored = random.nextBool();
    final compact = random.nextBool();
    final scale = compact ? 0.98 : 1.0;
    final objects = switch (selectedTemplate) {
      LevelTemplate.simpleRelay => _simpleRelay(difficulty, random),
      LevelTemplate.drop => [
        for (final object in drop_template.level3.objects)
          _transform(object, mirrored: mirrored, horizontalScale: scale),
      ],
      LevelTemplate.spring => [
        for (final object in _springLayout(difficulty))
          _transform(object, mirrored: mirrored, horizontalScale: scale),
      ],
      LevelTemplate.cascade => _cascadeLayout(difficulty),
      LevelTemplate.mechanism => _mechanismLayout(difficulty),
      LevelTemplate.slope => [
        for (final object in _slopeLayout())
          _transform(object, mirrored: mirrored, horizontalScale: scale),
      ],
      LevelTemplate.jumper => [
        for (final object in _jumperLayout(difficulty))
          _transform(object, mirrored: mirrored, horizontalScale: scale),
      ],
      LevelTemplate.auto => throw StateError('Auto template was not resolved.'),
    };
    final puzzle = _logicalPuzzle(selectedTemplate);
    final complexity = request.template == LevelTemplate.auto
        ? difficulty.toDouble()
        : _complexity(selectedTemplate, objects, difficulty);
    final level = LevelConfig(
      id: request.firstLevelId + acceptedIndex,
      name:
          'Generated ${_templateLabel(selectedTemplate)} ${acceptedIndex + 1}',
      hint: switch (selectedTemplate) {
        LevelTemplate.simpleRelay =>
          'Predict the chain, then tap the marked domino.',
        LevelTemplate.drop => 'Follow the ball through the drop to the target.',
        LevelTemplate.spring =>
          'Guide the ball onto the spring and upper lane.',
        LevelTemplate.cascade => 'Start midway and follow both drops to the target.',
        LevelTemplate.mechanism => 'Use the characters and switch to open the way to the target.',
        LevelTemplate.slope => 'Start midway and follow the sloped route to the target.',
        LevelTemplate.jumper => 'Start the ball midway and launch it up to the target.',
        LevelTemplate.auto => 'Follow the chain to the target.',
      },
      theme: request.theme,
      baseReward: 100 + difficulty * 10,
      objects: List.unmodifiable(objects),
      generatorVersion: currentGeneratorVersion,
      generationSeed: seed,
      generationTemplate: selectedTemplate.name,
      generationDifficulty: difficulty,
      complexityScore: complexity,
    );
    return GeneratedLevelDefinition(
      level: level,
      puzzle: puzzle,
      seed: seed,
      template: selectedTemplate.name,
      difficulty: difficulty,
      complexityScore: complexity,
    );
  }

  List<ObjectSpec> _simpleRelay(int difficulty, _SeededRandom random) {
    final dominoCount = 5 + ((difficulty - 1) * 3 / 9).round();
    const spacing = 0.6;
    final leftToRight = random.nextBool();
    final startX = 1.2 + random.nextInt(4) * 0.1;
    final row = <ObjectSpec>[
      for (var index = 0; index < dominoCount; index++)
        ObjectSpec.domino(
          leftToRight
              ? startX + index * spacing
              : kWorldWidth - startX - index * spacing,
          kGroundY,
          starter: index == 0,
          push: index == 0
              ? Offset(leftToRight ? 0.55 : -0.55, 0)
              : Offset.zero,
        ),
    ];
    return [
      ...row,
      ObjectSpec.target(row.last.x + (leftToRight ? 1.3 : -1.3), kGroundY),
    ];
  }

  List<ObjectSpec> _springLayout(int difficulty) {
    // Keep the authored spring route intact; the previous widened feed lane
    // caused the last domino to stall before the spring. Difficulty variation
    // for this template comes from the seeded mirror/compression transforms.
    return List<ObjectSpec>.of(spring_template.level9.objects);
  }

  List<ObjectSpec> _cascadeLayout(int difficulty) {
    // Level 6 is a physics-tested two-drop chain. Extend both connected
    // relays as difficulty rises, preserving the two drops and their contact
    // order so the extra pieces add decisions without breaking the solution.
    final groundExtra = difficulty <= 6 ? difficulty : 6;
    final upperExtra = difficulty < 4 ? 0 : difficulty < 8 ? 1 : 2;
    final rightExtra = difficulty < 5 ? 0 : 1;
    final targetX = 4.2 - (groundExtra - 1) * 0.6;
    final upperCount = 4 + upperExtra;
    final ballX = 1.55 + (upperCount - 1) * 0.6 + 0.8;
    final platformRight = ballX + 0.35 > 5.2 ? ballX + 0.35 : 5.2;
    return [
      for (final object in cascade_template.level6.objects)
        if (!(object.kind == ObjectKind.platform && object.y < 9) &&
            !(object.kind == ObjectKind.domino && object.y < 9 && !object.starter) &&
            !(object.kind == ObjectKind.ball && object.y < 9) &&
            object.kind != ObjectKind.target)
          object,
      ObjectSpec.platform((0.2 + platformRight) / 2, 8.0, platformRight - 0.2),
      ...ObjectSpec.dominoRow(fromX: 1.55, surfaceY: 8.0, count: upperCount, spacing: 0.6),
      ObjectSpec.ball(ballX, 8.0),
      ...ObjectSpec.dominoRow(fromX: 5.0, surfaceY: kGroundY, count: groundExtra, spacing: -0.6),
      ...ObjectSpec.dominoRow(fromX: 8.6, surfaceY: kGroundY, count: rightExtra, spacing: 0.6),
      ObjectSpec.target(targetX, kGroundY, radius: 0.48),
    ];
  }

  List<ObjectSpec> _mechanismLayout(int difficulty) {
    // A grounded, deterministic character-switch-gate chain. The ball tips a
    // relay, reaches the cat, and the cat runs over the linked switch to open
    // the gate. Ramp and plank add physical route elements in later variants.
    final mechanicStep = difficulty > 10 ? difficulty - 10 : difficulty;
    final dominoCount = 4 + (mechanicStep >= 6 ? 1 : 0);
    final ballX = 1.2 + (dominoCount - 1) * 0.56 + 0.55;
    final dogX = ballX + 0.78;
    final catX = dogX + 0.9;
    final buttonX = catX + 0.85;
    final gateX = buttonX + 0.65;
    final objects = <ObjectSpec>[
      ...ObjectSpec.dominoRow(
        fromX: 1.2,
        surfaceY: kGroundY,
        count: dominoCount,
        spacing: 0.56,
        firstIsStarter: true,
      ),
      ObjectSpec.ball(ballX, kGroundY),
      ObjectSpec.dog(dogX, kGroundY, direction: 1),
      ObjectSpec.cat(catX, kGroundY, direction: 1),
      ObjectSpec.button(buttonX, kGroundY - 0.12, id: 'switch-a', linkedTargetId: 'gate-a'),
      ObjectSpec.gate(gateX, kGroundY - 0.8, id: 'gate-a'),
      // Increasingly varied grounded hardware gives later routes more
      // collision choices while keeping the switch and gate chain readable.
      ObjectSpec.ramp(0.55, 13.88, 0.9, angle: -0.24 + mechanicStep * 0.012),
      if (mechanicStep <= 5) ObjectSpec.plank(7.25, kGroundY, length: 0.7),
      ObjectSpec.target(8.45, kGroundY, radius: 0.48),
    ];
    return objects;
  }

  List<ObjectSpec> _slopeLayout() =>
      List<ObjectSpec>.of(slope_template.level7.objects);

  List<ObjectSpec> _jumperLayout(int difficulty) {
    final addedFeedDominoes = difficulty >= 5 ? 1 : 0;
    final feedCount = 4 + addedFeedDominoes;
    return [
      ObjectSpec.platform(
        2.0 + addedFeedDominoes * 0.25,
        9.3,
        3.8 + addedFeedDominoes * 0.5,
      ),
      ...ObjectSpec.dominoRow(
        fromX: 1.45,
        surfaceY: 9.3,
        count: feedCount,
        spacing: 0.5,
        firstIsStarter: true,
      ),
      ObjectSpec.ball(3.55 + addedFeedDominoes * 0.5, 9.3),
      ObjectSpec.jumper(6.0, kGroundY, w: 1.2),
      ObjectSpec.platform(8.1, 7.2, 1.8),
      ...ObjectSpec.dominoRow(
        fromX: 8.4,
        surfaceY: 7.2,
        count: 3,
        spacing: -0.5,
      ),
      ObjectSpec.target(6.4, 7.2, radius: 0.48),
    ];
  }

  ObjectSpec _transform(
    ObjectSpec object, {
    required bool mirrored,
    required double horizontalScale,
  }) {
    double x(double value) {
      final scaled =
          kWorldWidth / 2 + (value - kWorldWidth / 2) * horizontalScale;
      return mirrored ? kWorldWidth - scaled : scaled;
    }

    final angle = mirrored ? -object.angle : object.angle;
    final push = Offset(
      mirrored ? -object.push.dx : object.push.dx,
      object.push.dy,
    );
    final starter = object.starter;
    return switch (object.kind) {
      ObjectKind.domino => ObjectSpec.domino(
        x(object.x),
        object.y + object.h / 2,
        h: object.h,
        angle: angle,
        starter: starter,
        push: push,
        id: object.id,
        physicsActivatable: object.physicsActivatable,
      ),
      ObjectKind.ball => ObjectSpec.ball(
        x(object.x),
        object.y + object.radius,
        radius: object.radius,
        starter: starter,
        push: push,
        id: object.id,
        physicsActivatable: object.physicsActivatable,
      ),
      ObjectKind.box => ObjectSpec.box(
        x(object.x),
        object.y + object.h / 2,
        w: object.w,
        h: object.h,
        starter: starter,
        push: push,
        id: object.id,
        physicsActivatable: object.physicsActivatable,
      ),
      ObjectKind.platform => ObjectSpec.platform(
        x(object.x + object.h / 2 * math.sin(object.angle)),
        object.y - object.h / 2 * math.cos(object.angle),
        object.w * horizontalScale,
        h: object.h,
        angle: angle,
      ),
      ObjectKind.jumper => ObjectSpec.jumper(
        x(object.x),
        object.y + object.h / 2,
        w: object.w * horizontalScale,
        h: object.h,
        direction: mirrored ? -object.direction : object.direction,
        launchVelocity: object.launchVelocity,
        launchSpeed: object.launchSpeed,
        physicsActivatable: object.physicsActivatable,
      ),
      ObjectKind.target => ObjectSpec.target(
        x(object.x),
        object.y + object.radius,
        radius: object.radius,
      ),
      ObjectKind.cat => ObjectSpec.cat(x(object.x), object.y + object.h / 2, direction: mirrored ? -object.direction : object.direction, id: object.id, physicsActivatable: object.physicsActivatable),
      ObjectKind.dog => ObjectSpec.dog(x(object.x), object.y + object.h / 2, direction: mirrored ? -object.direction : object.direction, id: object.id, physicsActivatable: object.physicsActivatable),
      ObjectKind.ramp => ObjectSpec.ramp(x(object.x), object.y, object.w * horizontalScale, angle: angle, h: object.h),
      ObjectKind.button => ObjectSpec.button(x(object.x), object.y, w: object.w * horizontalScale, h: object.h, id: object.id, linkedTargetId: object.linkedTargetId, physicsActivatable: object.physicsActivatable),
      ObjectKind.gate => ObjectSpec.gate(x(object.x), object.y, w: object.w, h: object.h, id: object.id),
      ObjectKind.plank => ObjectSpec.plank(x(object.x), object.y + object.h / 2, length: object.w * horizontalScale, h: object.h, angle: angle, starter: starter, push: push, id: object.id, physicsActivatable: object.physicsActivatable),
    };
  }

  LogicalPuzzle _logicalPuzzle(LevelTemplate template) => switch (template) {
    LevelTemplate.simpleRelay => const LogicalPuzzle(
      nodes: [
        PuzzleNode('start', PuzzleNodeType.starter),
        PuzzleNode('domino-relay', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('start', 'domino-relay'),
        PuzzleLink('domino-relay', 'target'),
      ],
    ),
    LevelTemplate.drop => const LogicalPuzzle(
      nodes: [
        PuzzleNode('start', PuzzleNodeType.starter),
        PuzzleNode('upper-run', PuzzleNodeType.dominoRun),
        PuzzleNode('upper-ball', PuzzleNodeType.ball),
        PuzzleNode('drop', PuzzleNodeType.drop),
        PuzzleNode('lower-run', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('start', 'upper-run'),
        PuzzleLink('upper-run', 'upper-ball'),
        PuzzleLink('upper-ball', 'drop'),
        PuzzleLink('drop', 'lower-run'),
        PuzzleLink('lower-run', 'target'),
      ],
    ),
    LevelTemplate.spring => const LogicalPuzzle(
      nodes: [
        PuzzleNode('start', PuzzleNodeType.starter),
        PuzzleNode('lower-run', PuzzleNodeType.dominoRun),
        PuzzleNode('ball', PuzzleNodeType.ball),
        PuzzleNode('spring', PuzzleNodeType.spring),
        PuzzleNode('upper-platform', PuzzleNodeType.platform),
        PuzzleNode('upper-run', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('start', 'lower-run'),
        PuzzleLink('lower-run', 'ball'),
        PuzzleLink('ball', 'spring'),
        PuzzleLink('spring', 'upper-platform'),
        PuzzleLink('upper-platform', 'upper-run'),
        PuzzleLink('upper-run', 'target'),
      ],
    ),
    LevelTemplate.cascade => const LogicalPuzzle(
      nodes: [
        PuzzleNode('start', PuzzleNodeType.starter),
        PuzzleNode('first-run', PuzzleNodeType.dominoRun),
        PuzzleNode('first-ball', PuzzleNodeType.ball),
        PuzzleNode('middle-run', PuzzleNodeType.dominoRun),
        PuzzleNode('second-ball', PuzzleNodeType.ball),
        PuzzleNode('ground-run', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('start', 'first-run'),
        PuzzleLink('first-run', 'first-ball'),
        PuzzleLink('first-ball', 'middle-run'),
        PuzzleLink('middle-run', 'second-ball'),
        PuzzleLink('second-ball', 'ground-run'),
        PuzzleLink('ground-run', 'target'),
      ],
    ),
    LevelTemplate.mechanism => const LogicalPuzzle(
      nodes: [
        PuzzleNode('starter', PuzzleNodeType.starter),
        PuzzleNode('ball', PuzzleNodeType.ball),
        PuzzleNode('character', PuzzleNodeType.dominoRun),
        PuzzleNode('button', PuzzleNodeType.platform),
        PuzzleNode('gate', PuzzleNodeType.platform),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('starter', 'ball'),
        PuzzleLink('ball', 'character'),
        PuzzleLink('character', 'button'),
        PuzzleLink('button', 'gate'),
        PuzzleLink('gate', 'target'),
      ],
    ),
    LevelTemplate.slope => const LogicalPuzzle(
      nodes: [
        PuzzleNode('mid-start', PuzzleNodeType.starter),
        PuzzleNode('slope-run', PuzzleNodeType.dominoRun),
        PuzzleNode('drop', PuzzleNodeType.drop),
        PuzzleNode('lower-route', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('mid-start', 'slope-run'),
        PuzzleLink('slope-run', 'drop'),
        PuzzleLink('drop', 'lower-route'),
        PuzzleLink('lower-route', 'target'),
      ],
    ),
    LevelTemplate.jumper => const LogicalPuzzle(
      nodes: [
        PuzzleNode('mid-ball', PuzzleNodeType.starter),
        PuzzleNode('jumper', PuzzleNodeType.spring),
        PuzzleNode('upper-run', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [
        PuzzleLink('mid-ball', 'jumper'),
        PuzzleLink('jumper', 'upper-run'),
        PuzzleLink('upper-run', 'target'),
      ],
    ),
    LevelTemplate.auto => throw StateError('Auto template was not resolved.'),
  };

  double _complexity(
    LevelTemplate template,
    List<ObjectSpec> objects,
    int difficulty,
  ) {
    final dominoes = objects
        .where((object) => object.kind == ObjectKind.domino)
        .length;
    final mechanicBonus = switch (template) {
      LevelTemplate.simpleRelay => 0.0,
      LevelTemplate.drop => 2.0,
      LevelTemplate.spring => 5.0,
      LevelTemplate.cascade => 6.0,
      LevelTemplate.mechanism =>
        4.0 +
        objects.where((o) => o.kind == ObjectKind.cat || o.kind == ObjectKind.dog).length * 0.6 +
        (objects.any((o) => o.kind == ObjectKind.button) && objects.any((o) => o.kind == ObjectKind.gate) ? 1.2 : 0) +
        (objects.any((o) => o.kind == ObjectKind.ramp) ? 0.8 : 0) +
        (objects.any((o) => o.kind == ObjectKind.plank) ? 0.8 : 0),
      LevelTemplate.slope => 4.0,
      LevelTemplate.jumper => 5.0,
      LevelTemplate.auto => 0.0,
    };
    final progression = template == LevelTemplate.cascade
        ? 3.5 + difficulty * 0.55
        : template == LevelTemplate.mechanism
        ? mechanicBonus + dominoes * 0.25 + difficulty * 0.1
        : 1 + (dominoes - 5) * 0.32 + mechanicBonus + difficulty * 0.06;
    return (progression)
        .clamp(1, 10)
        .toDouble();
  }

  String _templateLabel(LevelTemplate template) => switch (template) {
    LevelTemplate.simpleRelay => 'Relay',
    LevelTemplate.drop => 'Drop',
    LevelTemplate.spring => 'Spring',
    LevelTemplate.cascade => 'Cascade',
    LevelTemplate.mechanism => 'Mechanism',
    LevelTemplate.slope => 'Slope',
    LevelTemplate.jumper => 'Jumper',
    LevelTemplate.auto => 'Puzzle',
  };

  static void _count(Map<String, int> counts, String reason) {
    counts[reason] = (counts[reason] ?? 0) + 1;
  }
}

/// Rejects malformed graph definitions and common geometric mistakes before
/// spending time in the physics world.
GeometryReport validateGeometry(LevelConfig level, LogicalPuzzle puzzle) {
  final errors = <String>[...puzzle.validate()];
  errors.addAll(level.validateTapConfiguration());
  final starters = level.objects.where((object) => object.starter).length;
  final targets = level.objects
      .where((object) => object.kind == ObjectKind.target)
      .length;
  if (starters != 1) errors.add('Expected one starter; found $starters.');
  if (targets != 1) errors.add('Expected one target; found $targets.');
  if (!level.objects.any((object) => object.isDynamic)) {
    errors.add('At least one dynamic object is required.');
  }

  for (var index = 0; index < level.objects.length; index++) {
    final object = level.objects[index];
    final halfWidth =
        object.kind == ObjectKind.ball || object.kind == ObjectKind.target
        ? object.radius
        : object.w / 2;
    final halfHeight =
        object.kind == ObjectKind.ball || object.kind == ObjectKind.target
        ? object.radius
        : object.h / 2;
    final rotatedHalfWidth =
        halfWidth * math.cos(object.angle).abs() +
        halfHeight * math.sin(object.angle).abs();
    final rotatedHalfHeight =
        halfHeight * math.cos(object.angle).abs() +
        halfWidth * math.sin(object.angle).abs();
    if (object.x - rotatedHalfWidth < 0 ||
        object.x + rotatedHalfWidth > kWorldWidth ||
        object.y - rotatedHalfHeight < 0 ||
        object.y + rotatedHalfHeight > kWorldHeight) {
      errors.add('Object #${index + 1} is outside the playable world.');
    }
  }

  final dominoes =
      level.objects.where((object) => object.kind == ObjectKind.domino).toList()
        ..sort((a, b) => a.x.compareTo(b.x));
  for (var index = 1; index < dominoes.length; index++) {
    final a = dominoes[index - 1];
    final b = dominoes[index];
    if ((a.y - b.y).abs() > 0.2) continue;
    final spacing = (a.x - b.x).abs();
    if (spacing < 0.25 || spacing > 0.75) {
      errors.add(
        'Adjacent dominoes are $spacing world units apart; supported range is 0.25–0.75.',
      );
    }
  }

  // Catch interpenetrating bodies and crossed platforms before simulation.
  // Support contacts with the floor and a platform remain intentional.
  for (var i = 0; i < level.objects.length; i++) {
    final a = level.objects[i];
    for (var j = i + 1; j < level.objects.length; j++) {
      final b = level.objects[j];
      final relevant =
          (a.isDynamic && (b.isDynamic || b.kind == ObjectKind.target)) ||
          (b.isDynamic && a.kind == ObjectKind.target) ||
          ((a.kind == ObjectKind.platform || a.kind == ObjectKind.ramp) &&
              (b.kind == ObjectKind.platform ||
                  b.kind == ObjectKind.ramp ||
                  b.isDynamic ||
                  b.kind == ObjectKind.target ||
                  b.kind == ObjectKind.jumper)) ||
          ((b.kind == ObjectKind.platform || b.kind == ObjectKind.ramp) &&
              (a.isDynamic ||
                  a.kind == ObjectKind.ramp ||
                  a.kind == ObjectKind.target ||
                  a.kind == ObjectKind.jumper));
      if (!relevant) continue;
      final aWidth = a.kind == ObjectKind.ball || a.kind == ObjectKind.target
          ? a.radius
          : a.w / 2;
      final aHeight = a.kind == ObjectKind.ball || a.kind == ObjectKind.target
          ? a.radius
          : a.h / 2;
      final bWidth = b.kind == ObjectKind.ball || b.kind == ObjectKind.target
          ? b.radius
          : b.w / 2;
      final bHeight = b.kind == ObjectKind.ball || b.kind == ObjectKind.target
          ? b.radius
          : b.h / 2;
      final aHalfW =
          aWidth * math.cos(a.angle).abs() + aHeight * math.sin(a.angle).abs();
      final aHalfH =
          aHeight * math.cos(a.angle).abs() + aWidth * math.sin(a.angle).abs();
      final bHalfW =
          bWidth * math.cos(b.angle).abs() + bHeight * math.sin(b.angle).abs();
      final bHalfH =
          bHeight * math.cos(b.angle).abs() + bWidth * math.sin(b.angle).abs();
      final overlapX = aHalfW + bHalfW - (a.x - b.x).abs();
      final overlapY = aHalfH + bHalfH - (a.y - b.y).abs();
      final supportPair =
          a.kind == ObjectKind.platform || b.kind == ObjectKind.platform;
      final penetrationThreshold = supportPair ? 0.08 : 0.04;
      if (overlapX > penetrationThreshold && overlapY > penetrationThreshold) {
        errors.add('Objects #${i + 1} and #${j + 1} overlap at spawn.');
      }
    }
  }
  return GeometryReport(List.unmodifiable(errors));
}

/// Audits each configured tap in a fresh production physics world. This
/// developer/test utility is never called during gameplay.
TapChoiceAudit auditTapChoices(LevelConfig level, {double maxSimulationSeconds = 45}) {
  final configErrors = level.validateTapConfiguration();
  if (configErrors.isNotEmpty) {
    throw ArgumentError('Invalid tap configuration: ${configErrors.join(' ')}');
  }
  final outcomes = <TapCandidateOutcome>[];
  for (final index in level.tapCandidateIndices) {
    final spec = level.objects[index];
    final sim = ChainSimulation(level);
    if (!sim.triggerAt(Vector2(spec.x, spec.y))) {
      throw StateError('Tap candidate ${level.objectIdAt(index)} was not hit.');
    }
    while (!sim.failed && sim.time < maxSimulationSeconds) {
      sim.advance(1 / 60);
    }
    outcomes.add(TapCandidateOutcome(
      objectId: level.objectIdAt(index),
      kind: spec.kind,
      targetHit: sim.targetHit,
      allDynamicObjectsTouched: sim.allDynamicObjectsTouched,
      settled: sim.failed,
      touchedObjects: sim.touchedObjectCount,
      totalDynamicObjects: sim.totalDynamicObjects,
      simulationSeconds: sim.time,
    ));
  }
  return TapChoiceAudit(
    levelId: level.id,
    outcomes: List.unmodifiable(outcomes),
    profile: level.tapChoiceProfile,
    explicitCandidates: level.tapCandidates != null,
    physicsOnlyObjects: List.unmodifiable([
      for (var i = 0; i < level.objects.length; i++)
        if (level.objects[i].isDynamic && !level.isTapCandidate(i))
          level.objectIdAt(i),
    ]),
  );
}

/// Runs the candidate in the production Forge2D world, tapping its authored
/// starter and waiting for the same settle condition used by live gameplay.
PhysicsValidationReport validatePhysics(
  LevelConfig level,
  LogicalPuzzle puzzle, {
  double maxSimulationSeconds = 45,
}) {
  final diagnostics = <String>[];
  final sim = ChainSimulation(level);
  var interactions = 0;
  sim.onImpact = (_, __, ___, ____) {
    interactions++;
  };
  sim.trigger();
  while (!sim.failed && sim.time < maxSimulationSeconds) {
    sim.advance(1 / 60);
  }
  final starterActivated = sim.triggered && sim.starter.hasFallen;
  final chainBegan = interactions > 0;
  final allFell = sim.fallenObjectCount == sim.totalDynamicObjects;
  if (!starterActivated) diagnostics.add('Starter did not activate.');
  if (!chainBegan) diagnostics.add('No physical interaction was recorded.');
  if (!sim.targetHit) diagnostics.add('The target was not hit.');
  if (!sim.failed) diagnostics.add('The physics world did not settle in time.');
  if (!allFell) {
    diagnostics.add(
      'Only ${sim.fallenObjectCount}/${sim.totalDynamicObjects} dynamic objects fell.',
    );
  }
  if (puzzle.validate().isNotEmpty) diagnostics.addAll(puzzle.validate());
  return PhysicsValidationReport(
    starterActivated: starterActivated,
    chainBegan: chainBegan,
    targetHit: sim.targetHit,
    settled: sim.failed,
    allDynamicObjectsFell: allFell,
    interactionCount: interactions,
    settleTime: sim.time,
    diagnostics: List.unmodifiable(diagnostics),
  );
}

/// Minimal fixed-width PRNG to keep seeds reproducible without relying on the
/// Dart SDK's implementation details for [math.Random].
class _SeededRandom {
  _SeededRandom(int seed) : _state = seed & 0xffffffff {
    if (_state == 0) _state = 0x6d2b79f5;
  }

  int _state;

  int _next() {
    _state ^= (_state << 13) & 0xffffffff;
    _state ^= _state >> 17;
    _state ^= (_state << 5) & 0xffffffff;
    _state &= 0xffffffff;
    return _state;
  }

  int nextInt(int max) => _next() % max;
  bool nextBool() => nextInt(2) == 0;
}
