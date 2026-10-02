import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import '../widgets/common.dart';
import '../widgets/home_background.dart';
import '../widgets/tapchain_logo.dart';
import 'ftue_screen.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _play() {
    final level = LocalStorage.instance.unlockedLevel.value;
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => GameScreen(levelId: level)));
  }

  void _levels() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LevelSelectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: PhysicsBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(top: 12, right: 16, child: CoinCounter()),
              Positioned(
                top: 6,
                left: 8,
                child: IconButton(
                  iconSize: 32,
                  color: Colors.white,
                  tooltip: 'How to play',
                  icon: const Icon(Icons.help_outline_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FtueScreen(replay: true),
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TapChainLogo(width: w * 0.82),
                      const SizedBox(height: 36),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) => Transform.scale(
                          scale: 1 + 0.05 * _pulse.value,
                          child: child,
                        ),
                        child: GameButton(
                          label: 'PLAY',
                          fontSize: 44,
                          width: w * 0.64,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          onTap: _play,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GameButton(
                        label: 'LEVELS',
                        fontSize: 26,
                        width: w * 0.5,
                        color: const Color(0xFFFFB02E),
                        dark: const Color(0xFFB36A00),
                        onTap: _levels,
                      ),
                    ],
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
