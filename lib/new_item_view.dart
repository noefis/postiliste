import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (_input.isNotEmpty) {
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
        padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18),
                  )),
              const Text(
                "New Item",
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                  onPressed: () => _newList(),
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 18),
                  )),
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
                      hintText: "Title",
                      hintStyle:
                          TextStyle(color: Theme.of(context).shadowColor)),
                  onChanged: ((value) => _input = value),
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
                  return option.contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                debugPrint('You just selected $selection');
              },
            ));
  }

  Widget datePicker() {
    return Container(
        padding: const EdgeInsets.all(15),
        height: MediaQuery.of(context).size.width / 3,
        child: Center(
            child: TextField(
          controller: dateInput,
          decoration: InputDecoration(
              icon: const Icon(Icons.calendar_today),
              labelText: "Enter Date",
              labelStyle: TextStyle(color: Theme.of(context).shadowColor),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).shadowColor))),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
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
