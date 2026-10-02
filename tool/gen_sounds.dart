// Generates the bundled sound effects. Run: dart run tool/gen_sounds.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int rate = 22050;
final math.Random rng = math.Random(3);

List<double> tone(
  double f0,
  double f1,
  double dur, {
  double decay = 6,
  double vol = 0.8,
}) {
  final n = (dur * rate).round();
  final out = List<double>.filled(n, 0);
  var phase = 0.0;
  for (var i = 0; i < n; i++) {
    final t = i / n;
    final f = f0 + (f1 - f0) * t;
    phase += 2 * math.pi * f / rate;
    out[i] = math.sin(phase) * math.exp(-decay * t) * vol;
  }
  return out;
}

List<double> noise(double dur, {double decay = 20, double vol = 0.6}) {
  final n = (dur * rate).round();
  var lp = 0.0;
  return List<double>.generate(n, (i) {
    lp += 0.45 * ((rng.nextDouble() * 2 - 1) - lp);
    return lp * math.exp(-decay * i / n) * vol;
  });
}

List<double> mix(List<List<double>> parts, [List<double>? offsets]) {
  var len = 0;
  for (var i = 0; i < parts.length; i++) {
    final off = ((offsets?[i] ?? 0) * rate).round();
    len = math.max(len, off + parts[i].length);
  }
  final out = List<double>.filled(len, 0);
  for (var i = 0; i < parts.length; i++) {
    final off = ((offsets?[i] ?? 0) * rate).round();
    for (var j = 0; j < parts[i].length; j++) {
      out[off + j] += parts[i][j];
    }
  }
  return out;
}

void write(String name, List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  str(8, 'WAVEfmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  str(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(
      44 + i * 2,
      (samples[i].clamp(-1.0, 1.0) * 32000).round(),
      Endian.little,
    );
  }
  File('assets/audio/$name.wav')
    ..createSync(recursive: true)
    ..writeAsBytesSync(data.buffer.asUint8List());
}

void main() {
  write('tap', tone(700, 500, 0.08, decay: 7));
  write(
    'domino',
    mix([noise(0.05, decay: 14), tone(420, 260, 0.06, decay: 8, vol: 0.4)]),
  );
  write('ball', tone(520, 240, 0.14, decay: 5));
  write(
    'box',
    mix([
      noise(0.12, decay: 10, vol: 0.7),
      tone(110, 55, 0.2, decay: 5, vol: 0.9),
    ]),
  );
  write(
    'target',
    mix(
      [tone(660, 660, 0.3, decay: 4), tone(990, 990, 0.35, decay: 4)],
      [0, 0.08],
    ),
  );
  write(
    'coin',
    mix(
      [tone(988, 988, 0.08, decay: 3), tone(1319, 1319, 0.2, decay: 5)],
      [0, 0.07],
    ),
  );
  write(
    'win',
    mix(
      [
        for (final f in [523.0, 659.0, 784.0, 1047.0])
          tone(f, f, 0.25, decay: 4),
      ],
      [0, 0.12, 0.24, 0.36],
    ),
  );
  write(
    'fail',
    mix(
      [tone(330, 330, 0.2, decay: 4), tone(247, 247, 0.35, decay: 4)],
      [0, 0.18],
    ),
  );
}
