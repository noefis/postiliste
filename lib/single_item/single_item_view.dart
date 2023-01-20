import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postiliste/single_item/change_item_view.dart';
import 'package:postiliste/single_item/custom_radio_input_item.dart';
import 'package:postiliste/single_item/custom_radio_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'my_barcode_scanner.dart';
import 'package:rate_my_app/rate_my_app.dart';

class SingleItemViewRoute extends StatefulWidget {
  String title;
  String prefKey;
  final Function() notifyParent;

  SingleItemViewRoute(
      {super.key,
      required this.title,
      required this.prefKey,
      required this.notifyParent});

  @override
  State<SingleItemViewRoute> createState() => _SingleItemView();
}

class _SingleItemView extends State<SingleItemViewRoute> {
  List<String> _list = [];
  Map<String, List<String>> _images = {};

  bool _allDone = false;

  void _getList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeList = prefs.getStringList(widget.prefKey) ?? [''];
    String jsonStr = prefs.getString("${widget.prefKey}_images") ?? "{}";

    Map<String, List<String>> images = _castToStringMap(jsonDecode(jsonStr));

    if (activeList.toString() != _list.toString()) {
      setState(() {
        _list = activeList;
        _images = images;
      });
    }
  }

  Map<String, List<String>> _castToStringMap(Map<String, dynamic> input) {
    Map<String, List<String>> output = {};
    input.forEach((key, value) {
      List<String> list =
          (value as List).map((item) => item as String).toList();
      output[key] = list;
    });
    return output;
  }

  refresh() {
    setState(() {});
  }

  updateInfo(String value, DateTime dateTime) {
    String key = '$value,$dateTime';
    setState(() {
      widget.prefKey = key;
      widget.title = value;
    });
    widget.notifyParent();
  }

  _setAllDone() {
    _allDone =
        (_list.where((title) => !title.contains("_deactivated")).isEmpty &&
            _list.isNotEmpty);
  }

  _remove() async {
    await initRateMyApp();
    final prefs = await SharedPreferences.getInstance();
    List<String> activeLists = prefs.getStringList("active") ?? [];
    if (activeLists.remove(widget.prefKey)) {
      prefs.setStringList("active", activeLists);
      prefs.remove(widget.prefKey);
      prefs.remove("${widget.prefKey}_images");
      widget.notifyParent();
      Navigator.pop(context);
    } else {
      debugPrint("ERROR: Unable to remove existing list");
    }
  }

  _newItemPush() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChangeItemViewRoute(
            notifyParent: updateInfo,
            input: widget.title,
            dateTime: DateTime.parse(widget.prefKey.split(',').last)),
        transitionDuration: const Duration(milliseconds: 210),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _scanBarcode() async {
    String? barcode = await scanBarcode(context);
    String? error = null;

    if (barcode != null && !barcode.contains("ERROR")) {
      barcode = _checkBarcodeValidity(barcode);
    }
    if (barcode == null) {
    } else if (barcode.contains("ERROR")) {
      error = barcode;
    } else {
      final List<String> item = await getFoodRepoItem(barcode, context);
      final String productName = item.removeAt(0);
      final List<String> images = item;
      if (!productName.contains("ERROR")) {
        _newList(productName, images);
      } else {
        error = productName;
      }
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.replaceFirst("ERROR: ", ""))));
    }
  }

  String _checkBarcodeValidity(String barcode) {
    return isBarcode(barcode)
        ? barcode
        : AppLocalizations.of(context)!.notAbleToScan;
  }

  Future<void> _newList(String value, List<String> images) async {
    if (value.isNotEmpty) {
      String key = '$value,${DateTime.now()}';

      final prefs = await SharedPreferences.getInstance();
      _putActive(prefs, value, key);
      _putImage(images, key);
      _putAutoCompleteList(prefs, value);

      setState(() {});
    }
  }

  _putImage(List<String> productImages, String key) async {
    if (productImages.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      String jsonStr = prefs.getString("${widget.prefKey}_images") ?? "{}";

      Map<String, List<String>> images = _castToStringMap(jsonDecode(jsonStr));
      images[key] = productImages;

      String newJsonString = jsonEncode(images);
      prefs.setString("${widget.prefKey}_images", newJsonString);
    }
  }

  void _putActive(prefs, value, key) {
    List<String> activeLists = prefs.getStringList(widget.prefKey) ?? [];
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

  final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 5,
    appStoreIdentifier: 'ch.noel.postiliste',
    googlePlayIdentifier: 'ch.noel.postiliste',
  );

  @override
  void initState() {
    super.initState();
  }

  initRateMyApp() {
    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        _rateMyApp.showStarRateDialog(
          context,
          title: AppLocalizations.of(context)!.feedbackTitle,
          message: AppLocalizations.of(context)!.feedbackMessage,
          actionsBuilder: (context, stars) {
            return [
              OutlinedButton(
                child: Text(
                  'OK',
                  style:
                      TextStyle(color: Theme.of(context).unselectedWidgetColor),
                ),
                onPressed: () async {
                  await _rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);
                },
              ),
            ];
          },
          dialogStyle: const DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20.0),
          ),
          starRatingOptions: const StarRatingOptions(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _setAllDone();
    _getList();
    debugPrint(_list.toString());
    debugPrint(_images.toString());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 28),
            tooltip: 'Show list info',
            onPressed: () => _newItemPush(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _scanBarcode,
        child: const Icon(
          CupertinoIcons.barcode_viewfinder,
          size: 35,
        ),
      ),
      body: singleItemView(context),
    );
  }

  Widget singleItemView(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.only(top: 75, left: 20, right: 15),
        children: [
          Hero(
              tag: widget.prefKey,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).hoverColor))),
                  child: Text(widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Theme.of(context).disabledColor)))),
          ..._list.where((title) => !title.contains("_deactivated")).map(
                (title) => SingleItemRadio(
                  title: title,
                  prefKey: widget.prefKey,
                  picturesLink: _images[title]?.whereType<String>().toList(),
                  active: title.contains("_deactivated"),
                  notifyParent: refresh,
                ),
              ),
          SingleItemRadioInput(prefKey: widget.prefKey, notifyParent: refresh),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Theme.of(context).hoverColor))),
              child: Text(AppLocalizations.of(context)!.done,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: 16, color: Theme.of(context).disabledColor))),
          ..._list
              .where((title) => title.contains("_deactivated"))
              .map((title) => SingleItemRadio(
                    title: title,
                    prefKey: widget.prefKey,
                    picturesLink: _images[title.replaceAll("_deactivated", "")],
                    active: title.contains("_deactivated"),
                    notifyParent: refresh,
                  )),
          const Padding(padding: EdgeInsets.all(12)),
          _allDone
              ? OutlinedButton(
                  onPressed: () => _remove(),
                  child: Text(
                      "${AppLocalizations.of(context)!.deleteList}: ${widget.title}"))
              : Container(),
          const Padding(padding: EdgeInsets.all(78)),
        ]);
  }
}
