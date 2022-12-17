import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// ...
class MyBarcodeScanner {
  bool _barcodeScanInProgress = false;

  Future<String?> scanBarcode() async {
    if (_barcodeScanInProgress) {
      return null;
    }
    _barcodeScanInProgress = true;
    try {
      debugPrint("Starting barcode scan...");
      var result = await BarcodeScanner.scan();
      debugPrint(result.type.name);
      if (result.type.name == "Barcode" && isBarcode(result.rawContent)) {
        String barcode = result.rawContent;
        debugPrint("Scanned barcode: $barcode");
        return _getFoodRepoTitle(barcode);
      } else {
        debugPrint("NOT A VALID BARCODE:");
        debugPrint(result.rawContent);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        debugPrint("User denied access to camera");
      } else {
        debugPrint("Error while scanning barcode: $e");
      }
    } finally {
      _barcodeScanInProgress = false;
    }
    return null;
  }

  Future<String> _getFoodRepoTitle(String query) async {
    var apiKey = '12cf99fc88c83f24eda4367d4a90dbbd';
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Token token=$apiKey'
    };
    var url =
        'https://www.foodrepo.org/api/v3/products?excludes=nutrients&barcodes=$query';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final searchResults = json.decode(response.body);
      debugPrint(_getDisplayNameTranslation(searchResults));
      _barcodeScanInProgress = false;
      return _getDisplayNameTranslation(searchResults);
    } else {
      _barcodeScanInProgress = false;
      throw Exception('Failed to search for query: $query');
    }
  }

  String _getDisplayNameTranslation(responseData) {
    final languageCode = Platform.localeName.split('_')[0];

    final displayNameTranslations =
        responseData['data'][0]['display_name_translations'] ?? "Unknown";
    debugPrint(displayNameTranslations.toString());
    final displayName = displayNameTranslations[languageCode] ??
        displayNameTranslations.keys.toList()[0];

    return displayName;
  }
}

bool isBarcode(String str) {
  final regex = RegExp(r'^\d{13}$');
  return regex.hasMatch(str);
}
