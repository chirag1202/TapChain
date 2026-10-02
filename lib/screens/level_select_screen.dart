import 'package:flutter/material.dart';

import '../game/backgrounds.dart';
import '../game/level_config.dart';
import '../game/levels/levels.dart';
import '../game/physics_objects.dart';
import '../services/local_storage.dart';
import '../widgets/common.dart';
import '../widgets/home_background.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhysicsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 32,
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Center(child: OutlinedText('LEVELS', size: 34)),
                    ),
                    const CoinCounter(),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: LocalStorage.instance.unlockedLevel,
                  builder: (context, unlocked, _) => LayoutBuilder(
                    builder: (context, box) {
                      const gap = 16.0;
                      final cardW = (box.maxWidth - gap * 3) / 2;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(gap),
                        child: Center(
                          child: Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final level in allLevels)
                                _LevelCard(
                                  level: level,
                                  width: cardW,
                                  unlocked: level.id <= unlocked,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.width,
    required this.unlocked,
  });

  final LevelConfig level;
  final double width;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = level.theme;
    return BounceButton(
      onTap: unlocked
          ? () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GameScreen(levelId: level.id),
              ),
            )
          : null,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: unlocked ? theme.accent : Colors.white54,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              offset: Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 9 / 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: LevelPreviewPainter(level)),
                    if (!unlocked)
                      const ColoredBox(
                        color: Color(0xAA1B1B2F),
                        child: Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: unlocked
                              ? const Color(0xFFFFC93C)
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '${level.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF1B2A6B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              level.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1B2A6B),
              ),
            ),
            Text(
              '${theme.emoji} ${theme.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A6280)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniature of the real level: same background palette and objects.
class LevelPreviewPainter extends CustomPainter {
  LevelPreviewPainter(this.level);

  final LevelConfig level;

  static const double _top = 2.0;
  static const double _bottom = 15.2;

  @override
  void paint(Canvas c, Size s) {
    final theme = level.theme;
    final scale = s.width / kWorldWidth;
    final viewH = _bottom - _top;
    final fit = s.height / viewH;
    final k = scale < fit ? scale : fit;
    c.save();
    c.clipRect(Offset.zero & s);
    paintBackground(c, s, theme, 0);
    final oy = -_top * k + (s.height - viewH * k) / 2;
    final ox = (s.width - kWorldWidth * k) / 2;
    paintGround(c, s, oy + kGroundY * k, k, theme, 0);
    c.translate(ox, oy);
    c.scale(k);
    for (final o in level.objects) {
      c.save();
      c.translate(o.x, o.y);
      c.rotate(o.angle);
      paintObject(c, theme, o.kind, w: o.w, h: o.h, radius: o.radius);
      c.restore();
    }
    c.restore();
  }

  @override
  bool shouldRepaint(LevelPreviewPainter old) => old.level != level;
}
