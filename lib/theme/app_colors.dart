import 'package:flutter/cupertino.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFF3F5F9);
  static const Color primaryText = Color(0xFF172033);
  static const Color secondaryText = Color(0xFF6D7890);
  static const Color accent = Color(0xFF2E6BFF);
  static const Color darkControl = Color(0xFF162033);
  static const Color panelShadow = Color(0xFF30415E);

  static const Color zeroProgress = Color(0xFFE7EDF5);
  static const Color partialSoft = Color(0xFFC9DBFF);
  static const Color partial = Color(0xFF8EB6FF);
  static const Color complete = Color(0xFF8AD7B7);

  static const Color navActive = Color(0xFF172033);
  static const Color navInactive = Color(0xFF77839B);
  static const Color streakAccent = Color(0xFFEF9F49);
  static const Color streakText = Color(0xFF9C5A10);

  static Color glassWhite(double opacity) {
    return CupertinoColors.white.withValues(alpha: opacity.clamp(0, 1));
  }

  static Color progressColor(double progress) {
    final amount = progress.clamp(0, 1).toDouble();
    if (amount == 0) {
      return darkControl;
    }
    return Color.lerp(partial, complete, amount)!;
  }

  static List<Color> progressGradient(double progress) {
    final base = progressColor(progress);
    return [
      Color.lerp(partialSoft, base, 0.55)!,
      Color.lerp(base, complete, 0.35)!,
    ];
  }

  static Color progressTextColor(double progress) {
    final amount = progress.clamp(0, 1).toDouble();
    if (amount >= 1) {
      return primaryText;
    }
    if (amount > 0) {
      return Color.lerp(accent, primaryText, 0.2)!;
    }
    return secondaryText;
  }

  static Color progressBorderColor(double progress) {
    final amount = progress.clamp(0, 1).toDouble();
    if (amount == 0) {
      return glassWhite(0.58);
    }
    return progressColor(amount).withValues(alpha: 0.5 + amount * 0.18);
  }
}
