import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palette:
/// https://lospec.com/palette-list/ink-crimson
///
/// Palette Name: Ink-Crimson
///
/// Description: 10 colors picks with a bit of blues, for the court of the Crimson King!  Feel free to tag me (@inkpendude) on social media so I can share it too! I love to see what you guys do with this colors.
///
/// Colors: 10
///
/// |Color                |Hex     |
/// |---------------------|--------|
/// |Folly                |FFFF0546|
/// |Amaranth Purple      |FF9C173B|
/// |Tyrian Purple Light  |FF660F31|
/// |Tyrian Purple Dark   |FF450327|
/// |Dark Purple Light    |FF270022|
/// |Dark Purple Dark     |FF17001D|
/// |Licorice             |FF09010D|
/// |Electric Blue        |FF0CE6F2|
/// |Celestial Blue       |FF0098DB|
/// |Lapis Lazuli         |FF1E579C|
class InkCrimson {
  static const Color primaryColor = Color(0xFF450327);
  static const Color onPrimaryColor = Color(0xFFFF0546);
  static const Color primaryContainerColor = Color(0xFF660F31);
  static const Color onPrimaryContainerColor = Color(0xFFFFFFFF);
  static const Color secondaryColor = Color(0xFF9C173B);
  static const Color onSecondaryColor = Color(0xFFFFFFFF);
  static const Color secondaryContainerColor = Color(0xFFFF0546);
  static const Color onSecondaryContainerColor = Color(0xFFFFFFFF);
  static const Color tertiaryColor = Color(0xFF0098DB);
  static const Color onTertiaryColor = Color(0xFFFFFFFF);
  static const Color tertiaryContainerColor = Color(0xFF0CE6F2);
  static const Color onTertiaryContainerColor = Color(0xFF09010D);
  static const Color surfaceColor = Color(0xFF17001D);
  static const Color onSurfaceColor = Color(0xFF0098DB);
  static const Color surfaceVariantColor = Color(0xFF270022);
  static const Color onSurfaceVariantColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF0546);
  static const Color onErrorColor = Color(0xFFFFFFFF);
  static const Color outlineColor = Color(0xFFFF0546);
  static const Color outlineVariantColor = Color(0xFF660F31);
  static const Border border = Border(
    top: BorderSide(color: outlineColor, width: 4),
    left: BorderSide(color: outlineColor, width: 4),
    right: BorderSide(color: outlineVariantColor, width: 4),
    bottom: BorderSide(color: outlineVariantColor, width: 4),
  );
}

const String displayFont = 'Orbitron';
const String headlineFont = 'Orbitron';
const String titleFont = 'Orbitron';
const String bodyFont = 'Roboto Flex';
const String labelFont = 'Press Start 2P';

const TextTheme barkeepTextTheme = TextTheme(
  displayLarge: TextStyle(fontFamily: displayFont, fontSize: 48.0),
  displayMedium: TextStyle(fontFamily: displayFont, fontSize: 36.0),
  displaySmall: TextStyle(fontFamily: displayFont, fontSize: 20.0),
  headlineLarge: TextStyle(fontFamily: headlineFont, fontSize: 40.0),
  headlineMedium: TextStyle(fontFamily: headlineFont, fontSize: 32.0),
  headlineSmall: TextStyle(fontFamily: headlineFont, fontSize: 20.0),
  titleLarge: TextStyle(fontFamily: titleFont, fontSize: 20.0),
  titleMedium: TextStyle(fontFamily: titleFont, fontSize: 18.0),
  titleSmall: TextStyle(fontFamily: titleFont, fontSize: 16.0),
  bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 16.0),
  bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 14.0),
  bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 12.0),
  labelLarge: TextStyle(fontFamily: labelFont, fontSize: 16.0),
  labelMedium: TextStyle(fontFamily: labelFont, fontSize: 12.0),
  labelSmall: TextStyle(fontFamily: labelFont, fontSize: 10.0),
);

const IconThemeData barkeepIconTheme = IconThemeData(
  size: 24.0,
  fill: 0.0,
  weight: 400.0,
  grade: 0.0,
  opticalSize: 48.0,
  color: InkCrimson.onPrimaryColor,
  opacity: 1.0,
  applyTextScaling: true,
);

const ButtonThemeData barkeepButtonStyle = ButtonThemeData(
  textTheme: ButtonTextTheme.normal,
  minWidth: 88.0,
  height: 36.0,
  layoutBehavior: ButtonBarLayoutBehavior.constrained,
  alignedDropdown: false,
);

const ScrollbarThemeData barkeepScrollbarTheme = ScrollbarThemeData(
  thumbVisibility: WidgetStatePropertyAll(false),
  trackVisibility: WidgetStatePropertyAll(false),
);

const AppBarTheme barkeepAppBarTheme = AppBarTheme(
  systemOverlayStyle: SystemUiOverlayStyle.light,
);

TabBarTheme barkeepTabBarTheme = TabBarTheme(
  labelColor: InkCrimson.tertiaryContainerColor,
  labelStyle: barkeepTextTheme.titleLarge,
  unselectedLabelColor: InkCrimson.secondaryColor,
);

ColorScheme barkeepColorScheme =
    ColorScheme.fromSeed(seedColor: InkCrimson.primaryColor).copyWith(
  brightness: Brightness.dark,
  secondary: InkCrimson.secondaryColor,
  secondaryContainer: InkCrimson.secondaryContainerColor,
  tertiary: InkCrimson.tertiaryColor,
  tertiaryContainer: InkCrimson.tertiaryContainerColor,
  surface: InkCrimson.surfaceColor,
  surfaceContainerHighest: InkCrimson.surfaceVariantColor,
  error: InkCrimson.errorColor,
  onPrimary: InkCrimson.onPrimaryColor,
  onSecondary: InkCrimson.onSecondaryColor,
  onTertiary: InkCrimson.onTertiaryColor,
  onSurface: InkCrimson.onSurfaceColor,
  onSurfaceVariant: InkCrimson.onSurfaceVariantColor,
  onError: InkCrimson.onErrorColor,
  outline: InkCrimson.outlineColor,
  outlineVariant: InkCrimson.outlineVariantColor,
);

final ThemeData barkeepTheme = ThemeData(
  scrollbarTheme: barkeepScrollbarTheme,
  brightness: Brightness.dark,
  colorScheme: barkeepColorScheme,
  textTheme: barkeepTextTheme,
  iconTheme: barkeepIconTheme,
  buttonTheme: barkeepButtonStyle,
  appBarTheme: barkeepAppBarTheme,
  tabBarTheme: barkeepTabBarTheme,
  useMaterial3: true,
);
