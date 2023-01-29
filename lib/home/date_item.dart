import 'package:flutter/material.dart';

import 'custom_radio.dart';
import 'custom_radio_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateItem extends StatefulWidget {
  final Text title;
  final Map<String, String> radios;
  final bool divider;
  final bool first;
  final Function() notifyParent;
  final bool isEmpty;
  final DateTime dateTime;

  const DateItem(
      {super.key,
      required this.title,
      required this.radios,
      this.divider = true,
      required this.notifyParent,
      this.isEmpty = false,
      required this.dateTime,
      this.first = false});

  @override
  State<DateItem> createState() => _DateItem();
}

class _DateItem<T> extends State<DateItem> {
  refresh() {
    widget.notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(alignment: Alignment.topLeft, child: widget.title),
        const Padding(padding: EdgeInsets.all(6)),
        Column(
          children: [
            for (String key in widget.radios.keys)
              MyRadioListTile(
                title: widget.radios[key]!,
                first: widget.first && widget.radios.keys.elementAt(0) == key,
                prefKey: key,
                notifyParent: refresh,
              ),
            MyRadioListTileInput(
              notifyParent: refresh,
              dateTime: widget.dateTime,
              isFocused: widget.isEmpty &&
                  widget.title.data == AppLocalizations.of(context)!.today,
            ),
            Divider(
                color: widget.divider
                    ? Theme.of(context).shadowColor
                    : Theme.of(context).primaryColor),
          ],
        )
      ],
    );
  }
}
