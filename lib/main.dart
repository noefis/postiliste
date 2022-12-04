import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postiliste/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/date_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map lists = <DateTime, List<String>>{};
  final now = DateTime.now();
  DateTime lastDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  Future<void> getLists() async {
    final prefs = await SharedPreferences.getInstance();
    Map tmpLists = <DateTime, List<String>>{};

    List<String>? activeLists = prefs.getStringList("active");
    debugPrint(activeLists.toString());

    activeLists?.forEach((active) {
      List actives = active.split(',');
      if (tmpLists.containsKey(onlyDate(actives.last))) {
        List<String> bla = tmpLists[onlyDate(actives.last)];
        bla.add(actives.first);
      } else {
        List<String> values = [];
        values.add(actives.first);
        tmpLists[onlyDate(actives.last)] = values;
      }
    });

    if (tmpLists.keys.last.millisecondsSinceEpoch >
        lastDay.millisecondsSinceEpoch) {
      lastDay = tmpLists.keys.last;
    }
    debugPrint(tmpLists.toString());

    if (lists.toString() != tmpLists.toString()) {
      setState(() {
        lists = tmpLists;
      });
    }
  }

  DateTime onlyDate(String date) {
    return DateTime.parse(
        DateFormat("yyyy-MM-dd").format(DateTime.parse(date)));
  }

  Text date(DateTime date) {
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date == today) {
      return Text(
        AppLocalizations.of(context)!.today,
        style: Theme.of(context).textTheme.headline4?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500),
      );
    }
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
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date == tomorrow) {
      return Text(AppLocalizations.of(context)!.tomorrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).shadowColor,
              ));
    }
    return Text(DateFormat('EE, d. MMM.').format(date),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).shadowColor,
            ));
  }

  @override
  Widget build(BuildContext context) {
    getLists();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 48, left: 15, right: 15),
        children: [
          ...lists.keys
              .map((key) => DateItem(title: date(key), radios: lists[key])),
          DateItem(title: lastDate(lastDay), radios: const [], divider: false),
          const Padding(padding: EdgeInsets.all(60)),
        ],
      ),
    );
  }
}
