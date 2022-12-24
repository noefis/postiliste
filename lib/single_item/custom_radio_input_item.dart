import 'package:flutter/material.dart';
import 'package:postiliste/visual_elements/audo_complete.dart';
import 'package:postiliste/visual_elements/input_radio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleItemRadioInput extends StatefulWidget {
  final String prefKey;
  final Function() notifyParent;

  const SingleItemRadioInput(
      {super.key, required this.prefKey, required this.notifyParent});

  @override
  State<SingleItemRadioInput> createState() => _SingleItemRadioInput();
}

class _SingleItemRadioInput<T> extends State<SingleItemRadioInput> {
  List<String> _kOptions = <String>[];

  void _getAutoComplete() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteItem") ?? [];

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
      textEditingController.clear();
      FocusScope.of(context).unfocus();
    });
    if (value.isNotEmpty) {
      widget.notifyParent();
    }
  }

  void _putActive(prefs, value) {
    List<String> activeLists = prefs.getStringList(widget.prefKey) ?? [];
    String key = '$value,${DateTime.now()}';
    activeLists.add(key);
    prefs.setStringList(widget.prefKey, activeLists);
  }

  void _putAutoCompleteList(prefs, value) {
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteItem") ?? [];
    if (!autoCompleteList.contains(value)) {
      autoCompleteList.add(value);
      prefs.setStringList("autoCompleteItem", autoCompleteList);
    }
  }

  void _removeFromAutoCompleteList(value) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteItem") ?? [];
    if (autoCompleteList.remove(value)) {
      _kOptions.remove(value);
      prefs.setStringList("autoCompleteItem", autoCompleteList);
      setState(() {});
    } else {
      debugPrint("ERROR: could not remove existing autocomplete item");
    }
  }

  @override
  Widget build(BuildContext context) {
    _getAutoComplete();
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const InputRadio(),
            const SizedBox(width: 12),
            Expanded(
                child: AutoComplete(
                    onSubmit: _newList,
                    removeFromAutoCompleteList: _removeFromAutoCompleteList,
                    options: _kOptions))
          ],
        ),
      ),
    );
  }
}
