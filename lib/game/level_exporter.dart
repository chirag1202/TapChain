import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' show Color, Offset;

import 'level_config.dart';
import 'level_generator.dart';

/// Exports a vetted candidate as a normal Dart level definition.
///
/// Place the resulting file in `lib/game/levels/generated/`; its relative
/// import points back to the existing shared LevelConfig and object factories.
class LevelExporter {
  const LevelExporter();

  String toDart(GeneratedCandidate candidate) {
    if (!candidate.valid) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'Only vetted levels can be exported.',
      );
    }
    final generated = candidate.definition;
    final level = generated.level;
    final variable = _identifier(level.name);
    final theme = level.theme;
    final output = StringBuffer()
      ..writeln("import 'dart:ui';")
      ..writeln("import '../../level_config.dart';")
      ..writeln()
      ..writeln('const _generatedTheme = LevelTheme(')
      ..writeln('  id: ThemeId.${theme.id.name},')
      ..writeln('  name: ${_quote(theme.name)},')
      ..writeln('  emoji: ${_quote(theme.emoji)},')
      ..writeln('  skyTop: ${_color(theme.skyTop)},')
      ..writeln('  skyBottom: ${_color(theme.skyBottom)},')
      ..writeln('  ground: ${_color(theme.ground)},')
      ..writeln('  groundTop: ${_color(theme.groundTop)},')
      ..writeln('  platform: ${_color(theme.platform)},')
      ..writeln('  platformEdge: ${_color(theme.platformEdge)},')
      ..writeln('  domino: ${_color(theme.domino)},')
      ..writeln('  dominoDot: ${_color(theme.dominoDot)},')
      ..writeln('  ball: ${_color(theme.ball)},')
      ..writeln('  box: ${_color(theme.box)},')
      ..writeln('  boxEdge: ${_color(theme.boxEdge)},')
      ..writeln('  target: ${_color(theme.target)},')
      ..writeln('  accent: ${_color(theme.accent)},')
      ..writeln('  glow: ${theme.glow},')
      ..writeln(');')
      ..writeln()
      ..writeln('final $variable = LevelConfig(')
      ..writeln('  id: ${level.id},')
      ..writeln('  name: ${_quote(level.name)},')
      ..writeln('  hint: ${_quote(level.hint)},')
      ..writeln('  theme: _generatedTheme,')
      ..writeln('  baseReward: ${level.baseReward},')
      ..writeln('  generatorVersion: ${generated.level.generatorVersion},')
      ..writeln('  generationSeed: ${generated.seed},')
      ..writeln('  generationTemplate: ${_quote(generated.template)},')
      ..writeln('  generationDifficulty: ${generated.difficulty},')
      ..writeln('  complexityScore: ${generated.complexityScore},')
      ..writeln('  objects: [');
    for (final object in level.objects) {
      output.writeln('    ${_object(object)},');
    }
    output
      ..writeln('  ],')
      ..writeln(');');
    return output.toString();
  }

  Future<File> writeDartFile(
    GeneratedCandidate candidate,
    File destination,
  ) async {
    await destination.parent.create(recursive: true);
    return destination.writeAsString(toDart(candidate));
  }

  String _object(ObjectSpec object) {
    final starter = object.starter ? ', starter: true' : '';
    final push = object.push == Offset.zero
        ? ''
        : ', push: Offset(${object.push.dx}, ${object.push.dy})';
    return switch (object.kind) {
      ObjectKind.domino =>
        'ObjectSpec.domino(${object.x}, ${object.y + object.h / 2}, '
            'h: ${object.h}, angle: ${object.angle}$starter$push)',
      ObjectKind.ball =>
        'ObjectSpec.ball(${object.x}, ${object.y + object.radius}, '
            'radius: ${object.radius}$starter$push)',
      ObjectKind.box =>
        'ObjectSpec.box(${object.x}, ${object.y + object.h / 2}, '
            'w: ${object.w}, h: ${object.h}$starter$push)',
      ObjectKind.platform =>
        'ObjectSpec.platform('
            '${object.x + object.h / 2 * _sin(object.angle)}, '
            '${object.y - object.h / 2 * _cos(object.angle)}, ${object.w}, '
            'h: ${object.h}, angle: ${object.angle})',
      ObjectKind.jumper =>
        'ObjectSpec.jumper(${object.x}, ${object.y + object.h / 2}, '
            'w: ${object.w}, h: ${object.h}, direction: ${object.direction}, '
            'launchVelocity: ${object.launchVelocity}, launchSpeed: ${object.launchSpeed})',
      ObjectKind.target =>
        'ObjectSpec.target(${object.x}, ${object.y + object.radius}, '
            'radius: ${object.radius})',
      ObjectKind.cat => 'ObjectSpec.cat(${object.x}, ${object.y + object.h / 2}, direction: ${object.direction})',
      ObjectKind.dog => 'ObjectSpec.dog(${object.x}, ${object.y + object.h / 2}, direction: ${object.direction})',
      ObjectKind.ramp => 'ObjectSpec.ramp(${object.x}, ${object.y}, ${object.w}, h: ${object.h}, angle: ${object.angle})',
      ObjectKind.button => 'ObjectSpec.button(${object.x}, ${object.y}, w: ${object.w}, h: ${object.h}, id: ${object.id == null ? 'null' : _quote(object.id!)}, linkedTargetId: ${object.linkedTargetId == null ? 'null' : _quote(object.linkedTargetId!)})',
      ObjectKind.gate => 'ObjectSpec.gate(${object.x}, ${object.y}, w: ${object.w}, h: ${object.h}, id: ${object.id == null ? 'null' : _quote(object.id!)})',
      ObjectKind.plank => 'ObjectSpec.plank(${object.x}, ${object.y + object.h / 2}, length: ${object.w}, h: ${object.h}, angle: ${object.angle}$starter$push)',
    };
  }

  String _identifier(String value) {
    final words = value
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    final suffix = words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join();
    return 'level${suffix.isEmpty ? 'Generated' : suffix}';
  }

  String _quote(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r');
    return "'$escaped'";
  }

  String _color(Color color) =>
      'Color(0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';

  double _sin(double angle) => math.sin(angle);
  double _cos(double angle) => math.cos(angle);
}
