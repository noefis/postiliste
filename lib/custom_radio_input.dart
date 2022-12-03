import 'package:flutter/material.dart';

class MyRadioListTileInput extends StatefulWidget {
  const MyRadioListTileInput({super.key});

  @override
  State<MyRadioListTileInput> createState() => _MyRadioListTileInput();
}

class _MyRadioListTileInput<T> extends State<MyRadioListTileInput> {
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
        margin: const EdgeInsets.symmetric(vertical: 3),
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
    var dontQuestionIt = BoxDecoration(
      borderRadius: BorderRadius.circular(400),
      gradient: SweepGradient(
        stops: const [
          0.0,
          0.025,
          0.025,
          0.05,
          0.05,
          0.075,
          0.075,
          0.1,
          0.1,
          0.125,
          0.125,
          0.15,
          0.15,
          0.175,
          0.175,
          0.2,
          0.2,
          0.225,
          0.225,
          0.25,
          0.25,
          0.275,
          0.275,
          0.3,
          0.3,
          0.325,
          0.325,
          0.35,
          0.35,
          0.375,
          0.375,
          0.4,
          0.4,
          0.425,
          0.425,
          0.45,
          0.45,
          0.475,
          0.475,
          0.5,
          0.5,
          0.525,
          0.525,
          0.55,
          0.55,
          0.575,
          0.575,
          0.6,
          0.6,
          0.625,
          0.625,
          0.65,
          0.65,
          0.675,
          0.675,
          0.7,
          0.7,
          0.725,
          0.725,
          0.75,
          0.75,
          0.775,
          0.775,
          0.8,
          0.8,
          0.825,
          0.825,
          0.85,
          0.85,
          0.875,
          0.875,
          0.9,
          0.9,
          0.925,
          0.925,
          0.95,
          0.95,
          0.975,
          0.975,
          1
        ],
        colors: [
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
          Theme.of(context).shadowColor,
          Theme.of(context).shadowColor,
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor,
        ],
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
          decoration: dontQuestionIt,
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
