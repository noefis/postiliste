import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyBarcodeScanner {
  bool _barcodeScanInProgress = false;

  Future<String?> scanBarcode(context) async {
    String? barcode = await _getBarcode(context);
    _barcodeScanInProgress = false;
    if (barcode == null || barcode.contains("ERROR")) {
      return barcode;
    } else {
      debugPrint(barcode);
      final String productName = await _getFoodRepoTitle(barcode, context);
      return productName;
    }
  }

  Future<String?> _getBarcode(context) async {
    if (_barcodeScanInProgress) {
      return AppLocalizations.of(context)!.barcodeScannerRunning;
    }
    _barcodeScanInProgress = true;
    try {
      var result = await BarcodeScanner.scan();
      if (result.type.name == "Barcode" && isBarcode(result.rawContent)) {
        return result.rawContent;
      } else if (result.type.name == "Cancelled") {
        return null;
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        return AppLocalizations.of(context)!.cameraDenied;
      }
    }
    return AppLocalizations.of(context)!.notAbleToScan;
  }

  Future<String> _getFoodRepoTitle(String query, context) async {
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
      return _getDisplayNameTranslation(searchResults, context);
    } else {
      return AppLocalizations.of(context)!.noProductFound;
    }
  }

  String _getDisplayNameTranslation(responseData, context) {
    debugPrint(responseData.toString());
    final languageCode = Platform.localeName.split('_')[0];

    final data = responseData['data'];

    if (data.isNotEmpty) {
      final displayNameTranslations = data[0]['display_name_translations'];
      final displayName = displayNameTranslations[languageCode] ??
          displayNameTranslations.keys.toList()[0] ??
          AppLocalizations.of(context)!.productNotInDB;
      if (num.tryParse(displayName) != null) {
        return AppLocalizations.of(context)!.noProductFound;
      }
      return displayName;
    }

    return AppLocalizations.of(context)!.productNotInDB;
  }
}

bool isBarcode(String str) {
  final regex = RegExp(r'^\d{13}$');
  return regex.hasMatch(str);
}
