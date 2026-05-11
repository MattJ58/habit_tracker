import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.opacity = 0.42,
    this.blur = 28,
    this.shadowOpacity = 0.1,
    this.shadowBlur = 38,
    this.shadowOffset = const Offset(0, 22),
    this.borderOpacity = 0.58,
    this.animationDuration = const Duration(milliseconds: 240),
    this.animationCurve = Curves.easeOutCubic,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double opacity;
  final double blur;
  final double shadowOpacity;
  final double shadowBlur;
  final Offset shadowOffset;
  final double borderOpacity;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.panelShadow.withValues(alpha: shadowOpacity),
            blurRadius: shadowBlur,
            spreadRadius: -8,
            offset: shadowOffset,
          ),
          BoxShadow(
            color: AppColors.glassWhite(0.28),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.glassWhite(opacity + 0.1),
                  AppColors.glassWhite(opacity),
                  AppColors.glassWhite(opacity * 0.68),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.glassWhite(borderOpacity)),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
