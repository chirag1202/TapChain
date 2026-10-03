import 'package:flutter/painting.dart';

import '../level_config.dart';
import 'level_6.dart' show oceanTheme;
import 'level_7.dart' show volcanoTheme;

// Authored reasoning stages. Each layout asks the player to read a different
// route: side entry, split heights, a switch, a spring, or a reversed relay.
final List<LevelConfig> reasoningPuzzleLevels = [
  // ─────────────────────────────────────────────────────────────────────────
  // Level 21 – Junction Switchback  [RETAIN – Phase 1: add LevelDesignSpec]
  // tapCandidates already explicit (model level). Only LevelDesignSpec added.
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 21,
    tapChoiceProfile: TapChoiceProfile.exact,
    tapCandidates: const {
      'junction_box',
      'upper_ball',
      'shelf_domino_1',
      'shelf_domino_2',
      'shelf_domino_3',
      'shelf_domino_4',
      'return_ball',
    },
    name: 'Junction Switchback',
    hint:
        'The box must send the upper ball through the switch before the shelf transfers reach the gate.',
    theme: oceanTheme,
    baseReward: 420,
    generationTemplate: 'junction-switchback-gate',
    generationDifficulty: 10,
    complexityScore: 10,
    design: const LevelDesignSpec(
      idea: 'The junction_box starter pushes upper_ball rightward into the '
          'button, opening the gate. Meanwhile the shelf dominoes topple leftward, '
          'return_ball rolls left and passes through the now-open gate to the target.',
      intendedTapIds: ['junction_box'],
      decoys: [
        'upper_ball', 'shelf_domino_1', 'shelf_domino_2',
        'shelf_domino_3', 'shelf_domino_4', 'return_ball',
      ],
      chain: [
        'junction_box', 'upper_ball', 's21', 'g21',
        'shelf_domino_1', 'shelf_domino_2', 'shelf_domino_3', 'shelf_domino_4',
        'return_ball', 'target_1',
      ],
      reasoningPrompt: 'Why must the UPPER ball hit the switch BEFORE the lower '
          'chain brings return_ball to the gate?',
      complexity: ['gate_dependency', 'ordering', 'two_simultaneous_chains'],
    ),
    objects: [
      ObjectSpec.platform(4.0, 8.2, 6.0),
      ObjectSpec.box(
        4.3,
        8.2,
        starter: true,
        push: const Offset(12, 0),
        id: 'junction_box',
      ),
      ObjectSpec.ball(5.7, 8.2, id: 'upper_ball'),
      ObjectSpec.platform(5.8, 11.0, 4.5),
      ...ObjectSpec.dominoRow(
        fromX: 7.5,
        surfaceY: 11.0,
        count: 4,
        spacing: -0.58,
        idPrefix: 'shelf_domino_',
      ),
      ObjectSpec.ball(5.3, 11.0, id: 'return_ball'),
      ObjectSpec.button(6.55, 8.08, id: 's21', linkedTargetId: 'g21'),
      ObjectSpec.gate(1.65, kGroundY - 0.8, id: 'g21'),
      ObjectSpec.target(0.6, kGroundY),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 22 – Two-Shelf Relay  [REDESIGN – Phase 2: two-shelf-relay-gate]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..3 · ball_1 ·
  //                     platform_2 · ball_2 · domino_4..6 · s22 · g22 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 22,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Two-Shelf Relay',
    hint:
        'The upper ball must cross right to drop leftward momentum onto the lower shelf.',
    theme: oceanTheme,
    baseReward: 430,
    generationTemplate: 'two-shelf-relay-gate',
    generationDifficulty: 11,
    complexityScore: 11,
    tapCandidates: const {
      'domino_1',
      'domino_3',
      'domino_5',
      'ball_1',
      'domino_7',
      'ball_2',
    },
    design: const LevelDesignSpec(
      idea: 'Upper shelf chain moves rightward; ball_1 falls onto an angled '
          'ramp that reverses its direction leftward onto the lower shelf. The '
          'lower chain pushes ball_2 over the switch to open the gate and hit '
          'the target.',
      intendedTapIds: ['domino_1'],
      decoys: [
        'domino_2', 'domino_3', 'domino_4', 'domino_5', 'ball_1',
        'domino_6', 'domino_7', 'ball_2',
      ],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4', 'domino_5', 'ball_1',
        'ramp_1', 'domino_6', 'domino_7', 'ball_2', 's22', 'g22', 'target_1',
      ],
      reasoningPrompt: 'The ball on the upper shelf moves RIGHT, but the target is on '
          'the LEFT. How does the transfer invert direction?',
      complexity: ['vertical_transfer', 'direction_reversal', 'gate_dependency'],
    ),
    objects: [
      ObjectSpec.platform(3.0, 7.0, 4.4),
      ObjectSpec.domino(1.4, 7.0, starter: true, push: const Offset(0.38, 0)),
      ObjectSpec.domino(2.0, 7.0),
      ObjectSpec.domino(2.6, 7.0),
      ObjectSpec.domino(3.2, 7.0),
      ObjectSpec.domino(3.8, 7.0),
      ObjectSpec.ball(4.5, 7.0),
      ObjectSpec.ramp(6.0, 8.8, 1.8, angle: -0.30),
      ObjectSpec.platform(2.5, 10.5, 4.8),
      ObjectSpec.domino(3.2, 10.5),
      ObjectSpec.domino(2.6, 10.5),
      ObjectSpec.ball(2.0, 10.5),
      ObjectSpec.button(
        1.5,
        10.5 - 0.12,
        id: 's22',
        linkedTargetId: 'g22',
      ),
      ObjectSpec.gate(1.0, 10.5 - 0.8, id: 'g22'),
      ObjectSpec.target(0.45, 10.5, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 23 – False Switch  [REDESIGN – Phase 3: false-switch-gate]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..3 · ball_1 ·
  //                     s23b · g23b · s23a · g23a · domino_4 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 23,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'False Switch',
    hint:
        'One switch is a decoy; only the full run sends the ball to the real trigger.',
    theme: oceanTheme,
    baseReward: 440,
    generationTemplate: 'false-switch-gate',
    generationDifficulty: 12,
    complexityScore: 12,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Two switches are visible on the ground: the left switch is a decoy that '
          'opens an irrelevant gate, while the right switch opens the gate blocking '
          'the path to the target. Only starting from the full domino run sends the ball '
          'far enough right to reach the real switch.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'ball_1',
        's23b', 'g23b', 'domino_4', 'target_1',
      ],
      reasoningPrompt: 'Two switches are present on the ground. How can you tell which '
          'one opens the gate blocking the target, and why does tapping the ball fail to reach it?',
      complexity: ['decoy_choice', 'vertical_transfer', 'gate_dependency'],
    ),
    objects: [
      ObjectSpec.platform(2.5, 8.5, 3.4),
      ObjectSpec.domino(1.1, 8.5, starter: true, push: const Offset(0.38, 0)),
      ObjectSpec.domino(1.8, 8.5),
      ObjectSpec.domino(2.5, 8.5),
      ObjectSpec.ball(3.3, 8.5),
      // Real switch & gate
      ObjectSpec.button(5.0, kGroundY - 0.12, id: 's23b', linkedTargetId: 'g23b'),
      ObjectSpec.gate(5.9, kGroundY - 0.8, id: 'g23b'),
      // Decoy switch & gate
      ObjectSpec.button(2.4, kGroundY - 0.12, id: 's23a', linkedTargetId: 'g23a'),
      ObjectSpec.gate(1.5, kGroundY - 0.8, id: 'g23a'),
      // Ground domino & target
      ObjectSpec.domino(6.6, kGroundY),
      ObjectSpec.target(7.5, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 24 – Open the Spring Lane  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: box_1(starter) · domino_1..3 · ball_1 ·
  //                     s24(button, explicit) · g24(gate, explicit) · jumper_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 24,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Open the Spring Lane',
    hint:
        'The box opens the gate before the ball can reach the spring; tapping the ball skips that step.',
    theme: volcanoTheme,
    baseReward: 450,
    generationTemplate: 'switch-before-spring',
    generationDifficulty: 13,
    complexityScore: 13,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box starter pushes dominoes rightward; ball rolls into the button '
          'which opens the gate blocking the jumper lane; ball continues into the '
          'jumper and is launched upward to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3',
        'ball_1', 's24', 'g24', 'jumper_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly skips the button and the gate '
          'stays shut. Why does ball momentum alone not open the gate?',
      complexity: ['gate_dependency', 'ordering', 'jumper_arc'],
    ),
    objects: [
      ObjectSpec.box(0.8, kGroundY, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: kGroundY,
        count: 3,
        spacing: 0.56,
      ),
      ObjectSpec.ball(3.3, kGroundY),
      ObjectSpec.button(4.0, kGroundY - 0.12, id: 's24', linkedTargetId: 'g24'),
      ObjectSpec.gate(4.8, kGroundY - 0.8, id: 'g24'),
      ObjectSpec.jumper(5.6, kGroundY, direction: 1, launchSpeed: 1.0),
      ObjectSpec.target(5.9, 10.5, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 25 – Two Drops, One Gate  [REDESIGN – Phase 3: branch-converge-gate]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     s25 · platform_2 · domino_4..6 · ball_2 · g25 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 25,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'Two Drops, One Gate',
    hint:
        'The upper shelf must press the switch before the lower drop reaches the gate.',
    theme: oceanTheme,
    baseReward: 460,
    generationTemplate: 'branch-converge-gate',
    generationDifficulty: 14,
    complexityScore: 14,
    tapCandidates: const {
      'box_1',
      'domino_3',
      'ball_1',
      'domino_5',
      'ball_2',
    },
    design: const LevelDesignSpec(
      idea: 'The upper shelf box sends ball_1 over the switch to open the lower gate, '
          'then ball_1 drops onto the lower platform to initiate the second drop '
          'through ball_2 to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_3', 'ball_1', 'domino_5', 'ball_2'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'ball_1',
        's25', 'domino_4', 'domino_5', 'domino_6', 'ball_2', 'g25', 'target_1',
      ],
      reasoningPrompt: 'Tapping on the lower platform fails because the gate remains '
          'closed. Why must the chain start from the upper shelf?',
      complexity: ['vertical_transfer', 'gate_dependency', 'two_tier_transfer'],
    ),
    objects: [
      ObjectSpec.platform(2.0, 7.5, 4.0),
      ObjectSpec.box(0.8, 7.5, starter: true, push: const Offset(14, 0)),
      ObjectSpec.domino(1.4, 7.5),
      ObjectSpec.domino(1.9, 7.5),
      ObjectSpec.domino(2.4, 7.5),
      ObjectSpec.ball(3.2, 7.5, id: 'ball_1'),
      ObjectSpec.button(3.7, 7.5 - 0.12, id: 's25', linkedTargetId: 'g25'),
      ObjectSpec.platform(6.8, 10.8, 4.4),
      ObjectSpec.domino(5.5, 10.8),
      ObjectSpec.domino(6.1, 10.8),
      ObjectSpec.domino(6.7, 10.8),
      ObjectSpec.ball(7.3, 10.8, id: 'ball_2'),
      ObjectSpec.gate(7.9, 10.8 - 0.8, id: 'g25'),
      ObjectSpec.target(8.7, 10.8, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 26 – Opposite Pet Lanes  [TUNE – Phase 3: crossing-pet-lanes]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     dog_1 · cat_1 · s26 · g26 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 26,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Opposite Pet Lanes',
    hint:
        'The falling ball starts both pets; the dog opens the gate for the cat.',
    theme: volcanoTheme,
    baseReward: 470,
    generationTemplate: 'crossing-pet-lanes',
    generationDifficulty: 15,
    complexityScore: 15,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
      'dog_1',
      'cat_1',
    },
    design: const LevelDesignSpec(
      idea: 'The falling ball from the upper shelf activates both pets on the ground; '
          'the dog moves right to press the switch and open the gate, allowing '
          'the cat to reach the target.',
      intendedTapIds: ['box_1', 'domino_1'],
      decoys: ['domino_2', 'domino_3', 'ball_1', 'dog_1', 'cat_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'dog_1', 's26', 'g26', 'cat_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the cat directly fails because the gate remains closed. '
          'How does the ball falling from above coordinate both pets?',
      complexity: ['pet_coordination', 'gate_dependency', 'vertical_transfer'],
    ),
    objects: [
      ObjectSpec.platform(2.4, 8.8, 4.0),
      ObjectSpec.box(0.8, 8.8, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: 8.8,
        count: 3,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.3, 8.8),
      ObjectSpec.dog(4.4, kGroundY, direction: 1),
      ObjectSpec.cat(7.2, kGroundY, direction: -1),
      ObjectSpec.button(
        5.95,
        kGroundY - 0.12,
        id: 's26',
        linkedTargetId: 'g26',
      ),
      ObjectSpec.gate(6.55, kGroundY - 0.8, id: 'g26'),
      ObjectSpec.target(8.55, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 27 – The Falling Bridge  [REDESIGN – Phase 4: falling-bridge-timing]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     plank_1 · domino_4..6 · ball_2 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 27,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'The Falling Bridge',
    hint:
        'The upper run drops the ball to weight the plank bridge; partial taps fail to bridge the gap.',
    theme: oceanTheme,
    baseReward: 480,
    generationTemplate: 'falling-bridge-timing',
    generationDifficulty: 16,
    complexityScore: 16,
    tapCandidates: const {
      'box_1',
      'domino_2',
      'domino_3',
      'ball_1',
      'ball_2',
    },
    design: const LevelDesignSpec(
      idea: 'The upper platform box starts a chain that sends ball_1 onto the '
          'suspended plank bridge, tipping it downward to bridge the gap and '
          'activate the lower ground chain into the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_2', 'domino_3', 'ball_1', 'ball_2'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'plank_1', 'domino_4', 'domino_5', 'domino_6', 'ball_2', 'target_1',
      ],
      reasoningPrompt: 'Why does tapping ball_1 directly fail to properly weight '
          'the plank bridge, while starting from the box creates the full bridge connection?',
      complexity: ['bridge_timing', 'vertical_transfer', 'plank_activation'],
    ),
    objects: [
      ObjectSpec.platform(2.2, 8.2, 3.6),
      ObjectSpec.box(0.8, 8.2, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: 8.2,
        count: 3,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.1, 8.2),
      ObjectSpec.plank(4.6, 11.1, length: 2.4),
      ...ObjectSpec.dominoRow(
        fromX: 6.0,
        surfaceY: kGroundY,
        count: 3,
        spacing: 0.54,
      ),
      ObjectSpec.ball(7.9, kGroundY),
      ObjectSpec.target(8.75, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 28 – Ramp Return  [REDESIGN – Phase 2: ramp-return-direction]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     ramp_1 · platform_2 · domino_4..6 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 28,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Ramp Return',
    hint:
        'The ramp faces away from the target, but its reverse slope turns the run back.',
    theme: volcanoTheme,
    baseReward: 490,
    generationTemplate: 'ramp-return-direction',
    generationDifficulty: 17,
    complexityScore: 17,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
      'domino_4',
      'domino_6',
    },
    design: const LevelDesignSpec(
      idea: 'Upper shelf chain knocks ball_1 rightward into an angled ramp. '
          'Ramp deflects the ball downward and leftward onto a lower shelf, '
          'toppling a left-running domino chain to the target.',
      intendedTapIds: ['box_1'],
      decoys: [
        'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'domino_4', 'domino_5', 'domino_6',
      ],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'ramp_1', 'domino_4', 'domino_5', 'domino_6', 'target_1',
      ],
      reasoningPrompt: 'The ramp faces away from the target. How does its negative '
          'slope reverse the ball momentum?',
      complexity: ['ramp_redirect', 'direction_reversal', 'two_tier_transfer'],
    ),
    objects: [
      ObjectSpec.platform(4.5, 7.5, 4.8),
      ObjectSpec.box(2.8, 7.5, starter: true, push: const Offset(14, 0)),
      ObjectSpec.domino(3.5, 7.5),
      ObjectSpec.domino(4.1, 7.5),
      ObjectSpec.domino(4.7, 7.5),
      ObjectSpec.ball(5.6, 7.5),
      ObjectSpec.ramp(7.4, 9.6, 2.0, angle: -0.30),
      ObjectSpec.platform(3.4, 11.5, 5.8),
      ObjectSpec.domino(4.8, 11.5),
      ObjectSpec.domino(4.1, 11.5),
      ObjectSpec.domino(3.4, 11.5),
      ObjectSpec.target(2.2, 11.5, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 29 – The Ramp Reversal  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     ramp_1 · platform_2 · domino_5..7 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 29,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'The Ramp Reversal',
    hint:
        'The right-hand ramp turns the falling ball back across the lower shelf.',
    theme: oceanTheme,
    baseReward: 500,
    generationTemplate: 'double-ramp-reversal',
    generationDifficulty: 18,
    complexityScore: 18,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box starter pushes upper dominoes leftward; ball rolls off the left '
          'edge of the upper shelf and hits a negatively-angled ramp that deflects '
          'it leftward onto the lower shelf; lower dominoes carry it left to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'ramp_1', 'domino_5', 'domino_6', 'domino_7', 'target_1',
      ],
      reasoningPrompt: 'The ramp appears to send the ball AWAY from the target, '
          'but the negative angle actually deflects it leftward. '
          'Why does starting from a lower domino fail?',
      complexity: ['ramp_redirect', 'direction_reversal', 'two_tier_transfer'],
    ),
    objects: [
      ObjectSpec.platform(6.5, 7.4, 4.4),
      ObjectSpec.box(8.2, 7.4, starter: true, push: const Offset(-14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.6,
        surfaceY: 7.4,
        count: 4,
        spacing: -0.52,
      ),
      ObjectSpec.ball(5.2, 7.4),
      ObjectSpec.ramp(4.2, 10.8, 2.2, angle: -0.28),
      ObjectSpec.platform(2.3, 11.4, 3.6),
      ...ObjectSpec.dominoRow(
        fromX: 3.5,
        surfaceY: 11.4,
        count: 3,
        spacing: -0.52,
      ),
      ObjectSpec.target(1.6, 11.4, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 30 – Gate-to-Pet Finish  [REDESIGN – Phase 4: gate-to-pet-relay]
  // Auto-generated IDs: domino_1..4(first=starter) · ball_1 ·
  //                     s30a · g30a · dog_1 · cat_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 30,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'Gate-to-Pet Finish',
    hint:
        'The domino run opens the gate; the ball then starts the dog and cat relay to the target.',
    theme: oceanTheme,
    baseReward: 510,
    generationTemplate: 'gate-to-pet-relay',
    generationDifficulty: 19,
    complexityScore: 19,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The domino run pushes the ball into the button to open the gate, '
          'allowing the ball to pass through and activate the dog-and-cat relay '
          'to the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 's30a', 'g30a', 'dog_1', 'cat_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly fails to reach the button with '
          'enough momentum, leaving the gate shut. Why must the full domino row fall?',
      complexity: ['gate_dependency', 'pet_relay', 'ordering'],
    ),
    objects: [
      ...ObjectSpec.dominoRow(
        fromX: 1.2,
        surfaceY: kGroundY,
        count: 4,
        spacing: 0.56,
        firstIsStarter: true,
      ),
      ObjectSpec.ball(3.43, kGroundY),
      ObjectSpec.button(
        4.35,
        kGroundY - 0.12,
        id: 's30a',
        linkedTargetId: 'g30a',
      ),
      ObjectSpec.gate(5.2, kGroundY - 0.8, id: 'g30a'),
      ObjectSpec.dog(5.8, kGroundY, direction: 1),
      ObjectSpec.cat(6.8, kGroundY, direction: 1),
      ObjectSpec.target(9.25, kGroundY, radius: 0.48),
    ],
  ),
];
