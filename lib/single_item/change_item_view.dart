import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    if (_input.toString() != widget.input.toString() ||
        _dateTime.toString() != widget.dateTime.toString()) {
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
            child: inputItem(),
          ),
          datePicker(),
          const Padding(padding: EdgeInsets.all(90)),
        ]);
  }

  Widget inputItem() {
    return LayoutBuilder(
        builder: (context, constraints) => Autocomplete<String>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  scrollPadding: const EdgeInsets.only(bottom: 320),
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).shadowColor)),
                      hintText: widget.input,
                      hintStyle:
                          TextStyle(color: Theme.of(context).shadowColor)),
                  onChanged: (value) => _input = value,
                  onSubmitted: (value) => _input = value,
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
                                        _removeFromAutoCompleteList(option),
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
                return _kOptions.where((String option) {
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

  Widget datePicker() {
    return Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.width / 3,
        child: Center(
            child: TextField(
          controller: dateInput,
          decoration: InputDecoration(
              icon: const Icon(Icons.calendar_today),
              hintText: DateFormat('yyyy-MM-dd').format(_dateTime),
              hintStyle: TextStyle(color: Theme.of(context).shadowColor),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).shadowColor))),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _dateTime,
                firstDate: DateTime(1950),
                lastDate: DateTime(2100));

            if (pickedDate != null) {
              setState(() {
                _dateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    DateTime.now().hour,
                    DateTime.now().minute,
                    DateTime.now().second,
                    DateTime.now().millisecond);
                dateInput.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          },
        )));
  }
}
