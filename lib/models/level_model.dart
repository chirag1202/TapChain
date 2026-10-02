const double kStartTime = 60.0;

class LevelResult {
  const LevelResult({
    required this.timeLeft,
    required this.baseReward,
    this.fallenObjects = 0,
    this.totalObjects = 0,
  });

  final double timeLeft;
  final int baseReward;
  final int fallenObjects;
  final int totalObjects;

  double get multiplier => multiplierFor(timeLeft);

  int get baseScore {
    if (totalObjects <= 0) return baseReward;
    final coverage = (fallenObjects / totalObjects).clamp(0.0, 1.0);
    return (baseReward * coverage).round();
  }

  int get reward => (baseScore * multiplier).round();

  int get stars {
    if (totalObjects > 0) {
      final coverage = (fallenObjects / totalObjects).clamp(0.0, 1.0);
      if (coverage >= 0.8) return 3;
      if (coverage >= 0.5) return 2;
      return 1;
    }

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
