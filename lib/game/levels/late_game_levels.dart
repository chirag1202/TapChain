import '../level_config.dart';
import 'level_1.dart' show level1;
import 'level_2.dart' show level2;
import 'level_3.dart' show level3;
import 'level_4.dart' show level4;
import 'level_5.dart' show level5;
import 'level_6.dart' show level6;
import 'level_7.dart' show level7;
import 'level_8.dart' show level8;
import 'level_9.dart' show level9;
import 'level_10.dart' show level10;

// The final chapter revisits the game's route families in a mixed order so
// players must inspect each layout instead of learning a repeating template.
final List<LevelConfig> lateGameLevels = [
  _stage(
    level6,
    31,
    'Forked Descent',
    'Read both drops before the lower return.',
    'forked-descent',
  ),
  _stage(
    level9,
    32,
    'Spring Return',
    'Predict where the spring will send the ball.',
    'spring-return',
  ),
  _stage(
    level4,
    33,
    'Reverse Relay',
    'The starter is on the far side; follow the route back.',
    'reverse-relay',
  ),
  _stage(
    level7,
    34,
    'Lava Switchback',
    'Trace the alternating platforms from right to left.',
    'switchback',
  ),
  _stage(
    level3,
    35,
    'Two-Tier Transfer',
    'The upper run must feed the lower platform.',
    'two-tier-transfer',
  ),
  _stage(
    level10,
    36,
    'Springboard Return',
    'Read the drop onto the spring, then the elevated lane.',
    'springboard-return',
  ),
  _stage(
    level8,
    37,
    'Long Crosscurrent',
    'Start low and follow the ball along the cross-lane.',
    'cross-lane',
  ),
  _stage(
    level5,
    38,
    'Compact Chain',
    'A short tap must topple the full row.',
    'compact-chain',
  ),
  _stage(
    level2,
    39,
    'High Drop',
    'Follow the ball from the first ledge to the target shelf.',
    'high-drop',
  ),
  _stage(
    level1,
    40,
    'Final Cascade',
    'Find the starter and predict the final contact.',
    'final-cascade',
  ),
];

LevelConfig _stage(
  LevelConfig source,
  int id,
  String name,
  String hint,
  String concept,
) => LevelConfig(
  id: id,
  name: name,
  hint: hint,
  theme: source.theme,
  baseReward: 600 + (id - 31) * 20,
  generationTemplate: concept,
  generationDifficulty: id - 20,
  complexityScore: (id - 20).toDouble(),
  objects: source.objects,
);
