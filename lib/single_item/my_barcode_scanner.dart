import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MyBarcodeScanner {
  bool _barcodeScanInProgress = false;

  Future<String?> scanBarcode() async {
    if (_barcodeScanInProgress) {
      return "ERROR: Barcode Scanner is already running";
    }
    _barcodeScanInProgress = true;
    try {
      debugPrint("Starting barcode scan...");
      var result = await BarcodeScanner.scan();
      debugPrint(result.type.name);
      if (result.type.name == "Barcode" && isBarcode(result.rawContent)) {
        String barcode = result.rawContent;
        debugPrint("Scanned barcode: $barcode");
        final String productName = await _getFoodRepoTitle(barcode);
        debugPrint(productName);
        return productName;
      } else if (result.type.name == "Cancelled") {
        return null;
      } else {
        debugPrint("NOT A VALID BARCODE:");
        debugPrint(result.rawContent);
        return "ERROR: Couldn't scan barcode correctly";
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        debugPrint("User denied access to camera");
        return "ERROR: Not able to access camera";
      } else {
        debugPrint("Error while scanning barcode: $e");
      }
    } finally {
      _barcodeScanInProgress = false;
    }
    return "ERROR: unexpected error occured";
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
      _barcodeScanInProgress = false;
      return _getDisplayNameTranslation(searchResults);
    } else {
      _barcodeScanInProgress = false;
      return "ERROR: No product was found for the barcode";
    }
  }

  String _getDisplayNameTranslation(responseData) {
    final languageCode = Platform.localeName.split('_')[0];

    final displayNameTranslations =
        responseData['data'][0]['display_name_translations'];
    final displayName = displayNameTranslations[languageCode] ??
        displayNameTranslations.keys.toList()[0] ??
        "ERROR: Product name not in database";

    return displayName;
  }
}

bool isBarcode(String str) {
  final regex = RegExp(r'^\d{13}$');
  return regex.hasMatch(str);
}
