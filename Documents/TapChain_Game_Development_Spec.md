# TAPCHAIN — Game Development Specification

**Flutter + Flame • Android • Offline • Single Player**

## 1. Product Vision

Build a small, polished, self-contained Android casual physics game called **TapChain**.

The game is built around a simple one-tap mechanic:

> **LOOK → THINK → TAP → WATCH → REWARD**

The player studies a physics puzzle, decides when to tap, the timer stops, and the resulting chain reaction plays automatically.

The prototype must feel like a real casual mobile game rather than a developer demo.

---

## 2. Scope and Technical Constraints

- Flutter + Flame.
- Android only; portrait orientation, designed primarily for 9:16 phones.
- Completely offline and self-contained.
- Single player only.
- **No database.**
- No Supabase or Firebase.
- No login, account, networking, APIs, backend, multiplayer, analytics, or remote configuration.
- Use SharedPreferences only if needed for local level-unlock persistence.
- Keep architecture simple and maintainable.

---

## 3. Core Gameplay

1. Every level starts with a **60-second countdown**.
2. The player observes the arrangement and decides when to trigger it.
3. The player can **tap only once**.
4. Immediately when the player taps, freeze the timer.
5. Start the physics simulation and let the chain reaction play automatically.
6. Detect whether the target is reached and calculate the reward.

The player should not have to control objects after tapping. There is no joystick, dragging, aiming, or repeated tapping.

---

## 4. Timer and Reward System

The countdown begins at **60.0 seconds** and runs only while the player is deciding.

The exact remaining time at the tap is frozen and used for the multiplier.

| Time remaining at tap | Multiplier |
|---|---:|
| 50–60 sec | ×3 |
| 40–49.99 sec | ×2 |
| 30–39.99 sec | ×1.5 |
| 0–29.99 sec | ×1 |

Use a simple base coin reward per level.

Example:

- Base reward = 50 coins
- Player taps with 43.2 seconds remaining
- Multiplier = ×2
- Reward = 100 coins

For the prototype, keep the economy simple. Do **not** build shops, upgrades, inventories, or other economy systems.

---

## 5. Splash Screen

Create a polished, playful **TAPCHAIN** logo.

The logo should visually suggest:

- A falling domino
- A ball
- A chain reaction

Use subtle animation:

- Domino falling
- Ball bouncing
- Small particles
- Gentle logo bounce/scale

Splash duration should be approximately **1.5–2 seconds**, followed by a smooth transition to Home.

Do not make the visual style corporate. It should resemble a polished casual puzzle game.

---

## 6. Home Screen

Include:

- Large TAPCHAIN logo.
- Large animated **PLAY** button.
- **LEVELS** button/entry point.
- Small coin counter such as `🪙 250`.
- Lively physics-themed background instead of a flat solid color.

Background can include:

- Floating dominoes
- Bouncing balls
- Platforms
- Subtle particles
- Lightweight parallax

Buttons should have tactile press animation such as slight scale/bounce.

---

## 7. Level Selector

Show five large level cards/buttons.

Each card should display:

- Level number
- Small preview illustration
- Locked/unlocked state

Completing a level unlocks the next level.

Suggested initial state:

- Level 1 unlocked
- Levels 2–5 locked

Use a polished vertical or two-column layout.

Each level should visually have its own identity.

---

## 8. Level Progression

| Level | New Mechanic | Theme |
|---|---|---|
| **1 – First Fall** | Dominoes + target | Sunny Garden |
| **2 – The Drop** | Dominoes + ball + platforms | Toy Workshop |
| **3 – Heavy Impact** | Add box/crate | Construction Site |
| **4 – The Trick** | Multiple paths / decoys using all objects | Neon Night |
| **5 – Chain Master** | Complex multi-stage chain using all objects | Space Station |

The progression should teach the game naturally.

---

## 9. Level 1 — First Fall

**Difficulty:** Very easy.

**Objects:**

- Dominoes
- Target

The player taps the first domino and a reliable sequential domino chain reaches the target.

**Purpose:** Teach the fundamental mechanic:

> One tap → chain reaction → target.

**Visual theme: Sunny Garden**

- Blue sky
- Clouds
- Grass
- Flowers
- Warm cheerful atmosphere

---

## 10. Level 2 — The Drop

Introduce the **ball**.

**Objects:**

- Dominoes
- Ball
- Platforms
- Target

A domino chain should knock a ball off a platform. The ball falls or rolls onto another platform and continues the chain.

**Visual theme: Toy Workshop**

- Wooden platforms
- Bright toy-like objects
- Screws/gears
- Warm workshop lighting

---

## 11. Level 3 — Heavy Impact

Introduce a new object type:

### BOX / CRATE

**Objects:**

- Dominoes
- Balls
- Boxes
- Platforms
- Target

The box should have clearly different physics from the ball:

- Heavy
- Does not roll easily
- Can knock dominoes over
- Can block or redirect a ball

**Visual theme: Construction Site**

- Yellow/black construction elements
- Wooden/metal platforms
- Crates
- Pipes
- Subtle machinery

---

## 12. Level 4 — The Trick

Increase complexity.

Use:

- Dominoes
- Balls
- Boxes
- Multiple platforms
- Target

Introduce **multiple possible paths and decoy objects**.

The player must identify the correct place to trigger the chain.

**Visual theme: Neon Night**

- Dark blue/purple environment
- Neon platforms
- Glowing balls
- Particle effects

This level should feel visually very different from Levels 1–3.

---

## 13. Level 5 — Chain Master

Make this the first genuinely satisfying challenge.

Use:

- Dominoes
- Balls
- Boxes
- Multiple platforms
- Target

Create a multi-stage chain.

Example:

```text
DOMINO
   ↓
BALL
   ↓
DOMINO
   ↓
BOX
   ↓
BALL
   ↓
DOMINOES
   ↓
TARGET
```

The player should have a clear prediction puzzle:

> “If I tap here, that causes this, which causes the next event.”

The complete chain should ideally take approximately **5–10 seconds** to play after the tap.

**Visual theme: Space Station**

- Dark space background
- Stars
- Floating platforms
- Futuristic objects
- Glowing target
- Particles

---

## 14. Level Visual Identity

Do **not** simply move objects around while keeping the same background.

Each level must have its own:

- Background
- Color palette
- Decorative elements
- Lighting
- Object arrangement
- Physics challenge
- Mood

Themes:

1. 🌱 Sunny Garden
2. 🧸 Toy Workshop
3. 🚧 Construction Site
4. 🌃 Neon Night
5. 🚀 Space Station

---

## 15. Gameplay UI

During gameplay:

**Top-left**
```text
LEVEL 3
```

**Top-center**
```text
47.8
```

Large, readable countdown timer.

**Top-right**
```text
🪙 250
```

Before tapping:

> **TAP TO START**

Once tapped:

- Remove the prompt.
- Freeze the timer immediately.
- Start the physics.

Keep the HUD clean and readable.

---

## 16. Physics Requirements

Use Flame's physics/collision capabilities or another lightweight local physics implementation appropriate for Flutter.

Prioritize:

- Stable collisions
- Predictable results
- Consistent level outcomes
- Low CPU usage
- Smooth Android performance

The physics should feel satisfying but not overly realistic.

This is a puzzle game, so **gameplay consistency is more important than perfect real-world physics**.

Each level must be deterministic enough that the intended chain works reliably.

Avoid situations where tiny physics variations randomly cause the level to fail.

---

## 17. Success Screen

After the chain reaction, show an animated result screen.

Example:

```text
🎉 CHAIN COMPLETE!

TIME LEFT
43.2 SEC

MULTIPLIER
×2

BASE REWARD
50

REWARD
+100 🪙

⭐⭐⭐
```

Buttons:

- **NEXT LEVEL**
- **REPLAY**

Use small particle and coin animations.

---

## 18. Failure Screen

If the target is not reached:

```text
CHAIN FAILED

You missed the target!

TRY AGAIN
```

Allow immediate replay.

Do not heavily punish the player. Keep the game casual and friendly.

---

## 19. Audio

If easy to implement, include local bundled sound effects for:

- Button taps
- Domino falls
- Ball bounces
- Box impacts
- Target hit
- Coins
- Level completion

The chain should feel satisfying:

> **CLACK → CLACK → CLACK → BOOM → TARGET**

No external audio services.

The game must still work if audio assets are unavailable.

---

## 20. Animation and Polish

Use subtle animations throughout:

- Logo bounce
- PLAY button pulse
- Level-card press/bounce
- Coin reward animation
- Stars appearing one by one
- Target flash when hit
- Small collision particles

Do not overdo animations.

Performance is important.

---

## 21. Suggested Code Structure

```text
lib/
 ├── main.dart
 ├── screens/
 │    ├── splash_screen.dart
 │    ├── home_screen.dart
 │    ├── level_select_screen.dart
 │    └── game_screen.dart
 │
 ├── game/
 │    ├── tap_chain_game.dart
 │    ├── level_config.dart
 │    ├── physics_objects.dart
 │    └── levels/
 │         ├── level_1.dart
 │         ├── level_2.dart
 │         ├── level_3.dart
 │         ├── level_4.dart
 │         └── level_5.dart
 │
 ├── models/
 │    └── level_model.dart
 │
 └── services/
      └── local_storage.dart
```

Do not introduce unnecessary architecture.

Avoid:

- Repository pattern
- API layer
- Authentication
- Database
- Supabase
- Firebase
- Analytics
- Backend
- Multiplayer
- Remote configuration

This is deliberately a **small offline prototype**.

---

## 22. Responsive Android Design

- Portrait orientation, primarily 9:16.
- Use logical coordinates and responsive scaling.
- Do not hardcode one device resolution.
- No objects or buttons may be clipped.
- Respect Android system/navigation safe areas.
- Ensure readable text and comfortable touch targets.

---

## 23. Critical Prototype Requirements

**Do not generate only mock screens. The prototype must actually be playable.**

Implement:

- Splash screen
- Home screen
- Level selector
- Level unlocking
- Five playable levels
- 60-second countdown
- One-tap trigger
- Timer freeze at tap
- Physics chain reaction
- Success/failure detection
- Coin calculation
- Tap-time multiplier
- Result screen
- Replay
- Next level
- Local progress

---

## 24. Development Priority

Implement in this order:

1. Get the core one-tap physics loop working.
2. Implement the 60-second timer and freeze-on-tap behavior.
3. Build five reliable playable levels with progressive mechanics.
4. Add success/failure and reward calculations.
5. Build navigation: Splash → Home → Levels → Game → Result.
6. Add local unlock persistence.
7. Polish each level with its unique visual theme.
8. Add lightweight animations and sound.
9. Test on a real Android phone and fix physics/reliability issues.

If a choice must be made between visual complexity and reliable gameplay, **choose reliable gameplay**.

---

## 25. Final Product Vision

**TapChain** is a casual physics puzzle where the player has 60 seconds to figure out the setup, makes one tap, and then watches the chain reaction unfold.

### Tagline

> **60 seconds to think.  
> One tap to trigger.  
> Watch the chaos.  
> Master the chain.**

The prototype should feel:

- Simple at heart
- Visually lively
- Immediately understandable
- Satisfying to watch
- Fun to replay
- Polished enough to resemble a real Google Play casual game
