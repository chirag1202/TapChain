import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapchain/game/level_config.dart';
import 'package:tapchain/game/level_exporter.dart';
import 'package:tapchain/game/level_generator.dart';
import 'package:tapchain/game/levels/level_1.dart' show gardenTheme;
import 'package:tapchain/game/levels/level_2.dart' show workshopTheme;
import 'package:tapchain/game/levels/level_3.dart' show constructionTheme;
import 'package:tapchain/game/levels/level_4.dart' show neonTheme;
import 'package:tapchain/game/levels/level_5.dart' show spaceTheme;
import 'package:tapchain/game/levels/level_6.dart' show oceanTheme;
import 'package:tapchain/game/levels/level_7.dart' show volcanoTheme;

const _count = int.fromEnvironment('TAPCHAIN_COUNT', defaultValue: 10);
const _difficulty = int.fromEnvironment('TAPCHAIN_DIFFICULTY', defaultValue: 1);
const _seed = int.fromEnvironment('TAPCHAIN_SEED', defaultValue: 847291);
const _firstLevelId = int.fromEnvironment(
  'TAPCHAIN_FIRST_LEVEL_ID',
  defaultValue: 11,
);
const _themeName = String.fromEnvironment(
  'TAPCHAIN_THEME',
  defaultValue: 'neon',
);
const _templateName = String.fromEnvironment(
  'TAPCHAIN_TEMPLATE',
  defaultValue: 'cascade',
);
const _progressiveDifficulty = bool.fromEnvironment(
  'TAPCHAIN_PROGRESSIVE',
  defaultValue: true,
);

const _themes = <String, LevelTheme>{
  'garden': gardenTheme,
  'workshop': workshopTheme,
  'construction': constructionTheme,
  'neon': neonTheme,
  'space': spaceTheme,
  'ocean': oceanTheme,
  'volcano': volcanoTheme,
};

/// Developer command:
/// `flutter test tool/generate_levels_test.dart --dart-define=...`
///
/// Generated Dart levels are written under `lib/game/levels/generated/` and
/// can be added to `levels.dart` after review. Normal test runs do not discover
/// this tool because it lives outside the `test/` directory.
void main() {
  test('generate and export validated levels', () async {
    final theme = _themes[_themeName.toLowerCase()];
    if (theme == null) {
      fail(
        'Unknown TAPCHAIN_THEME "$_themeName". Use ${_themes.keys.join(', ')}.',
      );
    }
    final template = LevelTemplate.values.where(
      (value) => value.name == _templateName,
    );
    if (template.isEmpty) {
      fail(
        'Unknown TAPCHAIN_TEMPLATE "$_templateName". Use auto, simpleRelay, drop, spring, or cascade.',
      );
    }

    final result = const LevelGenerator().generateLevels(
      LevelGenerationRequest(
        count: _count,
        difficulty: _difficulty,
        seed: _seed,
        theme: theme,
        template: template.single,
        firstLevelId: _firstLevelId,
        progressiveDifficulty: _progressiveDifficulty,
      ),
    );
    expect(
      result.candidates,
      hasLength(_count),
      reason:
          'Generated ${result.candidates.length}/$_count after '
          '${result.attempts} attempts. Rejections: ${result.rejections}',
    );

    final outputDirectory = Directory('lib/game/levels/generated');
    await outputDirectory.create(recursive: true);
    const exporter = LevelExporter();
    for (var index = 0; index < result.candidates.length; index++) {
      final candidate = result.candidates[index];
      final templateFileName = candidate.definition.template.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match[0]!.toLowerCase()}',
      );
      final file = File(
        '${outputDirectory.path}${Platform.pathSeparator}'
        'level_${candidate.definition.level.id}_'
        '${templateFileName}_${candidate.definition.seed}.dart',
      );
      await exporter.writeDartFile(candidate, file);
      // ignore: avoid_print
      print(
        'PASS ${candidate.definition.level.name}: '
        'seed=${candidate.definition.seed}, '
        'difficulty=${candidate.definition.difficulty}, '
        'complexity=${candidate.definition.complexityScore.toStringAsFixed(1)}, '
        'physics=${candidate.physics.interactionCount} interactions, '
        'settled=${candidate.physics.settleTime.toStringAsFixed(2)}s -> ${file.path}',
      );
    }
  });
}
