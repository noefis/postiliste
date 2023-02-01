import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeDataLight(BuildContext context) {
    return ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        indicatorColor: const Color.fromARGB(255, 236, 236, 236),
        hintColor: const Color(0xffEECED3),
        highlightColor: const Color(0xffFCE192),
        hoverColor: const Color.fromARGB(255, 223, 223, 223),
        focusColor: const Color(0xffA8DAB5),
        disabledColor: Colors.black54,
        secondaryHeaderColor: Colors.white12,
        shadowColor: Colors.grey,
        unselectedWidgetColor: const Color.fromARGB(255, 24, 24, 24),
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
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: const Color.fromARGB(255, 12, 105, 182)));
  }

  static ThemeData themeDataDark(BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.black,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      indicatorColor: const Color.fromARGB(255, 23, 23, 23),
      hintColor: const Color(0xff280C0B),
      highlightColor: const Color(0xff372901),
      hoverColor: const Color(0xff3A3A3B),
      focusColor: const Color(0xff0B2512),
      disabledColor: Colors.grey,
      secondaryHeaderColor: Colors.white54,
      shadowColor: Colors.white30,
      unselectedWidgetColor: const Color.fromARGB(225, 255, 255, 255),
      cardColor: const Color.fromARGB(255, 9, 9, 9),
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
