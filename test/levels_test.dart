import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_config.dart';
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
          'plank-intro',
          'switch-gate-intro',
          'cat-intro',
          'dog-intro',
          'switch-gate-sequence',
          'ramp-return',
          'cat-switch-gate',
          'dog-cat-switch-gate',
          'mechanics-combo',
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
          'junction-choice',
          'reverse-entry',
          'switchback-gate',
          'spring-return',
          'falling-branch',
          'pet-relay',
          'plank-switch',
          'decoy-height',
          'ramp-transfer',
          'sequence-prediction',
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
    expect(kinds(12), {ObjectKind.plank, ObjectKind.target});
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
    expect(find(16, ObjectKind.button).activated, isTrue);
    expect(find(16, ObjectKind.gate).open, isTrue);
    expect(contactPairs[17], contains(contains(':ramp')));
    expect(find(18, ObjectKind.cat).activated, isTrue);
    expect(find(18, ObjectKind.gate).open, isTrue);
    expect(find(19, ObjectKind.dog).activated, isTrue);
    expect(find(19, ObjectKind.cat).activated, isTrue);
    expect(find(20, ObjectKind.dog).activated, isTrue);
    expect(find(20, ObjectKind.cat).activated, isTrue);
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
        'forked-descent',
        'spring-return',
        'reverse-relay',
        'switchback',
        'two-tier-transfer',
        'springboard-return',
        'cross-lane',
        'compact-chain',
        'high-drop',
        'final-cascade',
      ]),
    );
  });

  test('there are forty levels with exactly one default starter each', () {
    expect(allLevels.length, 40);
    for (final l in allLevels) {
      expect(l.objects.where((o) => o.starter).length, 1, reason: 'L${l.id}');
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
      expect(o.longestLull, lessThan(2.0), reason: 'chain stalls too long');
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
