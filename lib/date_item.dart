import 'package:flutter/material.dart';

import 'custom_radio.dart';
import 'custom_radio_input.dart';

class DateItem extends StatefulWidget {
  final Text title;
  final Map<String, String> radios;
  final bool divider;
  final Function() notifyParent;

  const DateItem(
      {super.key,
      required this.title,
      required this.radios,
      this.divider = true,
      required this.notifyParent});

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
                title: widget.radios[key],
                prefKey: key,
                notifyParent: refresh,
              ),
            MyRadioListTileInput(notifyParent: refresh),
            Divider(
                color: widget.divider
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).primaryColor),
          ],
        )
      ],
    );
  }
}
