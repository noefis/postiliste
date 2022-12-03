import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeDataLight(BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.white,
      backgroundColor: const Color(0xffF1F5FB),
      indicatorColor: const Color(0xffCBDCF8),
      hintColor: const Color(0xffEECED3),
      highlightColor: const Color(0xffFCE192),
      hoverColor: Color.fromARGB(255, 223, 223, 223),
      focusColor: const Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      shadowColor: Colors.white60,
      unselectedWidgetColor: Colors.black,
      cardColor: Colors.white,
      canvasColor: Colors.grey[50],
      brightness: Brightness.light,
      buttonTheme: Theme.of(context)
          .buttonTheme
          .copyWith(colorScheme: const ColorScheme.light()),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
      ),
      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: Colors.black54),
    );
  }

  static ThemeData themeDataDark(BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.black,
      backgroundColor: Colors.black,
      indicatorColor: const Color(0xff0E1D36),
      hintColor: const Color(0xff280C0B),
      highlightColor: const Color(0xff372901),
      hoverColor: const Color(0xff3A3A3B),
      focusColor: const Color(0xff0B2512),
      disabledColor: Colors.grey,
      shadowColor: Colors.white30,
      unselectedWidgetColor: Colors.white,
      cardColor: const Color(0xFF151515),
      canvasColor: Colors.black,
      brightness: Brightness.dark,
      toggleableActiveColor: Colors.red,
      buttonTheme: Theme.of(context)
          .buttonTheme
          .copyWith(colorScheme: const ColorScheme.dark()),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
      ),
      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: Colors.white70),
    );
  }
}
