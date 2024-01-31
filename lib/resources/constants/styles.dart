import 'package:flutter/material.dart';

class Styles {
  static Color scaffoldBackgroundColor = const Color.fromRGBO(28, 27, 27, 1);

  static Color primaryColor = const Color.fromRGBO(42, 117, 188, 1);

  static Color primaryTextColor = Colors.white;
  static Color secondryTextColor = Colors.white54;

  static Color errorColor = Colors.red;

  static TextStyle displayLargeTheme = const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w500,
  );
  static TextStyle headlineLargeTheme = const TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.w700,
  );
  static TextStyle headlineMediumTheme = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w200,
  );

  static TextStyle displayMedNormalStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static TextStyle displaySmNormalStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static TextStyle displaySmallStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
  );
  static TextStyle headingSmallStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static TextStyle titleLargeStyle = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w500,
  );

  static List<Color> gradient(bool isOwnMessage) {
    return isOwnMessage
        ? const [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : const [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
  }
}
