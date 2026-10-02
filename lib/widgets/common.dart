import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/local_storage.dart';

/// Scales down while pressed and springs back; plays the tap sound.
class BounceButton extends StatefulWidget {
  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.silent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool silent;

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              if (!widget.silent) AudioService.instance.tap();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: Duration(milliseconds: _down ? 70 : 220),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Text with a thick outline, the look used across the casual UI.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    this.size = 24,
    this.fill = Colors.white,
    this.stroke = const Color(0xFF1B2A6B),
    this.strokeWidth,
    this.letterSpacing = 0,
  });

  final String text;
  final double size;
  final Color fill;
  final Color stroke;
  final double? strokeWidth;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing,
      height: 1.05,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth ?? size * 0.22
              ..strokeJoin = StrokeJoin.round
              ..color = stroke,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(color: fill),
        ),
      ],
    );
  }
}

/// Chunky pill button.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF3DDC84),
    this.dark = const Color(0xFF1E9E57),
    this.fontSize = 24,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color dark;
  final double fontSize;
  final double? width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 56),
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, Colors.white, 0.25)!, color],
          ),
          border: Border.all(color: dark, width: 3),
          boxShadow: [
            BoxShadow(color: dark, offset: const Offset(0, 5)),
            const BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 9),
              blurRadius: 8,
            ),
          ],
        ),
        child: OutlinedText(label, size: fontSize, stroke: dark),
      ),
    );
  }
}

class CoinCounter extends StatelessWidget {
  const CoinCounter({super.key, this.valueOverride});

  final int? valueOverride;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorage.instance.coins,
      builder: (context, coins, _) => _pill(valueOverride ?? coins),
    );
  }

  Widget _pill(int value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x99000000),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFC93C), width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🪙', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}
