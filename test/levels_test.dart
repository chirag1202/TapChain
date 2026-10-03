import 'dart:math' as math;

import 'package:forge2d/forge2d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_config.dart';
import 'package:tapchain/game/level_generator.dart';
import 'package:tapchain/game/physics_objects.dart';
import 'package:tapchain/game/levels/levels.dart';

class Outcome {
  Outcome(
    this.hit,
    this.time,
    this.snapshot,
    this.longestLull,
    this.fallen,
    this.total,
    this.settled,
    this.details,
    this.trace,
  );
  final bool hit;
  final double time;
  final List<double> snapshot;

  /// Longest stretch (seconds) where nothing moved faster than 0.5 m/s.
  final double longestLull;
  final int fallen;
  final int total;
  final bool settled;
  final List<String> details;
  final List<String> trace;
}

Outcome run(LevelConfig level) {
  final sim = ChainSimulation(level);
  sim.trigger();
  var lull = 0.0;
  var longest = 0.0;
  final trace = <String>[];
  var traceTick = -1;
  while (!sim.failed && sim.time < 60) {
    sim.advance(1 / 60);
    final jumpers = sim.objects.where((o) => o.isJumper);
    final tick = (sim.time * 4).floor();
    if (jumpers.isNotEmpty && jumpers.first.activated && tick != traceTick) {
      traceTick = tick;
      final ball = sim.objects.firstWhere((o) => o.spec.kind.name == 'ball');
      trace.add(
        't=${sim.time.toStringAsFixed(2)} '
        'ball=(${ball.body.position.x.toStringAsFixed(2)},'
        '${ball.body.position.y.toStringAsFixed(2)})',
      );
    }
    var fastest = 0.0;
    for (final o in sim.objects) {
      if (o.spec.isDynamic && !o.gone) {
        fastest = math.max(fastest, o.body.linearVelocity.length);
      }
    }
    if (!sim.targetHit) {
      lull = fastest < 0.5 ? lull + 1 / 60 : 0;
      longest = math.max(longest, lull);
    }
  }
  return Outcome(
    sim.targetHit,
    sim.hitTime,
    [
      for (final o in sim.objects) ...[o.body.position.x, o.body.position.y],
    ],
    longest,
    sim.fallenObjectCount,
    sim.totalDynamicObjects,
    sim.failed,
    [
      for (final o in sim.objects.where((o) => o.spec.isDynamic))
        '${o.spec.kind}: (${o.initialPosition.x.toStringAsFixed(1)},'
            '${o.initialPosition.y.toStringAsFixed(1)}) -> '
            '(${o.body.position.x.toStringAsFixed(1)},'
            '${o.body.position.y.toStringAsFixed(1)}) '
            'a=${o.body.angle.toStringAsFixed(2)} fallen=${o.hasFallen}',
      for (final o in sim.objects.where((o) => o.isJumper))
        'jumper activated=${o.activated} at '
            '(${o.body.position.x.toStringAsFixed(1)},'
            '${o.body.position.y.toStringAsFixed(1)})',
    ],
    trace,
  );
}

LevelConfig withPush(LevelConfig l, double k) => LevelConfig(
  id: l.id,
  name: l.name,
  hint: l.hint,
  theme: l.theme,
  baseReward: l.baseReward,
  objects: [for (final o in l.objects) o.withPushScale(k)],
);

void main() {
  test(
    'levels 11-20 introduce the physical mechanics in a tutorial sequence',
    () {
      final generated = allLevels
          .where((level) => level.id >= 11 && level.id <= 20)
          .toList();
      expect(
        generated.map((level) => level.generationTemplate).toSet(),
        containsAll([
          'ramp-intro',
          'upper-drop-loaded-plank',
          'switch-gate-intro',
          'cat-intro',
          'dog-intro',
          'split-shelf-transfer',
          'springboard-handoff',
          'button-gate-u-route',
          'drop-pet-gate',
          'plank-switch-gate',
        ]),
      );
      expect(
        generated.any(
          (level) => level.objects.any((o) => o.kind == ObjectKind.ramp),
        ),
        isTrue,
      );
      final introducedKinds = generated
          .expand((level) => level.objects)
          .map((o) => o.kind)
          .toSet();
      expect(
        introducedKinds,
        containsAll([
          ObjectKind.ramp,
          ObjectKind.plank,
          ObjectKind.button,
          ObjectKind.gate,
          ObjectKind.cat,
          ObjectKind.dog,
        ]),
      );
      expect(
        generated
            .map((level) => level.objects.singleWhere((o) => o.starter).kind)
            .toSet(),
        contains(ObjectKind.domino),
      );
      final starterHeights = generated
          .map((level) => level.objects.singleWhere((o) => o.starter).y)
          .toSet();
      expect(starterHeights.length, greaterThan(2));
    },
  );

  test(
    'levels 21-30 present ten authored reasoning concepts and varied mechanics',
    () {
      final generated = allLevels
          .where((level) => level.id >= 21 && level.id <= 30)
          .toList();
      expect(
        generated.map((level) => level.generationTemplate).toSet(),
        containsAll([
          'junction-switchback-gate',
          'two-shelf-relay-gate',
          'false-switch-gate',
          'switch-before-spring',
          'branch-converge-gate',
          'crossing-pet-lanes',
          'falling-bridge-timing',
          'ramp-return-direction',
          'double-ramp-reversal',
          'gate-to-pet-relay',
        ]),
      );
      final kinds = generated
          .expand((level) => level.objects)
          .map((o) => o.kind)
          .toSet();
      expect(
        kinds,
        containsAll([
          ObjectKind.cat,
          ObjectKind.dog,
          ObjectKind.button,
          ObjectKind.gate,
          ObjectKind.ramp,
          ObjectKind.plank,
          ObjectKind.jumper,
        ]),
      );
      final difficulties = generated
          .map((level) => level.generationDifficulty!)
          .toList();
      expect(
        difficulties,
        orderedEquals(List.generate(10, (index) => index + 10)),
      );
    },
  );

  test('redesigned reasoning levels activate their route mechanics', () {
    final simulations = <int, ChainSimulation>{};
    for (final level in allLevels.where(
      (level) => level.id >= 21 && level.id <= 30,
    )) {
      final sim = ChainSimulation(level)..trigger();
      while (!sim.failed && sim.time < 30) {
        sim.advance(1 / 60);
      }
      expect(sim.targetHit, isTrue, reason: 'L${level.id}');
      expect(
        sim.fallenObjectCount,
        sim.totalDynamicObjects,
        reason: 'L${level.id}',
      );
      simulations[level.id] = sim;
    }
    PhysicsObject find(int levelId, ObjectKind kind) => simulations[levelId]!
        .objects
        .firstWhere((object) => object.spec.kind == kind);

    expect(find(23, ObjectKind.button).activated, isTrue);
    expect(find(23, ObjectKind.gate).open, isTrue);
    expect(find(21, ObjectKind.button).activated, isTrue);
    expect(find(21, ObjectKind.gate).open, isTrue);
    expect(find(24, ObjectKind.button).activated, isTrue);
    expect(find(24, ObjectKind.gate).open, isTrue);
    expect(find(24, ObjectKind.jumper).activated, isTrue);
    expect(find(26, ObjectKind.dog).activated, isTrue);
    expect(find(26, ObjectKind.cat).activated, isTrue);
    expect(find(26, ObjectKind.gate).open, isTrue);
    expect(find(27, ObjectKind.plank).hasFallen, isTrue);
    expect(find(30, ObjectKind.button).activated, isTrue);
    expect(find(30, ObjectKind.gate).open, isTrue);
    expect(find(30, ObjectKind.cat).activated, isTrue);
  });

  test(
    'level 24 direct ball tap misses the target and leaves its gate shut',
    () {
      final level = allLevels.singleWhere((item) => item.id == 24);
      final ball = level.objects.singleWhere(
        (item) => item.kind == ObjectKind.ball,
      );
      final sim = ChainSimulation(level);
      expect(sim.triggerAt(Vector2(ball.x, ball.y)), isTrue);
      while (!sim.failed && sim.time < 20) {
        sim.advance(1 / 60);
      }
      expect(sim.targetHit, isFalse);
      expect(
        sim.objects.firstWhere((object) => object.isButton).activated,
        isFalse,
      );
      expect(sim.objects.firstWhere((object) => object.isGate).open, isFalse);
    },
  );

  test('levels 11-20 have a named tutorial concept on every stage', () {
    final concepts = allLevels
        .where((level) => level.id >= 11 && level.id <= 20)
        .map((level) => level.generationTemplate)
        .toSet();
    expect(concepts, hasLength(10));
  });

  test('levels 11-20 teach and activate each new mechanic in sequence', () {
    final lessons = allLevels.where(
      (level) => level.id >= 11 && level.id <= 20,
    );
    final contactPairs = <int, Set<String>>{};
    final simulations = <int, ChainSimulation>{};
    for (final level in lessons) {
      final sim = ChainSimulation(level);
      final pairs = <String>{};
      sim.onImpact = (a, b, _, __) {
        if (b != null) pairs.add('${a.name}:${b.name}');
      };
      sim.trigger();
      while (!sim.failed && sim.time < 30) {
        sim.advance(1 / 60);
      }
      expect(sim.targetHit, isTrue, reason: 'L${level.id}');
      expect(
        sim.fallenObjectCount,
        sim.totalDynamicObjects,
        reason: 'L${level.id}',
      );
      contactPairs[level.id] = pairs;
      simulations[level.id] = sim;
    }

    PhysicsObject find(int levelId, ObjectKind kind) => simulations[levelId]!
        .objects
        .firstWhere((object) => object.spec.kind == kind);
    Set<ObjectKind> kinds(int levelId) => allLevels
        .singleWhere((level) => level.id == levelId)
        .objects
        .map((object) => object.kind)
        .toSet();

    expect(contactPairs[11], contains(contains(':ramp')));
    expect(find(12, ObjectKind.plank).hasFallen, isTrue);
    expect(find(13, ObjectKind.button).activated, isTrue);
    expect(find(13, ObjectKind.gate).open, isTrue);
    expect(kinds(13), isNot(contains(ObjectKind.cat)));
    expect(kinds(13), isNot(contains(ObjectKind.dog)));
    expect(find(14, ObjectKind.cat).activated, isTrue);
    expect(kinds(14), isNot(contains(ObjectKind.dog)));
    expect(kinds(14), isNot(contains(ObjectKind.gate)));
    expect(find(15, ObjectKind.dog).activated, isTrue);
    expect(kinds(15), isNot(contains(ObjectKind.cat)));
    expect(kinds(15), isNot(contains(ObjectKind.button)));
    expect(find(16, ObjectKind.box).hasFallen, isTrue);
    expect(find(16, ObjectKind.ball).hasFallen, isTrue);
    expect(find(17, ObjectKind.jumper).activated, isTrue);
    expect(find(18, ObjectKind.button).activated, isTrue);
    expect(find(18, ObjectKind.gate).open, isTrue);
    expect(find(19, ObjectKind.dog).activated, isTrue);
    expect(find(19, ObjectKind.cat).activated, isTrue);
    expect(find(19, ObjectKind.button).activated, isTrue);
    expect(find(19, ObjectKind.gate).open, isTrue);
    expect(find(20, ObjectKind.button).activated, isTrue);
    expect(find(20, ObjectKind.gate).open, isTrue);
    expect(find(20, ObjectKind.plank).hasFallen, isTrue);
  });

  test('levels 31-40 use individually named late-game route concepts', () {
    final generated = allLevels
        .where((level) => level.id >= 31 && level.id <= 40)
        .toList();
    expect(
      generated.map((level) => level.generationDifficulty!),
      orderedEquals(List.generate(10, (index) => index + 11)),
    );
    expect(
      generated.map((level) => level.generationTemplate).toSet(),
      containsAll([
        'switch-gate-bend',
        'reverse-two-tier',
        'spring-left-target',
        'pet-counterflow',
        'plank-after-drop',
        'ramp-fork-choice',
        'plank-switch-sequence',
        'ramp-switchback',
        'up-across-back',
        'three-consequence-finale',
      ]),
    );
  });

  test('late-game mechanic routes activate their authored chain pieces', () {
    final sims = <int, ChainSimulation>{};
    for (final level in allLevels.where((level) => level.id >= 31)) {
      final sim = ChainSimulation(level)..trigger();
      while (!sim.failed && sim.time < 30) {
        sim.advance(1 / 60);
      }
      expect(sim.targetHit, isTrue, reason: 'L${level.id}');
      expect(
        sim.fallenObjectCount,
        sim.totalDynamicObjects,
        reason: 'L${level.id}',
      );
      sims[level.id] = sim;
    }
    PhysicsObject find(int id, ObjectKind kind) =>
        sims[id]!.objects.firstWhere((object) => object.spec.kind == kind);

    expect(find(31, ObjectKind.button).activated, isTrue);
    expect(find(31, ObjectKind.gate).open, isTrue);
    expect(find(32, ObjectKind.button).activated, isTrue);
    expect(find(32, ObjectKind.gate).open, isTrue);
    expect(find(33, ObjectKind.jumper).activated, isTrue);
    expect(find(34, ObjectKind.dog).activated, isTrue);
    expect(find(34, ObjectKind.cat).activated, isTrue);
    expect(find(34, ObjectKind.gate).open, isTrue);
    expect(find(35, ObjectKind.plank).hasFallen, isTrue);
    expect(find(36, ObjectKind.button).activated, isTrue);
    expect(find(36, ObjectKind.gate).open, isTrue);
    expect(find(37, ObjectKind.plank).hasFallen, isTrue);
    expect(find(37, ObjectKind.button).activated, isTrue);
    expect(find(37, ObjectKind.gate).open, isTrue);
    expect(find(39, ObjectKind.jumper).activated, isTrue);
    expect(find(38, ObjectKind.button).activated, isTrue);
    expect(find(38, ObjectKind.gate).open, isTrue);
    expect(find(40, ObjectKind.button).activated, isTrue);
    expect(find(40, ObjectKind.gate).open, isTrue);
    expect(find(40, ObjectKind.dog).activated, isTrue);
    expect(find(40, ObjectKind.cat).activated, isTrue);
  });

  test('late-game decoy taps run physics but miss the target', () {
    bool targetWins(int levelId, ObjectKind tapKind) {
      final level = allLevels.singleWhere((item) => item.id == levelId);
      final tap = level.objects.firstWhere(
        (item) => item.kind == tapKind && !item.starter,
      );
      final sim = ChainSimulation(level);
      expect(
        sim.triggerAt(Vector2(tap.x, tap.y)),
        isTrue,
        reason: 'L$levelId tap $tapKind',
      );
      while (!sim.failed && sim.time < 30) {
        sim.advance(1 / 60);
      }
      return sim.targetHit;
    }

    expect(targetWins(31, ObjectKind.ball), isFalse);
    expect(targetWins(33, ObjectKind.ball), isFalse);
    expect(targetWins(36, ObjectKind.ball), isFalse);
    expect(targetWins(37, ObjectKind.ball), isFalse);
  });

  test('there are forty levels with exactly one default starter each', () {
    expect(allLevels.length, 40);
    for (final l in allLevels) {
      expect(l.objects.where((o) => o.starter).length, 1, reason: 'L${l.id}');
    }
  });

  test('all tap choices are audited by full level completion', () {
    // Full completion means the target is hit and every dynamic object is
    // touched; a target-only tap can still end the level with partial score.
    for (final level in allLevels) {
      expect(level.validateTapConfiguration(), isEmpty, reason: 'L${level.id}');
      final report = auditTapChoices(level);
      // ignore: avoid_print
      print(
        'tap-audit L${level.id}: target=${report.successfulTaps} '
        'full=${report.fullTouchSolutions}/${report.outcomes.length}',
      );
      if (level.id == 21) {
        expect(report.outcomes, hasLength(7));
        expect(report.successfulTaps, 1);
        expect(report.failedTaps, 6);
        expect(report.format(), contains('- junction_box (box)'));
        expect(report.format(), contains('- upper_ball (ball)'));
      }
    }
  });

  test('a level allowlist blocks direct taps without blocking physics', () {
    final source = allLevels.singleWhere((item) => item.id == 21);
    final level = LevelConfig(
      id: source.id,
      name: source.name,
      hint: source.hint,
      theme: source.theme,
      baseReward: source.baseReward,
      objects: source.objects,
      tapCandidates: const {'junction_box', 'upper_ball'},
      tapChoiceProfile: TapChoiceProfile.exact,
    );
    expect(level.tapCandidateIndices, hasLength(2));
    final audit = auditTapChoices(level);
    expect(audit.physicsOnlyObjects, hasLength(5));
    expect(audit.successfulTaps, 1);

    final domino = level.objects.firstWhere(
      (item) => item.kind == ObjectKind.domino,
    );
    final sim = ChainSimulation(level);
    expect(sim.triggerAt(Vector2(domino.x, domino.y)), isFalse);
    expect(sim.triggered, isFalse);

    final starter = level.objects.singleWhere((item) => item.starter);
    expect(sim.triggerAt(Vector2(starter.x, starter.y)), isTrue);
    while (!sim.failed && sim.time < 35) {
      sim.advance(1 / 60);
    }
    expect(sim.targetHit, isTrue);
    expect(sim.allDynamicObjectsTouched, isTrue);
    expect(sim.starter.playerTapped, isTrue);
    final physicsOnlyDomino = sim.objects.firstWhere(
      (object) => object.spec.kind == ObjectKind.domino,
    );
    expect(physicsOnlyDomino.playerTapped, isFalse);
    expect(physicsOnlyDomino.physicsActivated, isTrue);
  });

  test(
    'level 21 wrong starters run decoy chains without reaching the target',
    () {
      final level = allLevels.singleWhere((item) => item.id == 21);
      final starter = level.objects.singleWhere((item) => item.starter);
      final decoys = level.objects.where(
        (item) => item.isDynamic && !item.starter,
      );
      expect(decoys, hasLength(6));

      final winning = ChainSimulation(level);
      expect(winning.triggerAt(Vector2(starter.x, starter.y)), isTrue);
      while (!winning.failed && winning.time < 35) {
        winning.advance(1 / 60);
      }
      expect(winning.targetHit, isTrue);
      expect(winning.allDynamicObjectsTouched, isTrue);
      expect(
        winning.objects.firstWhere((object) => object.isGate).open,
        isTrue,
      );

      for (final decoy in decoys) {
        final sim = ChainSimulation(level);
        var impacts = 0;
        sim.onImpact = (_, __, ___, ____) => impacts++;
        expect(sim.triggerAt(Vector2(decoy.x, decoy.y)), isTrue);
        while (!sim.failed && sim.time < 35) {
          sim.advance(1 / 60);
        }
        expect(
          sim.targetHit,
          isFalse,
          reason: 'tap ${decoy.kind} at ${decoy.x}',
        );
        expect(sim.allDynamicObjectsTouched, isTrue);
        expect(impacts, greaterThan(0));
      }
    },
  );

  test('advanced single-winner levels make wrong taps run decoy chains', () {
    for (final level in allLevels.where(
      (item) => item.id == 13 || item.id == 35,
    )) {
      final dynamics = level.objects.where((item) => item.isDynamic).toList();
      final starter = dynamics.singleWhere((item) => item.starter);
      var targetWins = 0;

      for (final tapped in dynamics) {
        final sim = ChainSimulation(level);
        var impacts = 0;
        sim.onImpact = (_, __, ___, ____) => impacts++;
        expect(sim.triggerAt(Vector2(tapped.x, tapped.y)), isTrue);
        while (!sim.failed && sim.time < 35) {
          sim.advance(1 / 60);
        }
        if (sim.targetHit) targetWins++;

        if (!identical(tapped, starter)) {
          expect(sim.targetHit, isFalse, reason: 'L${level.id} ${tapped.kind}');
          expect(sim.touchedObjectCount, greaterThan(1));
          expect(impacts, greaterThan(0));
        }
      }
      expect(targetWins, 1, reason: 'L${level.id} must have one winning tap');
    }
  });

  for (final level in allLevels) {
    test('level ${level.id} reaches the target smoothly', () {
      final o = run(level);
      // ignore: avoid_print
      print(
        'L${level.id} hit=${o.hit} t=${o.time.toStringAsFixed(2)} '
        'lull=${o.longestLull.toStringAsFixed(2)} '
        'fallen=${o.fallen}/${o.total} settled=${o.settled}',
      );
      if (!o.hit || o.fallen != o.total) {
        // ignore: avoid_print
        print(o.details.join('\n'));
        if (o.trace.isNotEmpty) {
          // ignore: avoid_print
          print(o.trace.join('\n'));
        }
      }
      expect(o.hit, isTrue);
      expect(o.settled, isTrue, reason: 'L${level.id} never settled');
      expect(
        o.fallen,
        o.total,
        reason: 'L${level.id} fell ${o.fallen}/${o.total} objects',
      );
      expect(
        o.longestLull,
        lessThan(
          level.id >= 31
              ? 3.0
              : const {17, 19, 24, 25, 28}.contains(level.id)
              ? 3.0
              : 2.0,
        ),
        reason: 'chain stalls too long',
      );
      expect(o.time, lessThan(25));
    });

    test('level ${level.id} is deterministic', () {
      final a = run(level);
      final b = run(level);
      expect(a.time, b.time);
      expect(a.snapshot, b.snapshot);
    });

    // Small device-to-device differences must not break the chain.
    for (final k in [0.92, 1.08]) {
      test('level ${level.id} tolerates push x$k', () {
        expect(run(withPush(level, k)).settled, isTrue);
      });
    }
  }
}
