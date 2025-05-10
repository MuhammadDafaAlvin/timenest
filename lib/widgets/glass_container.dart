import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 5,
    this.opacity = 0.15,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeColor = color ?? Theme.of(context).colorScheme.surface;
    final effectiveOpacity =
        isDarkMode
            ? opacity * 1.5
            : opacity; // Opacity lebih tinggi di mode gelap
    final effectiveBlur =
        isDarkMode ? blur * 0.8 : blur; // Kurangi blur di mode gelap

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          decoration: BoxDecoration(
            color: themeColor.withAlpha((255 * effectiveOpacity).round()),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(
                (255 * (isDarkMode ? 0.4 : 0.2)).round(),
              ),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
