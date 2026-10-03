import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/level_config.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_exporter.dart';
import 'package:tapchain/game/level_generator.dart';
import 'package:tapchain/game/levels/level_1.dart';
import 'package:tapchain/game/logical_puzzle.dart';

void main() {
  const generator = LevelGenerator();
  const request = LevelGenerationRequest(
    count: 10,
    difficulty: 6,
    seed: 847291,
    theme: gardenTheme,
  );

  test('logical relay has one connected start and target', () {
    final result = generator.generateLevels(request);
    expect(result.candidates, isNotEmpty);
    final puzzle = result.candidates.first.definition.puzzle;
    expect(puzzle.validate(), isEmpty);
    expect(puzzle.starter?.type, PuzzleNodeType.starter);
    expect(puzzle.target?.type, PuzzleNodeType.target);
  });

  test('same seed produces the same accepted layouts', () {
    final a = generator.generateLevels(request);
    final b = generator.generateLevels(request);
    expect(a.candidates.length, 10);
    expect(
      a.candidates.map((candidate) => candidate.definition.seed),
      b.candidates.map((candidate) => candidate.definition.seed),
    );
    for (var i = 0; i < a.candidates.length; i++) {
      expect(
        a.candidates[i].definition.level.objects.map(
          (object) => [object.kind, object.x, object.y],
        ),
        b.candidates[i].definition.level.objects.map(
          (object) => [object.kind, object.x, object.y],
        ),
      );
    }
  });

  test('difficulty profiles create longer relays at higher settings', () {
    final easy = generator.generateLevels(
      const LevelGenerationRequest(
        count: 1,
        difficulty: 1,
        seed: 51,
        theme: gardenTheme,
      ),
    );
    final hard = generator.generateLevels(
      const LevelGenerationRequest(
        count: 1,
        difficulty: 10,
        seed: 51,
        theme: gardenTheme,
      ),
    );
    final medium = generator.generateLevels(
      const LevelGenerationRequest(
        count: 1,
        difficulty: 4,
        seed: 51,
        theme: gardenTheme,
      ),
    );
    expect(easy.candidates, hasLength(1));
    expect(medium.candidates, hasLength(1));
    expect(hard.candidates, hasLength(1));
    expect(easy.candidates.single.definition.template, 'slope');
    expect(medium.candidates.single.definition.template, 'cascade');
    expect(hard.candidates.single.definition.template, 'cascade');
    expect(
      hard.candidates.single.definition.complexityScore,
      greaterThan(easy.candidates.single.definition.complexityScore),
    );
  });

  test('auto progression varies routes and increases difficulty metadata', () {
    final result = generator.generateLevels(
      const LevelGenerationRequest(
        count: 10,
        difficulty: 1,
        seed: 847291,
        theme: gardenTheme,
        progressiveDifficulty: true,
      ),
    );
    expect(result.candidates, hasLength(10), reason: '${result.rejections}');
    expect(
      result.candidates.map((candidate) => candidate.definition.template).toSet(),
      containsAll(['slope', 'jumper', 'cascade', 'mechanism']),
    );
    for (var i = 0; i < result.candidates.length; i++) {
      expect(result.candidates[i].definition.difficulty, i + 1);
      expect(result.candidates[i].definition.complexityScore, (i + 1).toDouble());
      expect(result.candidates[i].physics.valid, isTrue);
    }
    final midStartJumper = result.candidates[1].definition.level;
    expect(midStartJumper.objects.singleWhere((object) => object.starter).kind, ObjectKind.domino);
    expect(midStartJumper.objects.any((object) => object.kind == ObjectKind.jumper), isTrue);
  });

  test('logical validator reports a disconnected required stage', () {
    const broken = LogicalPuzzle(
      nodes: [
        PuzzleNode('start', PuzzleNodeType.starter),
        PuzzleNode('run', PuzzleNodeType.dominoRun),
        PuzzleNode('target', PuzzleNodeType.target),
      ],
      links: [PuzzleLink('start', 'run')],
    );
    expect(broken.validate(), contains(contains('disconnected')));
  });

  test('returns ten geometry and physics validated playable candidates', () {
    final result = generator.generateLevels(request);
    expect(result.candidates, hasLength(10), reason: '${result.rejections}');
    for (final candidate in result.candidates) {
      expect(candidate.geometry.valid, isTrue);
      expect(candidate.physics.valid, isTrue);
      expect(candidate.physics.starterActivated, isTrue);
      expect(candidate.physics.chainBegan, isTrue);
      expect(candidate.physics.targetHit, isTrue);
      expect(candidate.physics.settled, isTrue);
      expect(candidate.physics.allDynamicObjectsFell, isTrue);
      expect(
        candidate.definition.level.generatorVersion,
        currentGeneratorVersion,
      );
      expect(
        candidate.definition.level.generationSeed,
        candidate.definition.seed,
      );
    }
  });

  test('relay, drop, and spring templates all use validated physics', () {
    for (final template in [
      LevelTemplate.simpleRelay,
      LevelTemplate.drop,
      LevelTemplate.spring,
      LevelTemplate.mechanism,
      LevelTemplate.slope,
      LevelTemplate.jumper,
    ]) {
      final result = generator.generateLevels(
        LevelGenerationRequest(
          count: 2,
          difficulty: 6,
          seed: 2200 + template.index,
          theme: gardenTheme,
          template: template,
        ),
      );
      expect(
        result.candidates,
        hasLength(2),
        reason: '$template rejected ${result.rejections}',
      );
      for (final candidate in result.candidates) {
        expect(candidate.valid, isTrue);
        expect(candidate.definition.template, template.name);
      }
    }
  });

  test('progressive cascade batch increases from difficulty 1 through 10', () {
    final result = generator.generateLevels(
      const LevelGenerationRequest(
        count: 10,
        difficulty: 1,
        seed: 123456,
        theme: gardenTheme,
        template: LevelTemplate.cascade,
        firstLevelId: 11,
        progressiveDifficulty: true,
      ),
    );
    expect(result.candidates, hasLength(10), reason: '${result.rejections}');
    var previousObjects = 0;
    var previousComplexity = 0.0;
    for (var index = 0; index < result.candidates.length; index++) {
      final candidate = result.candidates[index];
      final dynamicCount = candidate.definition.level.objects
          .where((object) => object.isDynamic)
          .length;
      expect(candidate.definition.level.id, 11 + index);
      expect(candidate.definition.difficulty, 1 + index);
      expect(dynamicCount, greaterThanOrEqualTo(previousObjects));
      expect(
        candidate.definition.complexityScore,
        greaterThan(previousComplexity),
      );
      expect(candidate.physics.valid, isTrue);
      previousObjects = dynamicCount;
      previousComplexity = candidate.definition.complexityScore;
    }
    expect(previousObjects, greaterThan(10));
  });

  test('progressive mechanism batch validates character and switch chain', () {
    final result = generator.generateLevels(
      const LevelGenerationRequest(
        count: 10,
        difficulty: 1,
        seed: 847291,
        theme: gardenTheme,
        template: LevelTemplate.mechanism,
        firstLevelId: 21,
        progressiveDifficulty: true,
      ),
    );
    expect(result.candidates, hasLength(10), reason: '${result.rejections}');
    final allKinds = result.candidates
        .expand((candidate) => candidate.definition.level.objects)
        .map((object) => object.kind)
        .toSet();
    expect(allKinds, containsAll([ObjectKind.cat, ObjectKind.dog, ObjectKind.button, ObjectKind.gate, ObjectKind.ramp, ObjectKind.plank]));
    for (final candidate in result.candidates) {
      expect(candidate.physics.valid, isTrue);
      expect(candidate.physics.targetHit, isTrue);
      expect(candidate.physics.allDynamicObjectsFell, isTrue);
      final sim = ChainSimulation(candidate.definition.level)..trigger();
      while (!sim.failed && sim.time < 45) {
        sim.advance(1 / 60);
      }
      expect(sim.objects.where((object) => object.isButton).single.activated, isTrue);
      expect(sim.objects.where((object) => object.isGate).single.open, isTrue);
      expect(sim.objects.where((object) => object.isCharacter).any((object) => object.activated), isTrue);
      final early = ChainSimulation(candidate.definition.level)..trigger();
      while (!early.completed && !early.failed && early.time < 45) {
        early.advance(1 / 60);
      }
      expect(early.completed, isTrue);
      expect(early.failed, isFalse, reason: 'completion should not wait for settling');
    }
  });

  test('geometry validator explains objects outside world bounds', () {
    final candidate = generator.generateLevels(request).candidates.first;
    final badLevel = LevelConfig(
      id: candidate.definition.level.id,
      name: candidate.definition.level.name,
      hint: candidate.definition.level.hint,
      theme: candidate.definition.level.theme,
      baseReward: candidate.definition.level.baseReward,
      objects: [
        ...candidate.definition.level.objects,
        ObjectSpec.platform(20, 7, 2),
      ],
    );
    final report = validateGeometry(badLevel, candidate.definition.puzzle);
    expect(report.valid, isFalse);
    expect(report.errors, contains(contains('outside the playable world')));
  });

  test('physics validator rejects a relay whose target is out of reach', () {
    final candidate = generator.generateLevels(request).candidates.first;
    final old = candidate.definition.level;
    final badLevel = LevelConfig(
      id: old.id,
      name: old.name,
      hint: old.hint,
      theme: old.theme,
      baseReward: old.baseReward,
      objects: [
        ...old.objects.where((object) => object.kind != ObjectKind.target),
        ObjectSpec.target(8.7, kGroundY, radius: 0.3),
      ],
    );
    final report = validatePhysics(badLevel, candidate.definition.puzzle);
    expect(report.targetHit, isFalse);
    expect(report.valid, isFalse);
    expect(report.diagnostics, contains(contains('target was not hit')));
  });

  test('export produces a normal LevelConfig with seed metadata', () {
    final generated = generator.generateLevels(request).candidates.first;
    final source = const LevelExporter().toDart(generated);
    expect(source, contains("import '../../level_config.dart';"));
    expect(source, contains('final levelGeneratedSpring1 = LevelConfig('));
    expect(source, contains('generationSeed: ${generated.definition.seed}'));
    expect(source, contains('ObjectSpec.domino('));
    expect(source, contains('ObjectSpec.target('));
  });

  test('a vetted candidate can be saved as a Dart level file', () async {
    final candidate = generator.generateLevels(request).candidates.first;
    final destination = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'tapchain_export_${candidate.definition.seed}.dart',
    );
    addTearDown(() async {
      if (await destination.exists()) await destination.delete();
    });
    final written = await const LevelExporter().writeDartFile(
      candidate,
      destination,
    );
    expect(await written.exists(), isTrue);
    expect(await written.readAsString(), contains('LevelConfig('));
  });
}
