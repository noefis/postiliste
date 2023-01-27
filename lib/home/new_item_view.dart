import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postiliste/visual_elements/auto_complete.dart';
import 'package:postiliste/visual_elements/date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewItemViewRoute extends StatefulWidget {
  final Function() notifyParent;

  const NewItemViewRoute({super.key, required this.notifyParent});

  @override
  State<NewItemViewRoute> createState() => _NewItemView();
}

class _NewItemView extends State<NewItemViewRoute> {
  String _input = "";
  DateTime _dateTime = DateTime.now();
  TextEditingController dateInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _getAutoComplete();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: newItemView(context),
    );
  }

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

  Future<void> _newList() async {
    if (_input.replaceAll(" ", "").isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();

      _putActive(prefs, _input, _dateTime);
      _putAutoCompleteList(prefs, _input);

      await widget.notifyParent();
      Navigator.pop(context);
    }
  }

  void _putActive(prefs, value, date) {
    List<String> activeLists = prefs.getStringList("active") ?? [];
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
  void initState() {
    dateInput.text = "";
    super.initState();
  }

  Widget newItemView(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.only(top: 55, left: 15, right: 15),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(fontSize: 18),
                      ))),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.newList,
                    style: const TextStyle(fontSize: 18),
                  )),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                      onPressed: () => _newList(),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.add,
                        style: const TextStyle(fontSize: 18),
                      ))),
            ],
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Container(
            padding: const EdgeInsets.all(10),
            child: AutoComplete(
              onChange: ((value) => _input = value),
              removeFromAutoCompleteList: _removeFromAutoCompleteList,
              options: _kOptions,
              inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).shadowColor)),
                  hintText: AppLocalizations.of(context)!.title,
                  hintStyle: TextStyle(color: Theme.of(context).shadowColor)),
            ),
          ),
          DatePicker(
              dateInput: dateInput,
              dateTime: _dateTime,
              onTap: (pickedDate) => setState(() {
                    _dateTime = pickedDate;
                    dateInput.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  })),
          const Padding(padding: EdgeInsets.all(90)),
        ]);
  }
}
