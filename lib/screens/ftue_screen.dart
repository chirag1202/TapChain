import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/levels/levels.dart';
import '../services/local_storage.dart';
import '../widgets/common.dart';
import '../widgets/home_background.dart';
import 'home_screen.dart';
import 'level_select_screen.dart';

/// First-run walkthrough: Look, Think, Tap, Watch.
class FtueScreen extends StatefulWidget {
  const FtueScreen({super.key, this.replay = false});

  /// True when opened from Home; closing returns instead of entering Home.
  final bool replay;

  @override
  State<FtueScreen> createState() => _FtueScreenState();
}

class _FtueScreenState extends State<FtueScreen>
    with SingleTickerProviderStateMixin {
  static const _pageCount = 4;

  final PageController _pages = PageController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _finish() {
    LocalStorage.instance.markFtueSeen();
    if (widget.replay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pageCount - 1;
    return Scaffold(
      body: PhysicsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _Step(
                      title: 'LOOK',
                      text:
                          'Every level is a chain reaction waiting to happen. Study the setup.',
                      child: _PreviewCard(anim: _anim, hand: false),
                    ),
                    _Step(
                      title: 'THINK',
                      text:
                          'You get 60 seconds. The longer you wait, the smaller your bonus, so decide fast.',
                      child: _ThinkArt(anim: _anim),
                    ),
                    _Step(
                      title: 'TAP',
                      text:
                          'Tap anywhere on the screen, once. The timer freezes and the chain runs by itself.',
                      child: _PreviewCard(anim: _anim, hand: true),
                    ),
                    _Step(
                      title: 'WATCH',
                      text:
                          'Hit the target to earn coins and stars. Tap sooner for a bigger multiplier.',
                      child: _RewardArt(anim: _anim),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pageCount; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 22 : 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: i == _page ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
                child: GameButton(
                  label: last ? "LET'S GO!" : 'NEXT',
                  fontSize: 26,
                  width: double.infinity,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.text, required this.child});

  final String title;
  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedText(
                  title,
                  size: 46,
                  fill: const Color(0xFFFFC93C),
                  stroke: const Color(0xFF7A2E0E),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: math.max(220, box.maxHeight * 0.5),
                  child: Center(child: child),
                ),
                const SizedBox(height: 14),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFC93C), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.anim, required this.hand});

  final AnimationController anim;
  final bool hand;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = (box.maxWidth * 11 / 9).clamp(0.0, box.maxHeight);
        return SizedBox(width: h * 9 / 11, height: h, child: _card());
      },
    );
  }

  Widget _card() {
    return _Frame(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: LevelPreviewPainter(allLevels.first)),
          if (hand)
            AnimatedBuilder(
              animation: anim,
              builder: (context, _) {
                final t = anim.value;
                final press = t < 0.5 ? Curves.easeInOut.transform(t * 2) : 0.0;
                final ripple = t < 0.35
                    ? 0.0
                    : ((t - 0.35) / 0.4).clamp(0.0, 1.0);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 30 + 110 * ripple,
                      height: 30 + 110 * ripple,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 1 - ripple),
                          width: 5,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, 28 - 22 * press),
                      child: Transform.scale(
                        scale: 1 - 0.18 * press,
                        child: const Icon(
                          Icons.touch_app_rounded,
                          size: 84,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ThinkArt extends StatelessWidget {
  const _ThinkArt({required this.anim});

  final AnimationController anim;

  static const _tiers = [
    ('50 - 60 s', '×3', Color(0xFF3DDC84)),
    ('40 - 50 s', '×2', Color(0xFF4DD0E1)),
    ('30 - 40 s', '×1.5', Color(0xFFFFB02E)),
    ('0 - 30 s', '×1', Color(0xFFFF8FAB)),
  ];

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(width: 300, child: _content()),
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: anim,
          builder: (context, _) {
            final left = 60 - 24 * Curves.easeInOut.transform(anim.value);
            final tier = left >= 50
                ? 0
                : left >= 40
                ? 1
                : left >= 30
                ? 2
                : 3;
            return Column(
              children: [
                OutlinedText(left.toStringAsFixed(1), size: 76),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < _tiers.length; i++)
                      AnimatedScale(
                        scale: i == tier ? 1.12 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _tiers[i].$3.withValues(
                              alpha: i == tier ? 1 : 0.55,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${_tiers[i].$1}  ${_tiers[i].$2}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RewardArt extends StatelessWidget {
  const _RewardArt({required this.anim});

  final AnimationController anim;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(width: 300, child: _content()),
    );
  }

  Widget _content() {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        double pop(double from) => Curves.elasticOut.transform(
          ((anim.value - from) / 0.25).clamp(0.0, 1.0),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Transform.scale(
                    scale: pop(0.05 + i * 0.15).clamp(0.0, 1.3),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 80,
                      color: Color(0xFFFFC93C),
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Transform.scale(
              scale: pop(0.5).clamp(0.0, 1.3),
              child: const OutlinedText(
                '+100 🪙',
                size: 56,
                fill: Color(0xFFFFC93C),
                stroke: Color(0xFF7A2E0E),
              ),
            ),
          ],
        );
      },
    );
  }
}
