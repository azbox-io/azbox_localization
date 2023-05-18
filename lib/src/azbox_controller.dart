import 'package:azbox/azbox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart'
if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'azbox_api.dart';
import 'translations.dart';

class AzboxController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;

  late Locale _locale;
  Locale? _fallbackLocale;

  final Function(FlutterError e) onLoadError;
  // ignore: prefer_typing_uninitialized_variables
  final String apiKey;
  final String project;
  final bool useFallbackTranslations;
  final bool saveLocale;
  Translations? _translations, _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  AzboxController({
    required this.apiKey,
    required this.project,
    required List<Locale> supportedLocales,
    required this.useFallbackTranslations,
    required this.saveLocale,
    required this.onLoadError,
    Locale? startLocale,
    Locale? fallbackLocale,
    Locale? forceLocale, // used for testing
  }) {
    _fallbackLocale = fallbackLocale;
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(supportedLocales, startLocale);
      if (kDebugMode) {
        print('Start locale loaded ${_locale.toString()}');
      }
    }
    // If saved locale then get
    else if (saveLocale && _savedLocale != null) {
      if (kDebugMode) {
        print('Saved locale loaded ${_savedLocale.toString()}');
      }
      _locale = selectLocaleFrom(
        supportedLocales,
        _savedLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      // From Device Locale
      _locale = selectLocaleFrom(
        supportedLocales,
        _deviceLocale,
        fallbackLocale: fallbackLocale,
      );
    }
  }

  @visibleForTesting
  static Locale selectLocaleFrom(
      List<Locale> supportedLocales,
      Locale deviceLocale, {
        Locale? fallbackLocale,
      }) {
    final selectedLocale = supportedLocales.firstWhere(
          (locale) => locale.supports(deviceLocale),
      orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale),
    );
    return selectedLocale;
  }

  //Get fallback Locale
  static Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale? fallbackLocale) {
    //If fallbackLocale not set then return first from supportedLocales
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      data = await loadTranslationData(_locale);
      _translations = Translations(data);
      if (useFallbackTranslations && _fallbackLocale != null) {
        Map<String, dynamic>? baseLangData;
        if (_locale.countryCode != null && _locale.countryCode!.isNotEmpty) {
          baseLangData =
          await loadBaseLangTranslationData(Locale(locale.languageCode));
        }
        data = await loadTranslationData(_fallbackLocale!);
        if (baseLangData != null) {
          try {
            data.addAll(baseLangData);
          } on UnsupportedError {
            data = Map.of(data)..addAll(baseLangData);
          }
        }
        _fallbackTranslations = Translations(data);
      }
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> loadBaseLangTranslationData(
      Locale locale) async {
    try {
      return await loadTranslationData(Locale(locale.languageCode));
    } on FlutterError catch (e) {
      // Disregard asset not found FlutterError when attempting to load base language fallback
      if (kDebugMode) {
        print(e.message);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> loadTranslationData(Locale locale) async {
    late Map<String, dynamic>? data;

    var azboxApi = AzboxAPI(
        apiKey: apiKey,
        project: project);

    data = await azboxApi.getKeywords(language: locale.languageCode.toUpperCase());

    if (data == null) return {};

    return data;
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale l) async {
    _locale = l;
    await loadTranslations();
    notifyListeners();
    if (kDebugMode) {
      print('Locale $locale changed');
    }
    await _saveLocale(_locale);
  }

  Future<void> _saveLocale(Locale? locale) async {
    if (!saveLocale) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.toString());
    if (kDebugMode) {
      print('Locale $locale saved');
    }
  }

  static Future<void> initAzbox() async {
    final preferences = await SharedPreferences.getInstance();
    final strLocale = preferences.getString('locale');
    _savedLocale = strLocale?.toLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    if (kDebugMode) {
      print('Azbox localization initialized');
    }
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('locale');
    if (kDebugMode) {
      print('Saved locale deleted');
    }
  }

  Locale get deviceLocale => _deviceLocale;

  Future<void> resetLocale() async {
    if (kDebugMode) {
      print('Reset locale to platform locale $_deviceLocale');
    }

    await setLocale(_deviceLocale);
  }
}

@visibleForTesting
extension LocaleExtension on Locale {
bool supports(Locale locale) {
  if (this == locale) {
    return true;
  }
  if (languageCode != locale.languageCode) {
    return false;
  }
  if (countryCode != null &&
      countryCode!.isNotEmpty &&
      countryCode != locale.countryCode) {
    return false;
  }
  if (scriptCode != null && scriptCode != locale.scriptCode) {
    return false;
  }

  return true;
}
}