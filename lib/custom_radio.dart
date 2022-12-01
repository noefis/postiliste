import 'package:flutter/material.dart';

class MyRadioListTile extends StatefulWidget {
  final String? title;

  const MyRadioListTile({super.key, required this.title});

  @override
  State<MyRadioListTile> createState() => _MyRadioListTile();
}

class _MyRadioListTile<T> extends State<MyRadioListTile> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _value = !_value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _customRadioButton,
            const SizedBox(width: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(widget.title!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _value
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).unselectedWidgetColor)),
            )
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color:
                  _value ? Theme.of(context).colorScheme.primary : Colors.black,
              width: 1.5,
            )),
        child: Container(
          padding: EdgeInsets.all(_value ? 8 : 9.5),
          decoration: BoxDecoration(
            color: _value ? Theme.of(context).colorScheme.primary : null,
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: _value ? Colors.black : Colors.grey[500]!,
              width: _value ? 3 : 1.5,
            ),
          ),
        ));
  }
}
