import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:postiliste/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  bool _initialUniLinksHandled = false;
  String? _link;
  Object? _err;

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

        //TODO remove
        initialLink =
            "postiliste://share-postiliste.ch?data=H4sIAAAAAAAAA4tWys7WMTIwMtY1MNQ1slQwMrIytbQyNNczMLZQ0lFKTAIS5maGxsaGRsamQGVGSrEANWsx5TMAAAA=";
        if (initialLink != null && mounted) {
          setState(() {
            _link = _getData(initialLink!);
          });
          debugPrint("Initial URI: ${_getData(initialLink)}");
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
  }

  void _incomingLinkHandler() {
    if (!kIsWeb) {
      _streamSubscription = linkStream.listen((String? link) {
        if (!mounted) {
          return;
        }
        debugPrint("received Link: ${_getData(link!)}");

        setState(() {
          _link = link;
          _err = null;
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

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: MyHomePage(title: 'Posti-Liste', link: _link),
    );
  }
}
