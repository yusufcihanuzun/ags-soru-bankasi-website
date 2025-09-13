import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResponsiveHelper {
  static const double _smallScreenWidth = 360;
  static const double _mediumScreenWidth = 400;
  static const double _largeScreenWidth = 600;
  static const double _extraSmallScreenWidth = 320; // Çok küçük ekranlar için

  static bool isExtraSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _extraSmallScreenWidth;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallScreenWidth;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _smallScreenWidth && width < _mediumScreenWidth;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeScreenWidth;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeScreenWidth;
  }

  // Responsive padding values
  static double getHorizontalPadding(BuildContext context) {
    if (isExtraSmallScreen(context)) return 8.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 12.0;
    if (isMediumScreen(context)) return 16.0;
    return 20.0;
  }

  static double getVerticalPadding(BuildContext context) {
    if (isExtraSmallScreen(context)) return 12.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 16.0;
    if (isMediumScreen(context)) return 20.0;
    return 24.0;
  }

  // Responsive font sizes
  static double getHeaderFontSize(BuildContext context) {
    if (isExtraSmallScreen(context)) return 16.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 18.0;
    if (isMediumScreen(context)) return 21.0;
    return 24.0;
  }

  static double getSubheaderFontSize(BuildContext context) {
    if (isExtraSmallScreen(context)) return 11.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 12.0;
    return 14.0;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isExtraSmallScreen(context)) return 13.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 14.0;
    return 16.0;
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context, {double defaultSize = 24.0}) {
    if (isExtraSmallScreen(context))
      return defaultSize * 0.7; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return defaultSize * 0.8;
    return defaultSize;
  }

  // Grid view responsive values
  static int getGridCrossAxisCount(BuildContext context) {
    if (isTablet(context)) return 3;
    return 2;
  }

  static double getGridAspectRatio(BuildContext context) {
    if (isSmallScreen(context)) return 1.4;
    if (isMediumScreen(context)) return 1.5;
    return 1.6;
  }

  static double getGridSpacing(BuildContext context) {
    if (isSmallScreen(context)) return 8.0;
    return 12.0;
  }

  // Navigation bar responsive values
  static double getNavBarWidth(BuildContext context) {
    if (isExtraSmallScreen(context)) return 160.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 180.0;
    return 200.0;
  }

  static double getNavBarHeight(BuildContext context) {
    if (isExtraSmallScreen(context)) return 40.0; // Çok küçük ekranlar için
    if (isSmallScreen(context)) return 45.0;
    return 60.0;
  }

  static double getNavBarItemSize(BuildContext context,
      {bool isPrimary = false}) {
    if (isExtraSmallScreen(context)) {
      return isPrimary ? 32.0 : 26.0; // Çok küçük ekranlar için
    }
    if (isSmallScreen(context)) {
      return isPrimary ? 36.0 : 30.0;
    }
    return isPrimary ? 48.0 : 40.0;
  }

  static double getNavBarIconSize(BuildContext context,
      {bool isPrimary = false}) {
    if (isExtraSmallScreen(context)) {
      return isPrimary ? 16.0 : 12.0; // Çok küçük ekranlar için
    }
    if (isSmallScreen(context)) {
      return isPrimary ? 18.0 : 14.0;
    }
    return isPrimary ? 24.0 : 20.0;
  }

  // Safe area values
  static EdgeInsets getContentPadding(BuildContext context) {
    final padding = getHorizontalPadding(context);
    return EdgeInsets.all(padding);
  }

  static EdgeInsets getHeaderPadding(BuildContext context) {
    final horizontal = getHorizontalPadding(context);
    final vertical = getVerticalPadding(context);
    return EdgeInsets.fromLTRB(
        horizontal, vertical, horizontal, vertical * 0.8);
  }

  // Responsive border radius
  static double getBorderRadius(BuildContext context,
      {double defaultRadius = 12.0}) {
    if (isSmallScreen(context)) return defaultRadius * 0.8;
    return defaultRadius;
  }

  // Screen size getters
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Status bar and bottom padding
  static EdgeInsets getViewPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding.bottom;
  }

  // Orientation helpers
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Banner ad responsive sizes
  static AdSize getBannerAdSize(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      // Çok küçük ekranlar için küçük banner
      return AdSize.banner; // 320x50
    } else if (isSmallScreen(context)) {
      // Küçük ekranlar için orta boyut banner
      return AdSize.mediumRectangle; // 300x250
    } else if (isTablet(context)) {
      // Tablet'ler için büyük banner
      return AdSize.largeBanner; // 320x100
    } else {
      // Orta boyut ekranlar için standart banner
      return AdSize.largeBanner; // 320x100
    }
  }

  // Banner ad padding
  static EdgeInsets getBannerPadding(BuildContext context) {
    final horizontal = getHorizontalPadding(context);
    final vertical = getVerticalPadding(context) *
        0.5; // Banner'lar için daha az vertical padding

    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  // Banner ad margin
  static EdgeInsets getBannerMargin(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    }
  }
}
