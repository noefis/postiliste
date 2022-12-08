import 'package:flutter/material.dart';
import 'package:postiliste/single_item/custom_radio_input_item.dart';
import 'package:postiliste/single_item/custom_radio_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleItemViewRoute extends StatefulWidget {
  final String title;
  final String prefKey;

  const SingleItemViewRoute(
      {super.key, required this.title, required this.prefKey});

  @override
  State<SingleItemViewRoute> createState() => _SingleItemView();
}

class _SingleItemView extends State<SingleItemViewRoute> {
  List<String> _list = [];

  void _getList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeList =
        prefs.getStringList(widget.prefKey + widget.title) ?? [];

    if (activeList.toString() != _list.toString()) {
      setState(() {
        _list = activeList;
      });
    }
    debugPrint(activeList.toString());
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _getList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          ..._list.map(
            (title) => SingleItemRadio(
              title: title,
              prefKey: widget.prefKey + widget.title,
              active: false,
              notifyParent: refresh,
            ),
          ),
          SingleItemRadioInput(
              prefKey: widget.prefKey + widget.title, notifyParent: refresh),
          const Padding(padding: EdgeInsets.all(90)),
        ]);
  }
}
