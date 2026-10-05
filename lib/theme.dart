import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const bg = Color(0xFF121212);
  static const surface = Color(0xFF1D1D1B);
  static const surface2 = Color(0xFF262624);
  static const border = Color(0xFF33332F);
  static const text = Color(0xFFF2F0EA);
  static const muted = Color(0xFFA3A199);
  static const muted2 = Color(0xFF8F8D86);
  static const nav = Color(0xFF171716);
  static const navBorder = Color(0xFF2A2A27);
  static const off = Color(0xFF3A3A35);
  static const dash = Color(0xFF44443F);
  static const gold = Color(0xFFE7B54A);
  static const goldBg = Color(0xFF1F1B12);
  static const goldBorder = Color(0xFF4A3E22);
  static const goldInk = Color(0xFF1A1408);
  static const goldMuted = Color(0xFFC9B27A);
  static const trophyBg = Color(0xFF0E0D0B);
}

TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w800, double? height}) =>
    GoogleFonts.barlowCondensed(
        fontSize: size, fontWeight: weight, color: color ?? C.text, height: height, letterSpacing: 0.3);

TextStyle body(double size,
        {Color? color, FontWeight weight = FontWeight.w500, double? letterSpacing, double? height}) =>
    GoogleFonts.dmSans(
        fontSize: size, fontWeight: weight, color: color ?? C.text, letterSpacing: letterSpacing, height: height);

TextStyle eyebrow(Color color) => body(12, color: color, weight: FontWeight.w700, letterSpacing: 1.2);

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = C.surface,
    this.borderColor = C.border,
    this.radius = 20,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
      ),
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class Bar extends StatelessWidget {
  const Bar({super.key, required this.value, required this.color, this.track = C.border, this.height = 4});
  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(children: [
          Positioned.fill(child: ColoredBox(color: track)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(height / 2)),
            ),
          ),
        ]),
      ),
    );
  }
}

class Chip2 extends StatelessWidget {
  const Chip2(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: body(12, weight: FontWeight.w600)),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.ink = C.bg,
    this.height = 56,
    this.displayFont = false,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color ink;
  final double height;
  final bool displayFont;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              displayFont ? label.toUpperCase() : label,
              style: displayFont ? display(22, color: ink) : body(15, color: ink, weight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelBars extends StatelessWidget {
  const LevelBars({super.key, required this.level, required this.color});
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(left: 3),
            width: 6,
            height: 10.0 + i * 5,
            decoration: BoxDecoration(
              color: i < level ? color : C.off,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
