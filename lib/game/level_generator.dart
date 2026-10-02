import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'chain_simulation.dart';
import 'level_config.dart';
import 'levels/level_3.dart' as drop_template;
import 'levels/level_9.dart' as spring_template;
import 'logical_puzzle.dart';

const int currentGeneratorVersion = 1;

enum LevelTemplate { auto, simpleRelay, drop, spring }

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

/// Builds deterministic relay, drop, and spring candidates and vets them with
/// the same Forge2D simulation used by gameplay. This is deliberately offline
/// and does not touch player state or the game timer.
class LevelGenerator {
  const LevelGenerator();

  GenerationResult generateLevels(LevelGenerationRequest request) {
    if (request.count < 1) throw ArgumentError.value(request.count, 'count');
    if (request.difficulty < 1 || request.difficulty > 10) {
      throw ArgumentError.value(request.difficulty, 'difficulty', 'Use 1–10.');
    }
    final finalDifficulty =
        request.difficulty +
        (request.progressiveDifficulty ? request.count - 1 : 0);
    if (finalDifficulty > 10) {
      throw ArgumentError.value(
        finalDifficulty,
        'difficulty progression',
        'The final generated difficulty must be 10 or less.',
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
        ? difficulty <= 2
              ? LevelTemplate.simpleRelay
              : difficulty <= 5
              ? LevelTemplate.drop
              : LevelTemplate.spring
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
      LevelTemplate.auto => throw StateError('Auto template was not resolved.'),
    };
    final puzzle = _logicalPuzzle(selectedTemplate);
    final complexity = _complexity(selectedTemplate, objects, difficulty);
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
    // Preserve level 9's tested spring launch and upper lane. Increase the
    // domino run feeding the spring from five to nine objects as difficulty
    // rises, moving the ball toward the pad while keeping the launch route.
    const lowerSurface = 9.3;
    const lowerStartX = 1.45;
    const lowerSpacing = 0.45;
    final lowerCount = 5 + ((difficulty - 1) * 4 / 9).round();
    final ballX = lowerStartX + (lowerCount - 1) * lowerSpacing + 0.6;
    const platformLeft = 0.1;
    final platformRight = ballX + 0.35;
    final objects = <ObjectSpec>[
      for (final object in spring_template.level9.objects)
        if (!(object.kind == ObjectKind.platform && object.y > 9) &&
            !(object.kind == ObjectKind.domino && object.y > 8) &&
            object.kind != ObjectKind.ball)
          object,
      ObjectSpec.platform(
        (platformLeft + platformRight) / 2,
        lowerSurface,
        platformRight - platformLeft,
      ),
      ...ObjectSpec.dominoRow(
        fromX: lowerStartX,
        surfaceY: lowerSurface,
        count: lowerCount,
        spacing: lowerSpacing,
      ),
      ObjectSpec.ball(ballX, lowerSurface),
    ];
    return objects;
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
      ),
      ObjectKind.ball => ObjectSpec.ball(
        x(object.x),
        object.y + object.radius,
        radius: object.radius,
        starter: starter,
        push: push,
      ),
      ObjectKind.box => ObjectSpec.box(
        x(object.x),
        object.y + object.h / 2,
        w: object.w,
        h: object.h,
        starter: starter,
        push: push,
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
      ),
      ObjectKind.target => ObjectSpec.target(
        x(object.x),
        object.y + object.radius,
        radius: object.radius,
      ),
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
      LevelTemplate.auto => 0.0,
    };
    return (1 + (dominoes - 5) * 0.32 + mechanicBonus + difficulty * 0.06)
        .clamp(1, 10)
        .toDouble();
  }

  String _templateLabel(LevelTemplate template) => switch (template) {
    LevelTemplate.simpleRelay => 'Relay',
    LevelTemplate.drop => 'Drop',
    LevelTemplate.spring => 'Spring',
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
          (a.kind == ObjectKind.platform &&
              (b.kind == ObjectKind.platform ||
                  b.isDynamic ||
                  b.kind == ObjectKind.target ||
                  b.kind == ObjectKind.jumper)) ||
          (b.kind == ObjectKind.platform &&
              (a.isDynamic ||
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
