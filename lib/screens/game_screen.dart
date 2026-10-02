import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/level_config.dart';
import '../game/levels/levels.dart';
import '../game/tap_chain_game.dart';
import '../models/level_model.dart';
import '../services/audio_service.dart';
import '../services/local_storage.dart';
import '../widgets/common.dart';
import '../widgets/fireworks.dart';
import '../widgets/result_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LevelConfig level = allLevels[widget.levelId - 1];
  late final TapChainGame game = TapChainGame(
    level: level,
    onFinished: _onFinished,
  );

  LevelResult? _result;
  bool _finished = false;

  void _onFinished(LevelResult? result) {
    final storage = LocalStorage.instance;
    if (result != null) {
      storage.addCoins(result.reward);
      storage.unlock(level.id + 1);
      AudioService.instance.win();
    } else {
      AudioService.instance.fail();
    }
    if (!mounted) return;
    setState(() {
      _result = result;
      _finished = true;
    });
  }

  void _open(int id) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => GameScreen(levelId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    game.setInsets(top: pad.top + 72, bottom: pad.bottom + 64);
    final hasNext = level.id < allLevels.length;

    return Scaffold(
      backgroundColor: level.theme.skyBottom,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => game.handleTap(),
            child: GameWidget(game: game),
          ),
          Positioned(
            top: pad.top + 8,
            left: 14,
            right: 14,
            child: _Hud(game: game, level: level),
          ),
          Positioned(
            bottom: pad.bottom + 20,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: ValueListenableBuilder<GameState>(
                valueListenable: game.stateNotifier,
                builder: (context, state, _) => AnimatedOpacity(
                  opacity: state == GameState.waiting ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Center(child: _TapPrompt()),
                ),
              ),
            ),
          ),
          if (_finished)
            Positioned.fill(
              child: IgnorePointer(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, v, _) => ColoredBox(
                    color: Colors.black.withValues(alpha: 0.5 * v),
                  ),
                ),
              ),
            ),
          ValueListenableBuilder<GameState>(
            valueListenable: game.stateNotifier,
            builder: (context, state, _) => state == GameState.success
                ? const Positioned.fill(child: Fireworks())
                : const SizedBox.shrink(),
          ),
          if (_finished && _result != null)
            ResultOverlay(
              result: _result!,
              hasNext: hasNext,
              onNext: () => _open(level.id + 1),
              onReplay: () => _open(level.id),
              onLevels: () => Navigator.of(context).pop(),
            ),
          if (_finished && _result == null)
            FailOverlay(
              onReplay: () => _open(level.id),
              onLevels: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.game, required this.level});

  final TapChainGame game;
  final LevelConfig level;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedText('LEVEL ${level.id}', size: 20),
                  Text(
                    level.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: Listenable.merge([game.displayTime, game.stateNotifier]),
          builder: (context, _) {
            final t = game.displayTime.value;
            final frozen = game.stateNotifier.value != GameState.waiting;
            final color = frozen
                ? const Color(0xFF7DF9FF)
                : t < 10
                ? const Color(0xFFFF6B6B)
                : Colors.white;
            return OutlinedText(t.toStringAsFixed(1), size: 46, fill: color);
          },
        ),
        const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(fit: BoxFit.scaleDown, child: CoinCounter()),
          ),
        ),
      ],
    );
  }
}

class _TapPrompt extends StatefulWidget {
  const _TapPrompt();

  @override
  State<_TapPrompt> createState() => _TapPromptState();
}

class _TapPromptState extends State<_TapPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) =>
          Transform.scale(scale: 1 + 0.06 * _c.value, child: child),
      child: const OutlinedText('TAP TO START', size: 28),
    );
  }
}
