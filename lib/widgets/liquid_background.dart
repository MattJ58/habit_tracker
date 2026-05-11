import 'dart:ui';

import 'package:flutter/cupertino.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3F5F9),
            Color(0xFFEFF3F8),
            Color(0xFFF8F7FB),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            left: -190,
            top: -160,
            child: _LiquidBlob(
              colors: [Color(0xFFAFCBFF), Color(0xFFE9F1FF)],
              width: 420,
              height: 360,
              opacity: 0.5,
              blur: 70,
            ),
          ),
          const Positioned(
            right: -210,
            top: 120,
            child: _LiquidBlob(
              colors: [Color(0xFFC7EFE5), Color(0xFFEAF8F5)],
              width: 460,
              height: 410,
              opacity: 0.42,
              blur: 78,
            ),
          ),
          const Positioned(
            left: -120,
            bottom: -190,
            child: _LiquidBlob(
              colors: [Color(0xFFE4D7FF), Color(0xFFF7ECFF)],
              width: 430,
              height: 380,
              opacity: 0.42,
              blur: 84,
            ),
          ),
          const Positioned(
            right: 18,
            bottom: 110,
            child: _LiquidBlob(
              colors: [Color(0xFFBFD9FF), Color(0xFFEAF3FF)],
              width: 260,
              height: 230,
              opacity: 0.24,
              blur: 66,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.white.withValues(alpha: 0.18),
                  CupertinoColors.white.withValues(alpha: 0.02),
                  const Color(0xFFDCE7F4).withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _LiquidBlob extends StatelessWidget {
  const _LiquidBlob({
    required this.colors,
    required this.width,
    required this.height,
    required this.opacity,
    required this.blur,
  });

  final List<Color> colors;
  final double width;
  final double height;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width),
            gradient: RadialGradient(
              center: const Alignment(-0.28, -0.34),
              radius: 0.82,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}
