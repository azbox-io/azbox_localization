import 'package:azbox/azbox.dart';
import 'package:azbox/src/codes.dart';
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
  static List<Locale> _supportedLocales = [];
  static late AzboxAPI? _azboxApi;

  late Locale _locale;
  late List<Locale> supportedLocales = [];

  final Function(FlutterError e) onLoadError;
  // ignore: prefer_typing_uninitialized_variables
  final bool useFallbackTranslations;
  final bool saveLocale;
  Translations? _translations, _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  AzboxController({
    required this.useFallbackTranslations,
    required this.saveLocale,
    required this.onLoadError,
    Locale? startLocale,
    Locale? forceLocale, // used for testing
  }) {
    supportedLocales = _supportedLocales;
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = startLocale;
    }
    else if (saveLocale && _savedLocale != null) {
      if (kDebugMode) {
        print('Saved locale loaded ${_savedLocale.toString()}');
      }
      _locale = selectLocaleFrom(
        supportedLocales,
        _savedLocale!
      );
    } else {
      _locale = selectLocaleFrom(
        supportedLocales,
        _deviceLocale,
      );
    }
    if (kDebugMode) {
      print('Locale loaded ${_locale.toString()}');
    }
  }

  @visibleForTesting
  static Locale selectLocaleFrom(
      List<Locale> supportedLocales,
      Locale deviceLocale) {
    final selectedLocale = supportedLocales.firstWhere(
          (locale) => locale.supports(deviceLocale),
      orElse: () => supportedLocales.first,
    );
    return selectedLocale;
  }

  static Future<List<Locale>> getSupportedLocales() async {
    List<dynamic> projects = [];
    List<Locale> locales = [];

    if (_azboxApi != null) {
      projects = await _azboxApi!.getProjects();
    }

    var project = projects.firstWhere((p) => p['id'] == _azboxApi!.projectId, orElse: () => null);

    if (project != null) {

      List projectLanguages = projects[0]['data']['languages'];
      for (String projectLanguage in projectLanguages) {
        String? localeStr = Code.codes[projectLanguage];
        if (localeStr != null) {
          locales.add(localeStr.toLocale());
        }
      }
    }
    return locales;
  }

  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      data = await loadTranslationData(_locale);
      _translations = Translations(data);
      // if (useFallbackTranslations && _fallbackLocale != null) {
      //   Map<String, dynamic>? baseLangData;
      //   if (_locale.countryCode != null && _locale.countryCode!.isNotEmpty) {
      //     baseLangData =
      //     await loadBaseLangTranslationData(Locale(locale.languageCode));
      //   }
      //   data = await loadTranslationData(_fallbackLocale!);
      //   if (baseLangData != null) {
      //     try {
      //       data.addAll(baseLangData);
      //     } on UnsupportedError {
      //       data = Map.of(data)..addAll(baseLangData);
      //     }
      //   }
      //   _fallbackTranslations = Translations(data);
      // }
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

    String language = Code.codes.keys.firstWhere(
        (k) =>  Code.codes[k] == locale.toStringWithSeparator(),
        orElse: () => Code.codes.keys.first);

    if (_azboxApi != null) {
      data = await _azboxApi?.getKeywords(language: language.toUpperCase());
    }

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

  static Future<void> initAzbox(String apiKey, String projectId) async {
    final preferences = await SharedPreferences.getInstance();
    final strLocale = preferences.getString('locale');
    _savedLocale = strLocale?.toLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    _azboxApi = AzboxAPI(
        apiKey: apiKey,
        project: projectId);
    _supportedLocales = await getSupportedLocales();

    if (kDebugMode) {
      print('Supported locales: $_supportedLocales');
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