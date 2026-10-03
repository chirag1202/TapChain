import 'dart:ui';
import '../../level_config.dart';

const _generatedTheme = LevelTheme(
  id: ThemeId.neon,
  name: 'Neon Night',
  emoji: '🌃',
  skyTop: Color(0xFF07072B),
  skyBottom: Color(0xFF3A0CA3),
  ground: Color(0xFF14143F),
  groundTop: Color(0xFF00F5D4),
  platform: Color(0xFF12123A),
  platformEdge: Color(0xFF00F5D4),
  domino: Color(0xFFFF2E93),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFF00E5FF),
  box: Color(0xFFB5179E),
  boxEdge: Color(0xFFF72585),
  target: Color(0xFFFFEE32),
  accent: Color(0xFF00F5D4),
  glow: true,
);

final levelGeneratedJumper7 = LevelConfig(
  id: 30,
  name: 'Generated Jumper 7',
  hint: 'Start the ball midway and launch it up to the target.',
  theme: _generatedTheme,
  baseReward: 200,
  generatorVersion: 1,
  generationSeed: 819605975,
  generationTemplate: 'jumper',
  generationDifficulty: 10,
  complexityScore: 10.0,
  objects: [
    ObjectSpec.platform(2.0, 9.3, 3.8, h: 0.3, angle: 0.0),
    ObjectSpec.domino(1.4500000000000002, 9.3, h: 1.0, angle: 0.0, starter: true, push: Offset(0.35, 0.0)),
    ObjectSpec.domino(1.9500000000000002, 9.3, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.45, 9.3, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.95, 9.3, h: 1.0, angle: 0.0),
    ObjectSpec.ball(3.55, 9.3, radius: 0.35),
    ObjectSpec.jumper(6.0, 14.0, w: 1.2, h: 0.36, direction: 1.0, launchVelocity: -15.0, launchSpeed: 1.7),
    ObjectSpec.platform(8.1, 7.2, 1.8, h: 0.3, angle: 0.0),
    ObjectSpec.domino(8.4, 7.2, h: 1.0, angle: 0.0),
    ObjectSpec.domino(7.9, 7.2, h: 1.0, angle: 0.0),
    ObjectSpec.domino(7.4, 7.2, h: 1.0, angle: 0.0),
    ObjectSpec.target(6.4, 7.200000000000001, radius: 0.48),
  ],
);
