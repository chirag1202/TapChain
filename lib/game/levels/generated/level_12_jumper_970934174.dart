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

final levelGeneratedJumper2 = LevelConfig(
  id: 12,
  name: 'Generated Jumper 2',
  hint: 'Start the ball midway and launch it up to the target.',
  theme: _generatedTheme,
  baseReward: 120,
  generatorVersion: 1,
  generationSeed: 970934174,
  generationTemplate: 'jumper',
  generationDifficulty: 2,
  complexityScore: 2.0,
  objects: [
    ObjectSpec.platform(6.95, 9.3, 3.7239999999999998, h: 0.3, angle: -0.0),
    ObjectSpec.domino(7.489, 9.3, h: 1.0, angle: -0.0, starter: true, push: Offset(-0.35, 0.0)),
    ObjectSpec.domino(6.999, 9.3, h: 1.0, angle: -0.0),
    ObjectSpec.domino(6.509, 9.3, h: 1.0, angle: -0.0),
    ObjectSpec.domino(6.019, 9.3, h: 1.0, angle: -0.0),
    ObjectSpec.ball(5.431, 9.3, radius: 0.35),
    ObjectSpec.jumper(3.0300000000000002, 14.0, w: 1.176, h: 0.36, direction: -1.0, launchVelocity: -15.0, launchSpeed: 1.7),
    ObjectSpec.platform(0.9720000000000013, 7.2, 1.764, h: 0.3, angle: -0.0),
    ObjectSpec.domino(0.6780000000000008, 7.2, h: 1.0, angle: -0.0),
    ObjectSpec.domino(1.1679999999999993, 7.2, h: 1.0, angle: -0.0),
    ObjectSpec.domino(1.6579999999999995, 7.2, h: 1.0, angle: -0.0),
    ObjectSpec.target(2.638, 7.200000000000001, radius: 0.48),
  ],
);
