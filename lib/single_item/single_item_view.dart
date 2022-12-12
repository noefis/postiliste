import 'package:flutter/material.dart';
import 'package:postiliste/single_item/change_item_view.dart';
import 'package:postiliste/single_item/custom_radio_input_item.dart';
import 'package:postiliste/single_item/custom_radio_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleItemViewRoute extends StatefulWidget {
  String title;
  String prefKey;
  final Function() notifyParent;

  SingleItemViewRoute(
      {super.key,
      required this.title,
      required this.prefKey,
      required this.notifyParent});

  @override
  State<SingleItemViewRoute> createState() => _SingleItemView();
}

class _SingleItemView extends State<SingleItemViewRoute> {
  List<String> _list = [];

  bool _allDone = false;

  void _getList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeList = prefs.getStringList(widget.prefKey) ?? [];

    if (activeList.toString() != _list.toString()) {
      setState(() {
        _list = activeList;
      });
    }
  }

  refresh() {
    setState(() {});
  }

  updateInfo(String value, DateTime dateTime) {
    String key = '$value,$dateTime';
    setState(() {
      widget.prefKey = key;
      widget.title = value;
    });
    widget.notifyParent();
  }

  _setAllDone() {
    _allDone =
        (_list.where((title) => !title.contains("_deactivated")).isEmpty &&
            _list.isNotEmpty);
  }

  _remove() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeLists = prefs.getStringList("active") ?? [];
    if (activeLists.remove(widget.prefKey)) {
      prefs.setStringList("active", activeLists);
      prefs.remove(widget.prefKey);
      widget.notifyParent();
      Navigator.pop(context);
    } else {
      debugPrint("ERROR: Unable to remove existing list");
    }
  }

  _newItemPush() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChangeItemViewRoute(
            notifyParent: updateInfo,
            input: widget.title,
            dateTime: DateTime.parse(widget.prefKey.split(',').last)),
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
    _setAllDone();
    _getList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Show list info',
            onPressed: () => _newItemPush(),
          )
        ],
      ),
      body: singleItemView(context),
    );
  }

  Widget singleItemView(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 15),
        children: [
          Hero(
              tag: widget.prefKey,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).hoverColor))),
                  child: Text(widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Theme.of(context).disabledColor)))),
          ..._list.where((title) => !title.contains("_deactivated")).map(
                (title) => SingleItemRadio(
                  title: title,
                  prefKey: widget.prefKey,
                  active: title.contains("_deactivated"),
                  notifyParent: refresh,
                ),
              ),
          SingleItemRadioInput(prefKey: widget.prefKey, notifyParent: refresh),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Theme.of(context).hoverColor))),
              child: Text(AppLocalizations.of(context)!.done,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: 16, color: Theme.of(context).disabledColor))),
          ..._list
              .where((title) => title.contains("_deactivated"))
              .map((title) => SingleItemRadio(
                    title: title,
                    prefKey: widget.prefKey,
                    active: title.contains("_deactivated"),
                    notifyParent: refresh,
                  )),
          _allDone
              ? OutlinedButton(
                  onPressed: () => _remove(),
                  child: Text(
                      "${AppLocalizations.of(context)!.deleteList}: ${widget.title}"))
              : Container(),
          const Padding(padding: EdgeInsets.all(90)),
        ]);
  }
}
