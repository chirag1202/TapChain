import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import '../widgets/home_background.dart';
import '../widgets/tapchain_logo.dart';
import 'ftue_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(_goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => LocalStorage.instance.ftueSeen
            ? const HomeScreen()
            : const FtueScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: PhysicsBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final pop = Curves.elasticOut.transform(
                (_c.value * 1.6).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: (_c.value * 4).clamp(0.0, 1.0),
                child: Transform.scale(scale: 0.6 + 0.4 * pop, child: child),
              );
            },
            child: TapChainLogo(width: w * 0.8),
          ),
        ),
      ),
    );
  }
}
