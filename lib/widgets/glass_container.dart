import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color color;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 5,
    this.opacity = 0.15,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withAlpha(
              (opacity * 255).round(),
            ), 
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withAlpha((opacity * 255).round()),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
