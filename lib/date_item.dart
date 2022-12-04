import 'package:flutter/material.dart';

import 'custom_radio.dart';
import 'custom_radio_input.dart';

class DateItem extends StatefulWidget {
  final Text title;
  final List<String> radios;

  const DateItem({super.key, required this.title, required this.radios});

  @override
  State<DateItem> createState() => _DateItem();
}

class _DateItem<T> extends State<DateItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(alignment: Alignment.topLeft, child: widget.title),
        const Padding(padding: EdgeInsets.all(6)),
        Column(
          children: [
            for (String item in widget.radios) MyRadioListTile(title: item),
            const MyRadioListTileInput(),
            Divider(color: Theme.of(context).disabledColor),
          ],
        )
      ],
    );
  }
}
