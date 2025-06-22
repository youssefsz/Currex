import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Return adaptive value for different screen sizes
  static T getAdaptiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Get font size adjusted for screen size
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.2;
    return baseFontSize * 1.4; // Desktop
  }

  // Get padding adjusted for screen size
  static EdgeInsets getPadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getAdaptiveValue(
      context: context,
      mobile: mobile ?? const EdgeInsets.all(16.0),
      tablet: tablet ?? const EdgeInsets.all(24.0),
      desktop: desktop ?? const EdgeInsets.all(32.0),
    );
  }

  // Get widget width as a percentage of screen width
  static double getWidthPercentage(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  // Get adaptive column count for grids
  static int getAdaptiveGridCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3; // Desktop
  }

  // Get adaptive card or container width
  static double getAdaptiveContainerWidth(BuildContext context) {
    if (isMobile(context)) return getScreenWidth(context) * 0.9;
    if (isTablet(context)) return getScreenWidth(context) * 0.7;
    return getScreenWidth(context) * 0.5; // Desktop
  }
}
