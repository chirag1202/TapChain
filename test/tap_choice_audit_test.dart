import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/level_generator.dart';
import 'package:tapchain/game/levels/levels.dart';

void main() {
  test('audits configured tap choices for Levels 11-40', () {
    for (final level in allLevels.where((item) => item.id >= 11)) {
      final report = auditTapChoices(level);
      // ignore: avoid_print
      print(report.format());
      expect(level.validateTapConfiguration(), isEmpty, reason: 'L${level.id}');
      expect(
        report.outcomes.every((outcome) => outcome.settled),
        isTrue,
        reason: 'L${level.id} did not settle for every candidate',
      );
    }
  });
}
