import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postiliste/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/date_item.dart';

import 'dark_theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Styles.themeDataLight(context),
      darkTheme: Styles.themeDataDark(context),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('de', ''), // German, no country code
      ],
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List values = [];
  final now = DateTime.now();

  Text date(DateTime date) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date == tomorrow) {
      return Text(AppLocalizations.of(context)!.tomorrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).disabledColor,
              ));
    }
    return Text(DateFormat('EE, d. MMM.').format(date),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).secondaryHeaderColor,
            ));
  }

  Text lastDate(DateTime date) {
    return Text(DateFormat('EE, d. MMM.').format(date),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).shadowColor,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 48, left: 15, right: 15),
        children: [
          DateItem(
              title: Text(
                AppLocalizations.of(context)!.today,
                style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
              radios: const []),
          DateItem(
              title: date(DateTime(now.year, now.month, now.day + 1)),
              radios: [
                widget.title,
                "Erinnerungen - Gestern, 22:00, Wöchentlich am Sonntag, Montag"
              ]),
          DateItem(
              title: date(DateTime(now.year, now.month, now.day + 2)),
              radios: const ["Coop...", "bla"]),
          DateItem(
              title: lastDate(DateTime(now.year, now.month, now.day + 3)),
              radios: const [],
              divider: false),
        ],
      ),
    );
  }
}
