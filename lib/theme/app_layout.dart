import 'package:flutter/cupertino.dart';

class AppLayout {
  const AppLayout._();

  static const double maxContentWidth = 720;
  static const double bottomNavMaxWidth = 420;
  static const double bottomNavRadius = 28;
  static const double bottomNavHeight = 70;
  static const double fabSize = 68;

  static const double cardSpacing = 16;
  static const double cardRadius = 28;
  static const double spacingXs = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;

  static const EdgeInsets todayCardPadding = EdgeInsets.fromLTRB(
    18,
    18,
    16,
    16,
  );

  static double horizontalPaddingFor(double width) {
    if (width >= 1024) {
      return 36;
    }
    if (width >= 720) {
      return 28;
    }
    return 18;
  }

  static double topPaddingFor(double height) {
    if (height >= 900) {
      return 20;
    }
    return 8;
  }

  static double headerBottomPaddingFor(double height) {
    if (height >= 900) {
      return 30;
    }
    return 20;
  }

  static double bottomNavBottomOffset(double bottomSafeArea) {
    return 14 + bottomSafeArea;
  }

  static double fabBottomOffset(double bottomSafeArea) {
    return bottomNavBottomOffset(bottomSafeArea) + bottomNavHeight + 18;
  }

  static double scrollBottomPadding(double bottomSafeArea) {
    return fabBottomOffset(bottomSafeArea) + fabSize + 26;
  }
}
