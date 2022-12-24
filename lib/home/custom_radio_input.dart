import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postiliste/visual_elements/input_radio.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ignore: must_be_immutable
class MyRadioListTileInput extends StatefulWidget {
  final Function() notifyParent;
  final DateTime dateTime;
  bool isFocused;

  MyRadioListTileInput(
      {super.key,
      required this.notifyParent,
      this.isFocused = false,
      required this.dateTime});

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
    if (value.replaceAll(" ", "").isNotEmpty) {
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
    DateTime date = DateTime(
        widget.dateTime.year,
        widget.dateTime.month,
        widget.dateTime.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
        DateTime.now().millisecond);
    String key = '$value,$date';
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
    _getAutoComplete();
    return InkWell(
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _visible ? 1.0 : 0.0,
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
                widget.isFocused ? Container() : const InputRadio(),
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
                                  readOnly: widget.isFocused,
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
                                          ? AppLocalizations.of(context)!
                                              .createNewList
                                          : _wasFocused
                                              ? AppLocalizations.of(context)!
                                                  .nameNewList
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
}
