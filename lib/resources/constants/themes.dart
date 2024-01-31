import 'package:chatify/resources/constants/styles.dart';
import 'package:flutter/material.dart';

class ThemesData {
  static ThemeData reqThemeData(ThemeMode themeMode) {
    return ThemeData(
      fontFamily: "Outfit",
      iconTheme: IconThemeData(color: Styles.primaryTextColor),
      brightness:
          themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      primaryColor: Styles.primaryColor,
      scaffoldBackgroundColor: Styles.scaffoldBackgroundColor,
      bottomSheetTheme:
          BottomSheetThemeData(backgroundColor: Styles.scaffoldBackgroundColor),
      textTheme: themeMode == ThemeMode.dark
          ? Typography.whiteHelsinki.copyWith(
              displayLarge: Styles.displayLargeTheme
                  .copyWith(color: Styles.primaryTextColor),
              headlineLarge: Styles.headlineLargeTheme
                  .copyWith(color: Styles.primaryTextColor),
              headlineMedium: Styles.headlineMediumTheme
                  .copyWith(color: Styles.primaryTextColor),
              displayMedium: Styles.displayMedNormalStyle
                  .copyWith(color: Styles.primaryTextColor),
              displaySmall: Styles.displaySmallStyle
                  .copyWith(color: Styles.primaryTextColor),
              headlineSmall: Styles.headingSmallStyle
                  .copyWith(color: Styles.primaryTextColor),
              titleLarge: Styles.titleLargeStyle
                  .copyWith(color: Styles.primaryTextColor),
            )
          : Typography.blackHelsinki.copyWith(
              displayLarge: Styles.displayLargeTheme
                  .copyWith(color: Styles.primaryTextColor),
              headlineLarge: Styles.headlineLargeTheme
                  .copyWith(color: Styles.primaryTextColor),
              headlineMedium: Styles.headlineMediumTheme
                  .copyWith(color: Styles.primaryTextColor),
              displayMedium: Styles.displayMedNormalStyle
                  .copyWith(color: Styles.primaryTextColor),
              displaySmall: Styles.displaySmallStyle
                  .copyWith(color: Styles.primaryTextColor),
              headlineSmall: Styles.headingSmallStyle
                  .copyWith(color: Styles.primaryTextColor),
              titleLarge: Styles.titleLargeStyle
                  .copyWith(color: Styles.primaryTextColor),
            ),
    );
  }
}
