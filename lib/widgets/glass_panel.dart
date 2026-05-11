import 'dart:ui';

import 'package:flutter/cupertino.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.opacity = 0.42,
    this.blur = 28,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30415E).withValues(alpha: 0.1),
            blurRadius: 38,
            spreadRadius: -8,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.white.withValues(alpha: opacity + 0.1),
                  CupertinoColors.white.withValues(alpha: opacity),
                  CupertinoColors.white.withValues(alpha: opacity * 0.68),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.58),
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
