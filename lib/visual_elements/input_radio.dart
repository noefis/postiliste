import 'package:flutter/material.dart';

class InputRadio extends StatelessWidget {
  const InputRadio({super.key});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [];
    for (var i = 0; i < 20; i++) {
      colors.add(Theme.of(context).shadowColor);
      colors.add(Theme.of(context).shadowColor);
      colors.add(Theme.of(context).primaryColor);
      colors.add(Theme.of(context).primaryColor);
    }

    List<double> stops = [0.0];
    for (var i = 1; i < 40; i++) {
      stops.add(i / 40);
      stops.add(i / 40);
    }
    stops.add(1.0);

    var dottedLine = BoxDecoration(
      borderRadius: BorderRadius.circular(400),
      gradient: SweepGradient(
        stops: stops,
        colors: colors,
        tileMode: TileMode.repeated,
      ),
    );

    return Container(
        margin: const EdgeInsets.only(right: 12, left: 9),
        constraints: const BoxConstraints(
            maxWidth: 25, maxHeight: 25, minHeight: 25, minWidth: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(400),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            )),
        child: Container(
          padding: const EdgeInsets.all(1.75),
          decoration: dottedLine,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(400),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
  }
}
