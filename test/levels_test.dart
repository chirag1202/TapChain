import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_config.dart';
import 'package:tapchain/game/levels/levels.dart';

class Outcome {
  Outcome(this.hit, this.time, this.snapshot, this.longestLull);
  final bool hit;
  final double time;
  final List<double> snapshot;

  /// Longest stretch (seconds) where nothing moved faster than 0.5 m/s.
  final double longestLull;
}

Outcome run(LevelConfig level) {
  final sim = ChainSimulation(level);
  sim.trigger();
  var lull = 0.0;
  var longest = 0.0;
  while (!sim.targetHit && !sim.failed) {
    sim.advance(1 / 60);
    var fastest = 0.0;
    for (final o in sim.objects) {
      if (o.spec.isDynamic && !o.gone) {
        fastest = math.max(fastest, o.body.linearVelocity.length);
      }
    }
    lull = fastest < 0.5 ? lull + 1 / 60 : 0;
    longest = math.max(longest, lull);
  }
  return Outcome(sim.targetHit, sim.targetHit ? sim.hitTime : sim.time, [
    for (final o in sim.objects) ...[o.body.position.x, o.body.position.y],
  ], longest);
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
  test('there are ten levels with exactly one default starter each', () {
    expect(allLevels.length, 10);
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
        'lull=${o.longestLull.toStringAsFixed(2)}',
      );
      expect(o.hit, isTrue);
      expect(o.longestLull, lessThan(0.8), reason: 'chain stalls too long');
      expect(o.time, lessThan(12));
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
        expect(run(withPush(level, k)).hit, isTrue);
      });
    }
  }
}
