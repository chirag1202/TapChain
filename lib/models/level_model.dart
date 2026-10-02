const double kStartTime = 60.0;

class LevelResult {
  const LevelResult({required this.timeLeft, required this.baseReward});

  final double timeLeft;
  final int baseReward;

  double get multiplier => multiplierFor(timeLeft);

  int get reward => (baseReward * multiplier).round();

  int get stars {
    final m = multiplier;
    if (m >= 3) return 3;
    if (m >= 2) return 2;
    return 1;
  }

  static double multiplierFor(double timeLeft) {
    if (timeLeft >= 50) return 3;
    if (timeLeft >= 40) return 2;
    if (timeLeft >= 30) return 1.5;
    return 1;
  }

  // Floors to tenths so the frozen value always matches the HUD digits.
  static double floorTenths(double seconds) =>
      (seconds.clamp(0, kStartTime) * 10).floor() / 10;

  static String formatMultiplier(double m) =>
      m == m.roundToDouble() ? '×${m.toInt()}' : '×$m';
}
