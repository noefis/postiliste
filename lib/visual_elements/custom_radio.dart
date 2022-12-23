import 'package:flutter/material.dart';

class CustomRadio extends StatelessWidget {
  final Function tapAction;
  final bool active;
  final double bottom;

  const CustomRadio(
      {super.key,
      required this.tapAction,
      required this.active,
      required this.bottom});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => tapAction(),
        child: Container(
            margin: EdgeInsets.only(bottom: bottom),
            constraints: const BoxConstraints(
                maxWidth: 25, maxHeight: 25, minHeight: 25, minWidth: 25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(400),
                border: Border.all(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).backgroundColor,
                  width: 1.5,
                )),
            child: Container(
              padding: EdgeInsets.all(active ? 8 : 9.5),
              decoration: BoxDecoration(
                color: active ? Theme.of(context).colorScheme.primary : null,
                borderRadius: BorderRadius.circular(400),
                border: Border.all(
                  color: active
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).shadowColor,
                  width: active ? 3 : 1.5,
                ),
              ),
            )));
  }
}
