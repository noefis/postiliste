import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postiliste/visual_elements/auto_complete.dart';
import 'package:postiliste/visual_elements/date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeItemViewRoute extends StatefulWidget {
  final Function(String, DateTime) notifyParent;
  final String input;
  final DateTime dateTime;

  const ChangeItemViewRoute(
      {super.key,
      required this.notifyParent,
      required this.input,
      required this.dateTime});

  @override
  State<ChangeItemViewRoute> createState() => _ChangeItemView();
}

class _ChangeItemView extends State<ChangeItemViewRoute> {
  var _input = null;
  var _dateTime = null;
  TextEditingController dateInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _input ??= widget.input;
    _dateTime ??= widget.dateTime;
    _getAutoComplete();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: changeItemView(context),
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

  Future<void> _changeList() async {
    if ((_input.toString() != widget.input.toString() ||
            _dateTime.toString() != widget.dateTime.toString()) &&
        _input.replaceAll(" ", "").isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _changeActive(prefs, _input, _dateTime);
      _putAutoCompleteList(prefs, _input);
      _changeListContent(prefs, _input, _dateTime);

      await widget.notifyParent(_input, _dateTime);
      Navigator.pop(context);
    }
  }

  void _changeActive(prefs, value, date) {
    List<String> activeLists = prefs.getStringList("active") ?? [];
    String oldKey = '${widget.input},${widget.dateTime}';
    String key = '$value,$date';
    activeLists.remove(oldKey);
    activeLists.add(key);
    prefs.setStringList("active", activeLists);
  }

  void _changeListContent(prefs, value, date) {
    String oldKey = '${widget.input},${widget.dateTime}';
    String key = '$value,$date';
    List<String> activeLists = prefs.getStringList(oldKey) ?? [];
    prefs.setStringList(key, activeLists);
    prefs.remove(oldKey);
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

  Widget changeItemView(BuildContext context) {
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
                    AppLocalizations.of(context)!.changeList,
                    style: const TextStyle(fontSize: 18),
                  )),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                      onPressed: () => _changeList(),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(fontSize: 18),
                      ))),
            ],
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Container(
            padding: const EdgeInsets.all(10),
            child: AutoComplete(
              removeFromAutoCompleteList: _removeFromAutoCompleteList,
              options: _kOptions,
              onSubmit: (value) => _input = value,
              onChange: (value) => _input = value,
              inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).shadowColor)),
                  hintText: widget.input,
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
