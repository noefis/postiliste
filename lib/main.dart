import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:postiliste/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/date_item.dart';
import 'package:postiliste/new_item_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.systemLocale = await findSystemLocale();
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
  Map _lists = <DateTime, Map<String, String>>{};
  final _now = DateTime.now();
  bool _isEmpty = false;
  DateTime lastDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  refresh() {
    _getLists();
  }

  Future<void> _getLists() async {
    final prefs = await SharedPreferences.getInstance();
    var tmpLists = SplayTreeMap<DateTime, Map<String, String>>();

    List<String>? activeLists = prefs.getStringList("active");
    _isEmpty = (activeLists == null || activeLists.isEmpty);

    activeLists?.forEach((active) {
      List actives = active.split(',');
      DateTime date = onlyDate(actives.last);
      actives.removeLast();
      if (tmpLists.containsKey(date)) {
        Map<String, String> values = tmpLists[date]!;
        values[active] = actives.join(",");
      } else {
        Map<String, String> values = {};
        values[active] = actives.join(",");
        tmpLists[date] = values;
      }
    });

    //always show Today
    if (!tmpLists.containsKey(DateTime(_now.year, _now.month, _now.day))) {
      Map<String, String> emptyValues = {};
      tmpLists[DateTime(_now.year, _now.month, _now.day)] = emptyValues;
    }

    //always show Tomorrow
    if (!tmpLists.containsKey(DateTime(_now.year, _now.month, _now.day + 1))) {
      Map<String, String> emptyValues = {};
      tmpLists[DateTime(_now.year, _now.month, _now.day + 1)] = emptyValues;
    }

    //always show a day after the latest key
    if (tmpLists.keys.isNotEmpty &&
        tmpLists.keys.last.millisecondsSinceEpoch >=
            lastDay.millisecondsSinceEpoch) {
      lastDay = tmpLists.keys.last;
      lastDay = DateTime(lastDay.year, lastDay.month, lastDay.day + 1);
    }

    if (_lists.toString() != tmpLists.toString()) {
      setState(() {
        _lists = tmpLists;
      });
    }
  }

  DateTime onlyDate(String date) {
    final yesterday = DateTime(_now.year, _now.month, _now.day - 1);

    if (DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(date)))
            .millisecondsSinceEpoch <
        yesterday.millisecondsSinceEpoch) {
      return yesterday;
    }
    return DateTime.parse(
        DateFormat("yyyy-MM-dd").format(DateTime.parse(date)));
  }

  Text date(DateTime date) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final tomorrow = DateTime(_now.year, _now.month, _now.day + 1);
    final yesterday = DateTime(_now.year, _now.month, _now.day - 1);
    if (date == yesterday) {
      return Text(
        AppLocalizations.of(context)!.overdue,
        style: Theme.of(context).textTheme.headline4?.copyWith(
            fontSize: 30,
            color: Theme.of(context).errorColor,
            fontWeight: FontWeight.w500),
      );
    } else if (date == today) {
      return Text(
        AppLocalizations.of(context)!.today,
        style: Theme.of(context).textTheme.headline4?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500),
      );
    } else if (date == tomorrow) {
      return Text(AppLocalizations.of(context)!.tomorrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).disabledColor,
              ));
    }
    return Text(_dateToString(date),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).secondaryHeaderColor,
            ));
  }

  Text lastDate(DateTime date) {
    final tomorrow = DateTime(_now.year, _now.month, _now.day + 1);
    debugPrint(date.toString() + tomorrow.toString());

    if (date == tomorrow) {
      return Text(AppLocalizations.of(context)!.tomorrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).shadowColor,
              ));
    }
    return Text(_dateToString(date),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).shadowColor,
            ));
  }

  _dateToString(date) {
    return DateFormat('EE, d. MMM.')
        .format(date)
        .replaceAll('.,', ',')
        .replaceAll('..', '.');
  }

  _newItemPush() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewItemViewRoute(notifyParent: refresh),
        transitionDuration: const Duration(milliseconds: 210),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getLists();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _newItemPush(),
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 48, left: 15, right: 15),
        children: [
          ..._lists.keys.map((key) => DateItem(
                dateTime: key,
                title: date(key),
                radios: _lists[key],
                notifyParent: refresh,
                isEmpty: _isEmpty,
              )),
          DateItem(
            dateTime: lastDay,
            title: lastDate(lastDay),
            radios: const {},
            divider: false,
            notifyParent: refresh,
          ),
          const Padding(padding: EdgeInsets.all(60)),
        ],
      ),
    );
  }
}
