import 'dart:convert';

import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:postiliste/single_item/my_barcode_scanner.dart';
import 'package:postiliste/single_item/picture_view.dart';
import 'package:postiliste/visual_elements/custom_radio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleItemRadio extends StatefulWidget {
  final String? title;
  final List<String>? picturesLink;
  final String prefKey;
  final bool active;
  final Function() notifyParent;

  const SingleItemRadio(
      {super.key,
      required this.title,
      required this.prefKey,
      required this.active,
      required this.notifyParent,
      this.picturesLink});

  @override
  State<SingleItemRadio> createState() => _SingleItemRadio();
}

class _SingleItemRadio<T> extends State<SingleItemRadio> {
  String _key = "";
  String _title = "";
  String _last = "";
  bool _edit = false;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textFormFieldController;

  void _tapAction() async {
    if (mounted && !_edit) {
      final prefs = await SharedPreferences.getInstance();
      List<String> activeList = prefs.getStringList(widget.prefKey) ?? [];
      if (activeList.remove(widget.title)) {
        if (widget.active) {
          activeList.add(widget.title!.replaceAll('_deactivated', ''));
        } else {
          activeList.add("_deactivated${widget.title!}");
        }

        prefs.setStringList(widget.prefKey, activeList);
        widget.notifyParent();
      }
    }
  }

  void _changeTitle(String val) async {
    bool canEdit = mounted &&
        _edit &&
        !widget.active &&
        val.replaceAll(" ", "").isNotEmpty &&
        val != _title;

    if (canEdit) {
      final prefs = await SharedPreferences.getInstance();
      List<String> activeList = prefs.getStringList(widget.prefKey) ?? [];

      int index = activeList.indexOf(widget.title!);
      if (index >= 0) {
        activeList[index] = "$val,$_last";
        prefs.setStringList(widget.prefKey, activeList);
        _putAutoCompleteList(prefs, val);
        _changeImageReference(prefs, "$val,$_last");
        _edit = false;
        FocusScope.of(context).unfocus();
        widget.notifyParent();
      }
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        _edit = false;
      });
    }
  }

  _changeImageReference(prefs, newKey) {
    String jsonStr = prefs.getString("${widget.prefKey}_images") ?? "{}";
    Map<String, List<String>> images = _castToStringMap(jsonDecode(jsonStr));

    List<String>? productImages = images.remove(widget.title);
    if (productImages != null) {
      images[newKey] = productImages;
      String newJsonString = jsonEncode(images);
      prefs.setString("${widget.prefKey}_images", newJsonString);
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

  void _putAutoCompleteList(prefs, value) {
    List<String> autoCompleteList =
        prefs.getStringList("autoCompleteItem") ?? [];
    if (!autoCompleteList.contains(value)) {
      autoCompleteList.add(value);
      prefs.setStringList("autoCompleteItem", autoCompleteList);
    }
  }

  void _delete() async {
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      List<String> activeList = prefs.getStringList(widget.prefKey) ?? [];
      activeList.remove(widget.title);
      prefs.setStringList(widget.prefKey, activeList);
      widget.notifyParent();
    }
  }

  void _showPicture() {
    if (widget.picturesLink!.isNotEmpty) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PictureView(
            pictures: widget.picturesLink!,
          ),
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, _, child) {
            const begin = Offset(1, 0.0);
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
  }

  @override
  void dispose() {
    // Remove the focus node listener
    _focusNode.removeListener(() {
      if (!_focusNode.hasFocus) {
        _changeTitle(_textFormFieldController.text);
      }
    });

    // Dispose of the focus node
    _focusNode.dispose();

    // Dispose of the text editing controller
    _textFormFieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _key = widget.active
        ? widget.title!.replaceAll('_deactivated', '')
        : widget.title!.replaceAll('_deactivated', '');
    List<String> tmp = _key.split(',');
    _last = tmp.removeLast();
    if (isBarcode(tmp.last)) {
      tmp.removeLast();
    }
    _title = tmp.join(",");
    _textFormFieldController = TextEditingController(text: _title);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // The keyboard has been closed
        _changeTitle(_textFormFieldController.text);
      }
    });

    return Opacity(
        opacity: widget.active ? 0.6 : 1.0,
        child: InkWell(
          onTap: () => _tapAction(),
          child: Container(
            padding: const EdgeInsets.only(left: 9, right: 5),
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                CustomRadio(
                    tapAction: _tapAction, active: widget.active, bottom: 7),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: _edit ? 1.7 : 1,
                              color: _edit
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).hoverColor))),
                  child: Row(children: [
                    Expanded(
                        child: Padding(
                            padding: !_edit
                                ? const EdgeInsets.only(bottom: 13, top: 7)
                                : const EdgeInsets.all(0),
                            child: !_edit
                                ? Text(_title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: widget.active
                                                ? Theme.of(context)
                                                    .disabledColor
                                                : Theme.of(context)
                                                    .unselectedWidgetColor))
                                : TextFormField(
                                    controller: _textFormFieldController,
                                    decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 0),
                                        border: InputBorder.none),
                                    style: TextStyle(fontSize: 14),
                                    focusNode: _focusNode,
                                    onEditingComplete: () => _changeTitle(
                                        _textFormFieldController.text),
                                    onSaved: (value) =>
                                        _changeTitle(value!.toString()),
                                    onFieldSubmitted: (value) =>
                                        _changeTitle(value),
                                  ))),
                    widget.picturesLink != null
                        ? ExpandTapWidget(
                            tapPadding: const EdgeInsets.all(10),
                            onTap: () => _showPicture(),
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, bottom: 13, top: 3),
                                child: SizedBox(
                                    height: 20.0,
                                    width: 30.0,
                                    child: IconButton(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      onPressed: () => _showPicture(),
                                      icon: Icon(
                                        size: 26,
                                        Icons.photo_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ))))
                        : Container(),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    !widget.active
                        ? ExpandTapWidget(
                            tapPadding: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 10),
                            onTap: () => setState(() => _edit = !_edit),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 13, top: 7),
                                child: SizedBox(
                                    height: 20.0,
                                    width: 45.0,
                                    child: IconButton(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      onPressed: () => setState(() {
                                        _edit = !_edit;
                                        if (_edit) {
                                          FocusScope.of(context)
                                              .requestFocus(_focusNode);
                                        }
                                      }),
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ))))
                        : ExpandTapWidget(
                            tapPadding: const EdgeInsets.all(8),
                            onTap: () => _delete(),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 13, top: 7),
                                child: SizedBox(
                                    height: 20.0,
                                    width: 45.0,
                                    child: IconButton(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      onPressed: () => _delete(),
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: Theme.of(context)
                                            .unselectedWidgetColor,
                                      ),
                                    ))))
                  ]),
                )),
              ],
            ),
          ),
        ));
  }
}
