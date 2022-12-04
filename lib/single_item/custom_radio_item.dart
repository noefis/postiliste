import 'package:flutter/material.dart';

class SingleItemRadio extends StatefulWidget {
  final String? title;

  const SingleItemRadio({super.key, required this.title});

  @override
  State<SingleItemRadio> createState() => _SingleItemRadio();
}

class _SingleItemRadio<T> extends State<SingleItemRadio> {
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
                      bottom: BorderSide(color: Theme.of(context).hoverColor))),
              child: Text(widget.title!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _value
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).unselectedWidgetColor)),
            ))
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    return Container(
        constraints: const BoxConstraints(
            maxWidth: 25, maxHeight: 25, minHeight: 25, minWidth: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: _value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColor,
              width: 1.5,
            )),
        child: Container(
          padding: EdgeInsets.all(_value ? 8 : 9.5),
          decoration: BoxDecoration(
            color: _value ? Theme.of(context).colorScheme.primary : null,
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: _value
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).shadowColor,
              width: _value ? 3 : 1.5,
            ),
          ),
        ));
  }
}
