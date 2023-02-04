import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime.now();

Future<bool> listsAreEmpty() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? activeLists = prefs.getStringList("active");
  return (activeLists == null || activeLists.isEmpty);
}

Future<SplayTreeMap<DateTime, Map<String, String>>> getLists() async {
  final prefs = await SharedPreferences.getInstance();
  var tmpLists = SplayTreeMap<DateTime, Map<String, String>>();

  List<String>? activeLists = prefs.getStringList("active");
  debugPrint("ALL KEYS: ${prefs.getKeys()}");
  debugPrint("ACTIVE: ${prefs.getStringList("active").toString()}");

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

  return tmpLists;
}

DateTime onlyDate(String date) {
  final yesterday = DateTime(_now.year, _now.month, _now.day - 1);

  if (DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(date)))
          .millisecondsSinceEpoch <
      yesterday.millisecondsSinceEpoch) {
    return yesterday;
  }
  return DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(date)));
}

Text date(DateTime date, context) {
  final today = DateTime(_now.year, _now.month, _now.day);
  final tomorrow = DateTime(_now.year, _now.month, _now.day + 1);
  final yesterday = DateTime(_now.year, _now.month, _now.day - 1);
  if (date == yesterday) {
    return Text(
      AppLocalizations.of(context)!.overdue,
      style: Theme.of(context).textTheme.headline4?.copyWith(
          fontSize: 30,
          color: Theme.of(context).errorColor,
          fontWeight: FontWeight.w700),
    );
  } else if (date == today) {
    return Text(
      AppLocalizations.of(context)!.today,
      style: Theme.of(context).textTheme.headline4?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600),
    );
  } else if (date == tomorrow) {
    return Text(AppLocalizations.of(context)!.tomorrow,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).disabledColor,
            ));
  }
  return Text(_dateToString(date),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).disabledColor,
          ));
}

Text lastDate(DateTime date, context) {
  final tomorrow = DateTime(_now.year, _now.month, _now.day + 1);

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
