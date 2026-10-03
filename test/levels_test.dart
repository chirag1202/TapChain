import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_config.dart';
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
  test('levels 11-20 vary mechanics, slopes, jumpers, and tap height', () {
    final generated = allLevels.where((level) => level.id >= 11 && level.id <= 20).toList();
    expect(
      generated.map((level) => level.generationTemplate).toSet(),
      containsAll(['slope', 'jumper', 'cascade', 'mechanism']),
    );
    expect(generated.any((level) => level.objects.any((o) => o.kind == ObjectKind.jumper)), isTrue);
    expect(
      generated.any((level) => level.objects.any((o) => o.kind == ObjectKind.platform && o.angle.abs() > 0.1)),
      isTrue,
    );
    expect(
      generated.map((level) => level.objects.singleWhere((o) => o.starter).kind).toSet(),
      contains(ObjectKind.domino),
    );
    final starterHeights = generated
        .map((level) => level.objects.singleWhere((o) => o.starter).y)
        .toSet();
    expect(starterHeights.length, greaterThan(3));
  });

  test('levels 21-30 continue varying puzzles while exposing test objects', () {
    final generated = allLevels.where((level) => level.id >= 21 && level.id <= 30).toList();
    expect(
      generated.map((level) => level.generationTemplate).toSet(),
      containsAll(['mechanism', 'slope', 'jumper', 'cascade']),
    );
    final kinds = generated.expand((level) => level.objects).map((o) => o.kind).toSet();
    expect(kinds, containsAll([
      ObjectKind.cat,
      ObjectKind.dog,
      ObjectKind.button,
      ObjectKind.gate,
      ObjectKind.ramp,
      ObjectKind.plank,
      ObjectKind.jumper,
    ]));
    final difficulties = generated.map((level) => level.generationDifficulty!).toList();
    expect(difficulties, orderedEquals(List.generate(10, (index) => index + 10)));
  });

  test('levels 12-30 raise difficulty across six varied route types', () {
    final generated = allLevels.where((level) => level.id >= 12 && level.id <= 30).toList();
    expect(
      generated.map((level) => level.generationDifficulty!),
      orderedEquals(List.generate(19, (index) => index + 1)),
    );
    expect(
      generated.map((level) => level.generationTemplate).toSet(),
      containsAll(['slope', 'jumper', 'mechanism', 'cascade', 'drop', 'spring']),
    );
  });

  test('there are thirty levels with exactly one default starter each', () {
    expect(allLevels.length, 30);
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
