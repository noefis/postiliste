import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:postiliste/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/thankyou/single_item_thank_you_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'dark_theme_provider.dart';
import 'home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.systemLocale = await findSystemLocale();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  Widget shownWidget = Container();
  bool firstLoad = true;

  bool _initialUniLinksHandled = false;
  String? _link;
  bool _firstTime = true;

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    //handle deep links
    _initUniLinks();
    _incomingLinkHandler();

    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  Future<void> _initUniLinks() async {
    if (!_initialUniLinksHandled) {
      _initialUniLinksHandled = true;
      try {
        String? initialLink = await getInitialLink();
        if (initialLink != null && mounted) {
          String? data = _getData(initialLink);
          setState(() {
            _link = data;
          });
          debugPrint("Initial URI: $data");
        } else {
          debugPrint("Null initial URI received");
          setState(() {
            _link = null;
          });
        }
      } on PlatformException {
        debugPrint('platfrom exception unilink');
        setState(() {
          _link = null;
        });
      }
    } else {
      setState(() {
        _link = null;
      });
    }
  }

  String _decode(String base64Json) {
    final decodeBase64Json = base64.decode(base64Json);
    final decodegZipJson = gzip.decode(decodeBase64Json);
    return utf8.decode(decodegZipJson);
  }

  String? _getData(String link) {
    List<String> splitLink = link.split("?");
    String data = splitLink.last.replaceFirst("data=", "");

    final pattern =
        RegExp(r'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$');

    if (pattern.hasMatch(data)) {
      return _decode(data);
    }
    return null;
  }

  void _incomingLinkHandler() {
    if (!kIsWeb) {
      _streamSubscription = linkStream.listen((String? link) {
        if (!mounted || link == null) {
          return;
        }
        String? data = _getData(link);
        debugPrint("received Link: $data");

        resetNotYetShownLink();

        setState(() {
          _firstTime = false;

          _link = data;
        });
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        debugPrint("error occured: $err");
        setState(() {
          _link = null;
        });
      });
    }
  }

  void _removeLink() {
    setState(() {
      _link = null;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _loadFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool("firstTime") ?? true;
    if (shownWidget.runtimeType == Container) {
      if (firstTime) {
        setState(() {
          shownWidget = const SingleItemThankYouViewRoute();
        });
      } else {
        setState(() {
          _firstTime = false;
        });
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!_firstTime) {
      shownWidget = MyHomePage(
          title: 'Posti-Liste', link: _link, notifyParent: _removeLink);
    }
    _loadFirstTime();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Posti-Liste',
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
          Locale('fr', ''), // French, no country code
          Locale('es', ''), // Spanish, no country code
          Locale('it', ''), // Italian, no country code
          Locale('pt', ''), // Portuguese, no country code
          Locale('pl', ''), // Polish, no country code
          Locale('rm', ''), // Romansh (Switzerland), no country code
        ],
        home: shownWidget);
  }
}
