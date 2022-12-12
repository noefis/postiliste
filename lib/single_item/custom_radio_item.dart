import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleItemRadio extends StatefulWidget {
  final String? title;
  final String prefKey;
  final bool active;
  final Function() notifyParent;

  const SingleItemRadio(
      {super.key,
      required this.title,
      required this.prefKey,
      required this.active,
      required this.notifyParent});

  @override
  State<SingleItemRadio> createState() => _SingleItemRadio();
}

class _SingleItemRadio<T> extends State<SingleItemRadio> {
  String _key = "";
  String _title = "";

  void _tapAction() async {
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      List<String> activeList = prefs.getStringList(widget.prefKey) ?? [];
      if (activeList.remove(widget.title)) {
        if (widget.active) {
          activeList.add(widget.title!.replaceAll('_deactivated', ''));
        } else {
          activeList.add("_deactivated${widget.title!}");
        }

        prefs.setStringList(widget.prefKey, activeList);
        widget.notifyParent();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _key = widget.active
        ? widget.title!.replaceAll('_deactivated', '')
        : widget.title!.replaceAll('_deactivated', '');
    List<String> tmp = _key.split(',');
    tmp.removeLast();
    _title = tmp.join(",");

    return Opacity(
        opacity: widget.active ? 0.6 : 1.0,
        child: InkWell(
          onTap: () => _tapAction(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                _customRadioButton,
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(bottom: 13, top: 7),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).hoverColor))),
                  child: Text(_title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.active
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).unselectedWidgetColor)),
                ))
              ],
            ),
          ),
        ));
  }

  Widget get _customRadioButton {
    return Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: const BoxConstraints(
            maxWidth: 25, maxHeight: 25, minHeight: 25, minWidth: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: widget.active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).backgroundColor,
              width: 1.5,
            )),
        child: Container(
          padding: EdgeInsets.all(widget.active ? 8 : 9.5),
          decoration: BoxDecoration(
            color: widget.active ? Theme.of(context).colorScheme.primary : null,
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: widget.active
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).shadowColor,
              width: widget.active ? 3 : 1.5,
            ),
          ),
        ));
  }
}
