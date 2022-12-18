import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String?> scanBarcode(context) async {
  try {
    var result = await BarcodeScanner.scan();
    if (result.type.name == "Barcode") {
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

Future<String> getFoodRepoTitle(String query, context) async {
  var apiKey = '12cf99fc88c83f24eda4367d4a90dbbd';
  var headers = {
    'Accept': 'application/json',
    'Authorization': 'Token token=$apiKey'
  };
  var url =
      'https://www.foodrepo.org/api/v3/products?excludes=nutrients&barcodes=$query';
  try {
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final searchResults = json.decode(response.body);
      return _getDisplayNameTranslation(searchResults, context);
    } else {
      return AppLocalizations.of(context)!.noProductFound;
    }
  } catch (e) {
    return AppLocalizations.of(context)!.networkError;
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

String barcodeType(String str) {
  final eanRegex = RegExp(r'^\d{13}$');
  final upcRegex = RegExp(r'^\d{12}$');
  if (eanRegex.hasMatch(str)) {
    return "EAN";
  }
  if (upcRegex.hasMatch(str)) {
    return "UPC";
  }
  return "invalid";
}
