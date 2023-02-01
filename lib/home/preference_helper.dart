import 'dart:convert';
import 'package:postiliste/single_item/my_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> newList(String title, String prefkey) async {
  final prefs = await SharedPreferences.getInstance();
  _putActive(prefs, prefkey);
  _putAutoCompleteList(prefs, title);
}

void _putActive(prefs, prefkey) {
  List<String> activeLists = prefs.getStringList("active") ?? [];
  activeLists.add(prefkey);
  prefs.setStringList("active", activeLists);
}

void _putAutoCompleteList(prefs, value) {
  List<String> autoCompleteList = prefs.getStringList("autoCompleteList") ?? [];
  if (!autoCompleteList.contains(value)) {
    autoCompleteList.add(value);
    prefs.setStringList("autoCompleteList", autoCompleteList);
  }
}

Future<void> newMultipleItems(List<dynamic> items, prefKey, context) async {
  final prefs = await SharedPreferences.getInstance();

  for (var item in items) {
    newItem(item, prefKey, prefs, context);
  }
}

Future<void> newItem(String value, String prefKey, prefs, context) async {
  if (value.replaceAll(" ", "").isNotEmpty) {
    if (isBarcode(value)) {
      final List<String> item = await getFoodRepoItem(value, context);
      final String productName = item.removeAt(0);
      final List<String> images = item;

      if (!productName.contains("ERROR")) {
        _newList("$productName,$value", images, prefKey);
      }
    } else {
      String key = '$value,${DateTime.now()}';

      _putActiveItem(prefs, key, prefKey);
      _putAutoCompleteListItem(prefs, value);
    }
  }
}

Future<void> _newList(String value, List<String> images, prefKey) async {
  if (value.isNotEmpty) {
    String key = '$value,${DateTime.now()}';

    final prefs = await SharedPreferences.getInstance();
    _putActiveItem(prefs, key, prefKey);
    _putImage(images, key, prefKey);
    _putAutoCompleteListItem(prefs, value);
  }
}

_putImage(List<String> productImages, String key, prefKey) async {
  if (productImages.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString("${prefKey}_images") ?? "{}";

    Map<String, List<String>> images = _castToStringMap(jsonDecode(jsonStr));
    images[key] = productImages;

    String newJsonString = jsonEncode(images);
    prefs.setString("${prefKey}_images", newJsonString);
  }
}

Map<String, List<String>> _castToStringMap(Map<String, dynamic> input) {
  Map<String, List<String>> output = {};
  input.forEach((key, value) {
    List<String> list = (value as List).map((item) => item as String).toList();
    output[key] = list;
  });
  return output;
}

void _putActiveItem(prefs, String key, String prefKey) {
  List<String> activeLists = prefs.getStringList(prefKey) ?? [];
  activeLists.add(key);
  prefs.setStringList(prefKey, activeLists);
}

void _putAutoCompleteListItem(prefs, value) {
  if (isBarcode(value.split(",").last)) {
    List tmp = value.split(",");
    tmp.removeLast();
    value = tmp.join(",");
  }

  List<String> autoCompleteList = prefs.getStringList("autoCompleteItem") ?? [];
  if (!autoCompleteList.contains(value)) {
    autoCompleteList.add(value);
    prefs.setStringList("autoCompleteItem", autoCompleteList);
  }
}
