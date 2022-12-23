import 'dart:collection';

import 'package:flutter/material.dart';

import 'date_helper.dart';
import 'date_item.dart';
import 'new_item_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
