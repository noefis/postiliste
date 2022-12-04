import 'package:flutter/material.dart';
import 'package:postiliste/single_item/single_item_view.dart';

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
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                SingleItemViewRoute(title: widget.title!),
            transitionDuration: const Duration(milliseconds: 420),
            reverseTransitionDuration: const Duration(milliseconds: 360),
            transitionsBuilder: (context, animation, _, child) {
              const begin = Offset(1, 0.0);
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            _customRadioButton,
            const SizedBox(width: 12),
            Expanded(
                child: Hero(
                    tag: widget.title!,
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
                                          .textSelectionTheme
                                          .selectionColor)),
                    )))
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    return GestureDetector(
        onTap: () {
          setState(() {
            _value = !_value;
          });
        },
        child: Container(
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
            )));
  }
}
