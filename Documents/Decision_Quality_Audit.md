# Tap decision audit: Levels 1–40

Every dynamic object was tapped at its center in the production `ChainSimulation`, then simulated until it settled. Static scenery is not tappable. **Target** counts taps that hit the target (the game's success condition). **All-touched** counts those that also touch every dynamic object, which earns the full object score. Thus `2/3` means two target-winning taps out of three tappable objects, and one of those two touches fewer than all objects.

The profile labels describe the measured target-winning choices: **broad** = 4 or more, **narrow** = 2–3, **single** = exactly 1. The early physics and mechanic lessons intentionally include broad choices; the reasoning stages increasingly use narrow and single-choice starters. A single-choice stage still allows every wrong tap to start its own physical simulation.

| Level | Target wins / tappable | All-touched wins | Profile |
|---:|---:|---:|---|
| 1 | 3/10 | 1 | narrow |
| 2 | 4/10 | 4 | broad |
| 3 | 4/12 | 4 | broad |
| 4 | 2/10 | 2 | narrow |
| 5 | 3/8 | 1 | narrow |
| 6 | 6/17 | 4 | broad |
| 7 | 5/14 | 3 | broad |
| 8 | 4/11 | 4 | broad |
| 9 | 3/9 | 3 | narrow |
| 10 | 3/9 | 3 | narrow |
| 11 | 2/6 | 2 | narrow |
| 12 | 1/1 | 1 | single (one tap exists) |
| 13 | 1/5 | 1 | single |
| 14 | 2/6 | 1 | narrow |
| 15 | 2/6 | 1 | narrow |
| 16 | 2/6 | 1 | narrow |
| 17 | 3/6 | 3 | narrow |
| 18 | 2/5 | 1 | narrow |
| 19 | 5/8 | 4 | broad |
| 20 | 3/4 | 1 | narrow |
| 21 | 1/7 | 1 | single |
| 22 | 4/12 | 4 | broad |
| 23 | 2/6 | 2 | narrow |
| 24 | 3/5 | 1 | narrow |
| 25 | 4/10 | 4 | broad |
| 26 | 3/7 | 3 | narrow |
| 27 | 4/10 | 3 | broad |
| 28 | 5/11 | 5 | broad |
| 29 | 3/9 | 3 | narrow |
| 30 | 3/7 | 1 | narrow |
| 31 | 2/6 | 1 | narrow |
| 32 | 2/6 | 2 | narrow |
| 33 | 2/6 | 2 | narrow |
| 34 | 4/7 | 1 | broad |
| 35 | 1/7 | 1 | single |
| 36 | 2/5 | 2 | narrow |
| 37 | 3/6 | 2 | narrow |
| 38 | 3/10 | 3 | narrow |
| 39 | 3/6 | 3 | narrow |
| 40 | 1/4 | 1 | exact |

## Decision-quality changes

Level 21 was the outlier: six of seven dynamic taps hit the target. Its upper shelf now carries the existing switch. The intended box push rolls the upper ball through that switch, then drops it onto the lower shelf. The lower domino-and-ball route feeds the ground gate and target. Tapping the lower shelf skips the switch, while tapping the upper ball sends it away from the switch. Those six taps still produce collisions and touch the dynamic pieces, but none reaches the target. The authored box tap remains a full-object solution.

This creates an advanced single-starter puzzle without adding objects or changing the two-shelf junction, ball handoff, floor gate, or target. Its hint now points to the required order. Other advanced single-choice examples are Level 35's plank-after-drop route; broad-choice examples such as Levels 22, 25, and 28 retain their distinct two-shelf and cross-lane structures.

Wrong taps in a single-choice level are not rejected by input handling: they launch the tapped object and run the same physics engine. Level 21's automated check confirms every wrong tap produces impacts and contacts multiple objects, yet misses the target. Target-only wins and full-object wins are reported separately so partial-score routes are not mistaken for perfect solutions.

## Validation

`test/levels_test.dart` exhaustively taps every dynamic object in all 40 levels, asserts the target and full-object route counts above, and includes a Level 21 decoy-chain check. Existing per-level tests also validate the authored starter routes in the physics engine.
