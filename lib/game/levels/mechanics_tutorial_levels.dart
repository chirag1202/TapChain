import 'package:flutter/painting.dart';

import '../level_config.dart';
import 'level_2.dart' show workshopTheme;
import 'level_4.dart' show neonTheme;

const _reward = 210;

final List<LevelConfig> mechanicTutorialLevels = [
  // ─────────────────────────────────────────────────────────────────────────
  // Level 11 – Ramp Lesson  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     ramp_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 11,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Ramp Lesson',
    hint: 'The ramp turns a falling ball into a sideways hit.',
    theme: workshopTheme,
    baseReward: _reward,
    generationTemplate: 'ramp-intro',
    generationDifficulty: 1,
    complexityScore: 1,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box starter topples a domino chain that sends a ball off the shelf '
          'edge. The ball falls and hits an angled ramp that redirects it '
          'rightward to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'ramp_1', 'target_1',
      ],
      reasoningPrompt: 'Why must you tap the box rather than a mid-chain domino?',
      complexity: ['ramp_redirect', 'momentum_dependency'],
    ),
    objects: [
      ObjectSpec.platform(2.0, 9.3, 3.8),
      ObjectSpec.box(0.85, 9.3, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.45,
        surfaceY: 9.3,
        count: 4,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.55, 9.3),
      ObjectSpec.ramp(5.0, 13.55, 2.4, angle: 0.28),
      ObjectSpec.target(7.8, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 12 – Shelf to See-Saw  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     plank_1 · ramp_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 12,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Shelf to See-Saw',
    hint: 'The ball must leave the high shelf and load the plank from its far end.',
    theme: neonTheme,
    baseReward: _reward,
    generationTemplate: 'upper-drop-loaded-plank',
    generationDifficulty: 2,
    complexityScore: 2,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
      'plank_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box launches dominoes rightward; the ball rolls off the shelf edge '
          'and lands on the far (right) end of an angled plank, tipping it so '
          'the ball rolls left onto a ramp that redirects it to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'ball_1', 'plank_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3',
        'ball_1', 'plank_1', 'ramp_1', 'target_1',
      ],
      reasoningPrompt: 'The ball must land on the FAR end of the plank to create '
          'enough rotation. Why does tapping the ball directly fail to achieve that?',
      complexity: ['plank_loading', 'ramp_redirect', 'direction_reversal'],
    ),
    objects: [
      ObjectSpec.platform(2.25, 8.0, 3.8),
      ObjectSpec.box(0.72, 8.0, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.32,
        surfaceY: 8.0,
        count: 3,
        spacing: 0.52,
      ),
      ObjectSpec.ball(3.15, 8.0),
      ObjectSpec.plank(
        5.6,
        11.4,
        length: 2.6,
        angle: -0.10,
      ),
      ObjectSpec.ramp(7.15, 12.65, 1.6, angle: 0.28),
      ObjectSpec.target(0.62, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 13 – Switch First  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · domino_1..4(first=starter) · ball_1 ·
  //                     switch-13(button, explicit id) · gate-13(gate, explicit id) ·
  //                     target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 13,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'Switch First',
    hint: 'The ball presses the switch; the open gate clears its route.',
    theme: workshopTheme,
    baseReward: _reward,
    generationTemplate: 'switch-gate-intro',
    generationDifficulty: 3,
    complexityScore: 3,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Domino chain pushes ball rightward; ball hits the button which opens '
          'the gate; ball continues and passes through the now-open gate to reach '
          'the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'switch-13', 'gate-13', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly hits the button but the gate does '
          'not open fast enough – or the ball skips the button entirely. '
          'Why must the FULL chain run first?',
      complexity: ['gate_dependency', 'ordering'],
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
        id: 'switch-13',
        linkedTargetId: 'gate-13',
      ),
      ObjectSpec.gate(5.2, kGroundY - 0.8, id: 'gate-13'),
      ObjectSpec.target(6.6, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 14 – Catapult Cat  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · domino_1..4(first=starter) · ball_1 ·
  //                     cat_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 14,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Catapult Cat',
    hint: 'The ball wakes the cat; the cat carries the chain forward.',
    theme: neonTheme,
    baseReward: _reward,
    generationTemplate: 'cat-intro',
    generationDifficulty: 4,
    complexityScore: 4,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
      'cat_1',
    },
    design: const LevelDesignSpec(
      idea: 'Domino chain falls off the platform edge; ball drops onto the ground '
          'and activates the cat on contact; cat runs rightward to the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1', 'cat_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'cat_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the cat directly starts it running but nothing else '
          'follows. Why is the BALL essential for triggering the cat?',
      complexity: ['pet_activation', 'vertical_transfer'],
    ),
    objects: [
      ObjectSpec.platform(2.7, 9.0, 4.6),
      ...ObjectSpec.dominoRow(
        fromX: 1.2,
        surfaceY: 9.0,
        count: 4,
        spacing: 0.56,
        firstIsStarter: true,
      ),
      ObjectSpec.ball(3.43, 9.0),
      ObjectSpec.cat(5.75, kGroundY, direction: 1),
      ObjectSpec.target(7.8, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 15 – Dog Run  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · domino_1(starter,push-left) · domino_2..4 ·
  //                     ball_1 · dog_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 15,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Dog Run',
    hint: 'Start on the right: the dog runs left through the dominoes.',
    theme: workshopTheme,
    baseReward: _reward,
    generationTemplate: 'dog-intro',
    generationDifficulty: 5,
    complexityScore: 5,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
      'dog_1',
    },
    design: const LevelDesignSpec(
      idea: 'Rightmost domino (starter) is pushed leftward, toppling the chain '
          'right-to-left. Ball on the ground is knocked left by the last falling '
          'domino, activating the dog; dog runs left to the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1', 'dog_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'dog_1', 'target_1',
      ],
      reasoningPrompt: 'The chain runs RIGHT-TO-LEFT — the opposite of most levels. '
          'Why does tapping a mid-chain domino cause the dog to miss the target?',
      complexity: ['direction_reversal', 'pet_activation'],
    ),
    objects: [
      ObjectSpec.platform(5.2, 9.0, 3.8),
      ObjectSpec.domino(
        6.0,
        9.0,
        starter: true,
        push: const Offset(-0.35, 0),
      ),
      ObjectSpec.domino(5.44, 9.0),
      ObjectSpec.domino(4.88, 9.0),
      ObjectSpec.domino(4.32, 9.0),
      ObjectSpec.ball(3.75, 9.0),
      ObjectSpec.dog(2.95, kGroundY, direction: -1),
      ObjectSpec.target(0.8, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 16 – Split Shelf  [REDESIGN – Phase 2: split-shelf-transfer]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..3 · ball_1 ·
  //                     platform_2 · domino_4..6 · ball_2 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 16,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Split Shelf',
    hint: 'A ball dropped from the high shelf bridges the gap to the lower row.',
    theme: neonTheme,
    baseReward: _reward,
    generationTemplate: 'split-shelf-transfer',
    generationDifficulty: 6,
    complexityScore: 6,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
      'domino_4',
      'domino_5',
      'domino_6',
      'ball_2',
    },
    design: const LevelDesignSpec(
      idea: 'Vertical transfer: full upper box and domino chain sends ball_1 off '
          'the upper shelf to land on the lower platform, continuing the chain '
          'through ball_2 to the target.',
      intendedTapIds: ['box_1'],
      decoys: [
        'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'domino_4', 'domino_5', 'domino_6', 'ball_2',
      ],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'ball_1',
        'domino_4', 'domino_5', 'domino_6', 'ball_2', 'target_1',
      ],
      reasoningPrompt: 'Why does tapping the lower dominoes directly fail to reach '
          'the target, while starting from the upper box succeeds?',
      complexity: ['vertical_transfer', 'momentum_dependency', 'two_tier_transfer'],
    ),
    objects: [
      ObjectSpec.platform(2.0, 7.5, 4.0),
      ObjectSpec.box(0.8, 7.5, starter: true, push: const Offset(14, 0)),
      ObjectSpec.domino(1.4, 7.5),
      ObjectSpec.domino(1.9, 7.5),
      ObjectSpec.domino(2.4, 7.5),
      ObjectSpec.ball(3.2, 7.5),
      ObjectSpec.platform(6.8, 10.8, 4.4),
      ObjectSpec.domino(5.5, 10.8),
      ObjectSpec.domino(6.1, 10.8),
      ObjectSpec.domino(6.7, 10.8),
      ObjectSpec.ball(7.4, 10.8),
      ObjectSpec.target(8.4, 10.8, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 17 – The Upward Handoff  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     jumper_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 17,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'The Upward Handoff',
    hint: 'The upper row feeds a leftward launch from the floor spring.',
    theme: workshopTheme,
    baseReward: _reward,
    generationTemplate: 'springboard-handoff',
    generationDifficulty: 7,
    complexityScore: 7,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box on the upper platform is pushed leftward; the leftward domino '
          'chain sends the ball off the left edge of the shelf; ball falls to the '
          'floor jumper which launches it leftward-upward to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'jumper_1', 'target_1',
      ],
      reasoningPrompt: 'The ball must go DOWN to the jumper first in order to travel '
          'UP and across to the target. Why does tapping a mid-chain domino not '
          'give the ball enough momentum to reach the jumper correctly?',
      complexity: ['jumper_arc', 'momentum_dependency', 'direction_reversal'],
    ),
    objects: [
      ObjectSpec.platform(6.2, 9.2, 4.8),
      ObjectSpec.box(8.1, 9.2, starter: true, push: const Offset(-14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.55,
        surfaceY: 9.2,
        count: 4,
        spacing: -0.42,
      ),
      ObjectSpec.ball(5.45, 9.2),
      ObjectSpec.jumper(3.0, kGroundY, direction: -1),
      ObjectSpec.target(1.9, kGroundY, radius: 0.65),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 18 – Gate on the Return  [REDESIGN – Phase 3: button-gate-u-route]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..3 · ball_1 ·
  //                     s18 · ramp_1 · g18 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 18,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'Gate on the Return',
    hint:
        'The ball presses the high switch first, then loops down and back through the open gate.',
    theme: neonTheme,
    baseReward: _reward,
    generationTemplate: 'button-gate-u-route',
    generationDifficulty: 8,
    complexityScore: 8,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The ball rolls leftward on the high shelf to trigger the switch and '
          'open the gate. Continuing left off the shelf, the ball drops onto an '
          'angled ramp that redirects it through the now-open gate to the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'ball_1',
        's18', 'g18', 'ramp_1', 'target_1',
      ],
      reasoningPrompt: 'Why does tapping the ball directly cause it to reach the '
          'gate before it opens, while starting with the domino succeeds?',
      complexity: ['u_route', 'gate_dependency', 'ordering'],
    ),
    objects: [
      ObjectSpec.platform(5.2, 8.5, 4.4),
      ObjectSpec.domino(7.0, 8.5, starter: true, push: const Offset(-0.38, 0)),
      ObjectSpec.domino(6.4, 8.5),
      ObjectSpec.domino(5.8, 8.5),
      ObjectSpec.ball(5.0, 8.5),
      ObjectSpec.button(
        4.1,
        8.5 - 0.12,
        id: 's18',
        linkedTargetId: 'g18',
      ),
      ObjectSpec.ramp(2.6, 11.2, 2.0, angle: -0.30),
      ObjectSpec.gate(1.5, kGroundY - 0.8, id: 'g18'),
      ObjectSpec.target(0.65, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 19 – Drop Into the Relay  [TUNE → Phase 3; unchanged]
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 19,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Drop Into the Relay',
    hint:
        'The high run drops the ball onto a dog, then the cat opens the low gate.',
    theme: workshopTheme,
    baseReward: _reward,
    generationTemplate: 'drop-pet-gate',
    generationDifficulty: 9,
    complexityScore: 9,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The high platform run drops the ball onto the dog below, which collides with '
          'and activates the cat to press the switch and open the gate to the target.',
      intendedTapIds: ['box_1', 'domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'dog_1', 'cat_1', 'switch-19', 'gate-19', 'target_1',
      ],
      reasoningPrompt: 'Why does starting the chain from the high shelf successfully activate '
          'both pets, while tapping the ball directly fails to reach the dog?',
      complexity: ['vertical_transfer', 'pet_relay', 'gate_dependency'],
    ),
    objects: [
      ObjectSpec.platform(2.2, 8.8, 4.0),
      ObjectSpec.box(0.8, 8.8, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: 8.8,
        count: 4,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.6, 8.8),
      ObjectSpec.dog(7.2, kGroundY, direction: 1),
      ObjectSpec.cat(8.0, kGroundY, direction: 1),
      ObjectSpec.button(
        8.35,
        kGroundY - 0.12,
        id: 'switch-19',
        linkedTargetId: 'gate-19',
      ),
      ObjectSpec.gate(8.85, kGroundY - 0.8, id: 'gate-19'),
      ObjectSpec.target(9.25, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 20 – Lever Before the Gate  [REDESIGN – Phase 4: plank-switch-gate]
  // Auto-generated IDs: plank_1(starter) · switch-20 · ball_1 · gate-20 ·
  //                     domino_1..2 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 20,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Lever Before the Gate',
    hint:
        'The plank presses the switch first; its falling end then sends the ball through the open gate.',
    theme: neonTheme,
    baseReward: _reward,
    generationTemplate: 'plank-switch-gate',
    generationDifficulty: 10,
    complexityScore: 10,
    tapCandidates: const {
      'plank_1',
      'ball_1',
      'domino_1',
      'domino_2',
    },
    design: const LevelDesignSpec(
      idea: 'The plank starter sweeps rightward into the switch to open the gate, '
          'then collides with the ball to send it through the now-open gate into '
          'the domino chain and target.',
      intendedTapIds: ['plank_1', 'domino_1'],
      decoys: ['ball_1', 'domino_2'],
      chain: [
        'plank_1', 'switch-20', 'gate-20', 'ball_1',
        'domino_1', 'domino_2', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly fails because the gate remains '
          'shut and blocks it. Why must the plank be triggered first?',
      complexity: ['plank_activation', 'gate_dependency', 'ordering'],
    ),
    objects: [
      ObjectSpec.plank(
        1.8,
        kGroundY,
        length: 2.2,
        starter: true,
        push: const Offset(12, 0),
      ),
      ObjectSpec.button(
        3.3,
        kGroundY - 0.12,
        id: 'switch-20',
        linkedTargetId: 'gate-20',
      ),
      ObjectSpec.ball(4.1, kGroundY),
      ObjectSpec.gate(5.0, kGroundY - 0.8, id: 'gate-20'),
      ObjectSpec.domino(6.0, kGroundY),
      ObjectSpec.domino(6.7, kGroundY),
      ObjectSpec.target(7.9, kGroundY, radius: 0.48),
    ],
  ),
];
