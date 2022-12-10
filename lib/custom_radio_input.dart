import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ignore: must_be_immutable
class MyRadioListTileInput extends StatefulWidget {
  final Function() notifyParent;
  bool isFocused;

  MyRadioListTileInput(
      {super.key, required this.notifyParent, this.isFocused = false});

  @override
  State<MyRadioListTileInput> createState() => _MyRadioListTileInput();
}

class _MyRadioListTileInput<T> extends State<MyRadioListTileInput> {
  late TextEditingController textEditingController;
  bool _visible = true;
  bool _wasFocused = false;

  List<String> _kOptions = <String>[];

  void _getAutoComplete() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteList") ?? [];

    if (_kOptions.toString() != autoCompleteList.toString()) {
      setState(() {
        _kOptions = autoCompleteList;
      });
    }
  }

  Future<void> _newList(
      String value, TextEditingController textEditingController) async {
    if (value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _putActive(prefs, value);
      _putAutoCompleteList(prefs, value);
    }
    setState(() {
      _wasFocused = false;
      textEditingController.clear();
      FocusScope.of(context).unfocus();
    });
    if (value.isNotEmpty) {
      widget.notifyParent();
    }
  }

  void _putActive(prefs, value) {
    List<String> activeLists = prefs.getStringList("active") ?? [];
    String key = '$value,${DateTime.now()}';
    activeLists.add(key);
    prefs.setStringList("active", activeLists);
  }

  void _putAutoCompleteList(prefs, value) {
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteList") ?? [];
    if (!autoCompleteList.contains(value)) {
      autoCompleteList.add(value);
      prefs.setStringList("autoCompleteList", autoCompleteList);
    }
  }

  void _removeFromAutoCompleteList(value) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteList") ?? [];
    if (autoCompleteList.remove(value)) {
      _kOptions.remove(value);
      prefs.setStringList("autoCompleteList", autoCompleteList);
      setState(() {});
    } else {
      debugPrint("ERROR: could not remove existing autocomplete item");
    }
  }

  @override
  Widget build(BuildContext context) {
    _wasFocused = widget.isFocused == true ? true : _wasFocused;
    debugPrint(_wasFocused.toString());
    _getAutoComplete();
    return InkWell(
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _visible ? 1.0 : 0.1,
          onEnd: () => {
                setState(() => {
                      _visible ? null : widget.isFocused = false,
                      _visible = true
                    })
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
                border: Border.all(
                    color: widget.isFocused
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).primaryColor,
                    width: widget.isFocused ? 1 : 0),
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            child: Row(
              children: [
                widget.isFocused
                    ? const Padding(padding: EdgeInsets.all(1))
                    : _customRadioButton,
                const SizedBox(width: 12),
                Expanded(
                    child: LayoutBuilder(
                        builder: (context, constraints) => Autocomplete<String>(
                              fieldViewBuilder: (context,
                                  fieldTextEditingController,
                                  focusNode,
                                  onFieldSubmitted) {
                                textEditingController =
                                    fieldTextEditingController;
                                return TextField(
                                  scrollPadding:
                                      const EdgeInsets.only(bottom: 320),
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: widget.isFocused
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context).shadowColor),
                                      hintText: widget.isFocused
                                          ? "Create a new List"
                                          : _wasFocused
                                              ? "Name of the new List"
                                              : "",
                                      border: InputBorder.none),
                                  onSubmitted: ((value) =>
                                      _newList(value, textEditingController)),
                                  onTap: () => {
                                    setState(() {
                                      widget.isFocused
                                          ? _visible = false
                                          : null;
                                    })
                                  },
                                  onChanged: (value) => {
                                    if (widget.isFocused)
                                      {
                                        setState(() {
                                          _visible = false;
                                        })
                                      }
                                  },
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) => Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(4.0)),
                                          ),
                                          child: SizedBox(
                                            height: 60.0 * options.length,
                                            width: constraints.biggest.width,
                                            child: ListView.separated(
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: options.length,
                                              shrinkWrap: false,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final String option =
                                                    options.elementAt(index);
                                                return InkWell(
                                                  onTap: () =>
                                                      onSelected(option),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                    child: Row(children: [
                                                      Expanded(
                                                          child: Text(option)),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .remove_circle_outline,
                                                          color: Colors.pink,
                                                          size: 24.0,
                                                          semanticLabel:
                                                              'Remove',
                                                        ),
                                                        onPressed: () =>
                                                            _removeFromAutoCompleteList(
                                                                option),
                                                      ),
                                                    ]),
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return Divider(
                                                    color: Theme.of(context)
                                                        .hoverColor);
                                              },
                                            ),
                                          ))),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return _kOptions.where((String option) {
                                  return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                            )))
              ],
            ),
          )),
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
