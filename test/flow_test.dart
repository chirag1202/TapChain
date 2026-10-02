import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapchain/main.dart';
import 'package:tapchain/services/local_storage.dart';

void main() {
  testWidgets('splash -> home -> level 1 -> success -> level 2 unlocked', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ftueSeen': true});
    await LocalStorage.init();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TapChainApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('PLAY'), findsWidgets);

    await tester.tap(find.text('PLAY').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('TAP TO START'), findsWidgets);
    expect(find.textContaining(RegExp(r'^\d{1,2}\.\d$')), findsWidgets);

    await tester.tapAt(const Offset(180, 400));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('CHAIN COMPLETE'), findsWidgets);
    expect(LocalStorage.instance.isUnlocked(2), isTrue);
    expect(LocalStorage.instance.coins.value, greaterThan(0));
  });

  testWidgets('first launch shows the walkthrough once', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TapChainApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('LOOK'), findsWidgets);
    expect(LocalStorage.instance.ftueSeen, isFalse);

    for (final step in ['THINK', 'TAP', 'WATCH']) {
      await tester.tap(find.text('NEXT').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(step), findsWidgets);
    }
    await tester.tap(find.text("LET'S GO!").last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(LocalStorage.instance.ftueSeen, isTrue);
    expect(find.text('PLAY'), findsWidgets);
  });

  testWidgets('level select shows locked and unlocked cards', (tester) async {
    SharedPreferences.setMockInitialValues({
      'unlockedLevel': 3,
      'ftueSeen': true,
    });
    await LocalStorage.init();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TapChainApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('LEVELS').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));
    expect(find.text('Chain Master'), findsOneWidget);
  });
}
