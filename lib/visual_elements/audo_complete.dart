import 'package:flutter/material.dart';

class AutoComplete extends StatelessWidget {
  final Function? onSubmit;
  final Function removeFromAutoCompleteList;
  final Function? onChange;
  final List<String> options;
  final InputDecoration inputDecoration;

  const AutoComplete(
      {super.key,
      this.onSubmit,
      this.onChange,
      required this.removeFromAutoCompleteList,
      required this.options,
      this.inputDecoration = const InputDecoration(border: InputBorder.none)});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => Autocomplete<String>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  scrollPadding: const EdgeInsets.only(bottom: 320),
                  focusNode: focusNode,
                  decoration: inputDecoration,
                  onSubmitted: ((value) =>
                      onSubmit?.call(value, textEditingController)),
                  onChanged: ((value) => onChange?.call(value)),
                );
              },
              optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(4.0)),
                      ),
                      child: SizedBox(
                        height: 60.0 * options.length,
                        width: constraints.biggest.width,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: false,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 5),
                                child: Row(children: [
                                  Expanded(child: Text(option)),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.pink,
                                      size: 24.0,
                                      semanticLabel: 'Remove',
                                    ),
                                    onPressed: () =>
                                        removeFromAutoCompleteList(option),
                                  ),
                                ]),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(color: Theme.of(context).hoverColor);
                          },
                        ),
                      ))),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return options.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                debugPrint('You just selected $selection');
              },
            ));
  }
}
