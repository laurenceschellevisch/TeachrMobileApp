import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LangLocalizations {
  LangLocalizations(this.locale);

  final Locale locale;

  static LangLocalizations of(BuildContext context) {
    return Localizations.of<LangLocalizations>(context, LangLocalizations);
  }
  

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('assets/lang/${this.locale.languageCode}.json');

    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String trans(String key) {
    return this._sentences[key];
  }
}

class LangLocalizationsDelegate
    extends LocalizationsDelegate<LangLocalizations> {
  const LangLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['nl', 'en'].contains(locale.languageCode);

  @override
  Future<LangLocalizations> load(Locale locale) async {
    LangLocalizations localizations = new LangLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LangLocalizationsDelegate old) => false;
}
