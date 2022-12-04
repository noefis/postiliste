import 'package:flutter/material.dart';

class SingleItemRadioInput extends StatefulWidget {
  const SingleItemRadioInput({super.key});

  @override
  State<SingleItemRadioInput> createState() => _SingleItemRadioInput();
}

class _SingleItemRadioInput<T> extends State<SingleItemRadioInput> {
  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _customRadioButton,
            const SizedBox(width: 12),
            Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) => Autocomplete<String>(
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              scrollPadding: const EdgeInsets.only(bottom: 120),
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) =>
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(4.0)),
                                      ),
                                      child: SizedBox(
                                        height: 40.0 * options.length,
                                        width: constraints.biggest.width,
                                        child: ListView.separated(
                                          padding: EdgeInsets.zero,
                                          itemCount: options.length,
                                          shrinkWrap: false,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final String option =
                                                options.elementAt(index);
                                            return InkWell(
                                              onTap: () => onSelected(option),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                child: Text(option),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Divider(
                                                color: Theme.of(context)
                                                    .hoverColor);
                                          },
                                        ),
                                      ))),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _kOptions.where((String option) {
                              return option.contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            debugPrint('You just selected $selection');
                          },
                        )))
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
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
