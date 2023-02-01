import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:postiliste/home/preference_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/home/thank_you.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'date_helper.dart';
import 'date_item.dart';
import 'new_item_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title, this.link, required this.notifyParent});
  final String title;
  final String? link;
  final Function notifyParent;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _thanks = false;
  Map _lists = <DateTime, Map<String, String>>{};
  bool _isEmpty = false;
  DateTime _lastDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  refresh() {
    _getLists();
  }

  Future<void> _getLists() async {
    final now = DateTime.now();

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _isEmpty = await listsAreEmpty();

    SplayTreeMap<DateTime, Map<String, String>> tmpLists = await getLists();

    debugPrint(tmpLists.toString());

    //always show a day after the latest key
    if (tmpLists.keys.isNotEmpty &&
        tmpLists.keys.last.millisecondsSinceEpoch >=
            tomorrow.millisecondsSinceEpoch) {
      _lastDay = tmpLists.keys.last;
      _lastDay = DateTime(_lastDay.year, _lastDay.month, _lastDay.day + 1);
    }

    if (_lists.toString() != tmpLists.toString()) {
      setState(() {
        _lists = tmpLists;
      });
    }
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

  String adjustDate(String title) {
    List<String> titleList = title.split(",");
    String dateString = titleList.removeLast();
    DateTime date = DateTime.parse(dateString);

    DateTime dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
        DateTime.now().millisecond);

    titleList.add(dateTime.toString());
    return titleList.join(",");
  }

  Future<void> _showDialog() async {
    if (widget.link != null) {
      List<dynamic> data = jsonDecode(widget.link!);
      final prefKey = adjustDate(data.removeAt(0));
      List tmp = prefKey.split(",");
      tmp.removeLast();
      String title = tmp.join(",");

      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).indicatorColor,
            title: Text(AppLocalizations.of(context)!.addList + title,
                style: Theme.of(context).textTheme.headline5?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.confirmAddList(title),
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Theme.of(context).disabledColor,
                          fontSize: 18)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.add,
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18)),
                onPressed: () {
                  newList(title, prefKey);
                  newMultipleItems(data, prefKey, context);
                  widget.notifyParent();
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          );
        },
      );
    }
  }

  void loadThankYou() async {
    final prefs = await SharedPreferences.getInstance();
    bool? shownThanks = prefs.getBool("merci");
    if (shownThanks != true) {
      prefs.setBool("merci", true);
      setState(() {
        _thanks = true;
      });
    } else {
      _thanks = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    loadThankYou();
    _getLists();
    Future.delayed(const Duration(seconds: 0), () {
      _showDialog();
    });
    (widget.link == null && _thanks)
        ? Future.delayed(const Duration(seconds: 0), () {
            thankYou(context);
          })
        : Container();
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
                first: _lists.keys.elementAt(0) == key,
                title: date(key, context),
                radios: _lists[key],
                notifyParent: refresh,
                isEmpty: _isEmpty,
              )),
          DateItem(
            dateTime: _lastDay,
            title: lastDate(_lastDay, context),
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
