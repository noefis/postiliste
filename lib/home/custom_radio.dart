import 'dart:async';

import 'package:flutter/material.dart';
import 'package:postiliste/single_item/single_item_view.dart';
import 'package:postiliste/visual_elements/custom_radio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRadioListTile extends StatefulWidget {
  final String? title;
  final String prefKey;
  final Function() notifyParent;

  const MyRadioListTile(
      {super.key,
      required this.title,
      required this.prefKey,
      required this.notifyParent});

  @override
  State<MyRadioListTile> createState() => _MyRadioListTile();
}

class _MyRadioListTile<T> extends State<MyRadioListTile> {
  bool _value = false;
  bool _visible = true;
  String _toRemoveKey = "";

  late Timer _timer;

  void _tapAction() {
    setState(() {
      _value = !_value;
    });
    if (_value) {
      _toRemoveKey = widget.prefKey;
      _timer = _scheduleTimeout(2100);
    } else if (_timer.isActive) {
      _timer.cancel();
    }
  }

  Timer _scheduleTimeout([int milliseconds = 1000]) =>
      Timer(Duration(milliseconds: milliseconds), _handleTimeout);

  void _handleTimeout() {
    if (mounted) {
      if (_toRemoveKey == widget.prefKey) {
        setState(() {
          _visible = false;
        });
      } else {
        _removeWidget();
        setState(() {
          _visible = true;
          _value = false;
        });
      }
    }
  }

  void _removeWidget() async {
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      List<String> activeLists = prefs.getStringList("active") ?? [];
      if (activeLists.remove(_toRemoveKey)) {
        prefs.setStringList("active", activeLists);
        prefs.remove(widget.prefKey);
        widget.notifyParent();
      }
      //in case of error, return radio to initial state
      _visible = true;
      _value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        onEnd: _visible ? () => {} : () => _removeWidget(),
        child: InkWell(
          onTap: () {
            if (!_value) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => SingleItemViewRoute(
                    title: widget.title!,
                    prefKey: widget.prefKey,
                    notifyParent: widget.notifyParent,
                  ),
                  transitionDuration: const Duration(milliseconds: 320),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation, _, child) {
                    const begin = Offset(1, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutSine;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                CustomRadio(tapAction: _tapAction, active: _value, bottom: 1),
                const SizedBox(width: 12),
                Expanded(
                    child: Hero(
                        tag: widget.prefKey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Theme.of(context).hoverColor))),
                          child: Text(widget.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: _value
                                          ? Theme.of(context).disabledColor
                                          : Theme.of(context)
                                              .unselectedWidgetColor)),
                        )))
              ],
            ),
          ),
        ));
  }
}
