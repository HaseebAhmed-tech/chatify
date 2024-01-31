import 'package:chatify/resources/constants/styles.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  bool get isLight => themeMode == ThemeMode.light;

  // Define a getter named 'provider' that returns a Provider
  static ThemeProvider instance = ThemeProvider();

  changeAppTheme(String theme) {
    if (theme == 'light') {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    _updateColorScheme();
    notifyListeners();
  }

  _updateColorScheme() {
    if (themeMode == ThemeMode.dark) {
      _updateDarkColors();
    } else {
      _updateLightColors();
    }
  }

  _updateDarkColors() {
    Styles.scaffoldBackgroundColor = const Color.fromRGBO(28, 27, 27, 1);
    Styles.primaryColor = const Color.fromRGBO(42, 117, 188, 1);
    Styles.primaryTextColor = Colors.white;
    Styles.secondryTextColor = Colors.white54;
    notifyListeners();
  }

  _updateLightColors() {
    Styles.scaffoldBackgroundColor = Colors.white;
    Styles.primaryColor = Colors.blueAccent;
    Styles.primaryTextColor = Colors.black;
    Styles.secondryTextColor = Colors.black54;
    notifyListeners();
  }
}
