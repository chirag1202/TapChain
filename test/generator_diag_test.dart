import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/chain_simulation.dart';
import 'package:tapchain/game/level_config.dart';
import 'package:tapchain/game/levels/level_6.dart';

LevelConfig layout(int difficulty) {
  final groundExtra = difficulty <= 6 ? difficulty : 6;
  final upperExtra = difficulty <= 6 ? 0 : difficulty - 6;
  final targetX = 4.2 - (groundExtra - 1) * 0.6;
  final upperCount = 4 + upperExtra;
  final ballX = 1.55 + (upperCount - 1) * 0.6 + 0.8;
  final platformRight = ballX + 0.35;
  final objects = [
    for (final o in level6.objects)
      if (!(o.kind == ObjectKind.platform && o.y < 9) &&
          !(o.kind == ObjectKind.domino && o.y < 9 && !o.starter) &&
          !(o.kind == ObjectKind.ball && o.y < 9) &&
          o.kind != ObjectKind.target)
        o,
    ObjectSpec.platform((0.2 + platformRight) / 2, 8.0, platformRight - 0.2),
    ...ObjectSpec.dominoRow(
      fromX: 1.55,
      surfaceY: 8.0,
      count: upperCount,
      spacing: 0.6,
    ),
    ObjectSpec.ball(ballX, 8.0),
    ...ObjectSpec.dominoRow(
      fromX: 5.0,
      surfaceY: kGroundY,
      count: groundExtra,
      spacing: -0.6,
    ),
    ObjectSpec.target(targetX, kGroundY, radius: 0.48),
  ];
  return LevelConfig(
    id: difficulty,
    name: 'diag',
    hint: '',
    theme: oceanTheme,
    baseReward: 1,
    objects: objects,
  );
}

void main() {
  test('check progressive cascade layouts', () {
    for (var difficulty = 1; difficulty <= 10; difficulty++) {
      final sim = ChainSimulation(layout(difficulty))..trigger();
      while (!sim.failed && sim.time < 45) {
        sim.advance(1 / 60);
      }
      // ignore: avoid_print
      print(
        'd=$difficulty hit=${sim.targetHit} '
        '${sim.fallenObjectCount}/${sim.totalDynamicObjects}',
      );
    }
  });
}
