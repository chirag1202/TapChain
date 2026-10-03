import '../level_config.dart';
import 'level_1.dart';
import 'level_2.dart';
import 'level_3.dart';
import 'level_4.dart';
import 'level_5.dart';
import 'level_6.dart';
import 'level_7.dart';
import 'level_8.dart';
import 'level_9.dart';
import 'level_10.dart';
import 'mechanics_tutorial_levels.dart';
import 'reasoning_levels.dart';
import 'late_game_levels.dart';

final List<LevelConfig> allLevels = [
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level7,
  level8,
  level9,
  level10,
  ...mechanicTutorialLevels,
  ...reasoningPuzzleLevels,
  ...lateGameLevels,
];
