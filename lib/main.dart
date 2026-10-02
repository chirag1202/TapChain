import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await LocalStorage.init();
  AudioService.instance.init();
  runApp(const TapChainApp());
}

class TapChainApp extends StatelessWidget {
  const TapChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapChain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4B6CFF),
      ),
      home: const SplashScreen(),
    );
  }
}
