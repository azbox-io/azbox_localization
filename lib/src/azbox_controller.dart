import 'package:azbox/azbox.dart';
import 'package:azbox/src/cache_strategy/cache_strategy.dart';
import 'package:azbox/src/cache_strategy/storage/cache_storage_impl.dart';
import 'package:azbox/src/codes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';

import 'azbox_api.dart';
import 'cache_strategy/strategies/cache_or_async_strategy.dart';
import 'translations.dart';

class AzboxController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;
  static List<Locale> supportedLocales = [];
  static Locale internalLocale = Locale('', '');
  static late AzboxAPI? _azboxApi;
  late Locale _locale;
  late List<Locale> locales = [];

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
    locales = supportedLocales;
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = startLocale;
    } else if (saveLocale && _savedLocale != null) {
      if (kDebugMode) {
        print('Saved locale loaded ${_savedLocale.toString()}');
      }
      _locale = selectLocaleFrom(locales, _savedLocale!);
    } else {
      _locale = selectLocaleFrom(
        locales,
        _deviceLocale,
      );
    }
    internalLocale = _locale;
    if (kDebugMode) {
      print('Locale loaded ${_locale.toString()}');
    }
  }

  @visibleForTesting
  static Locale selectLocaleFrom(List<Locale> supportedLocales, Locale deviceLocale) {
    try {
      final selectedLocale = supportedLocales.firstWhere(
            (locale) => locale.supports(deviceLocale),
        orElse: () => supportedLocales.first,
      );
      return selectedLocale;
    } catch (e) {
      return deviceLocale;
    }
  }

  static Future<List<Locale>> getSupportedLocales() async {
    List<dynamic> projects = [];
    List<Locale> locales = [];

    if (_azboxApi != null) {
      var result = await FlutterCacheStrategy().execute<dynamic>(
        keyCache: 'projects',
        serializer: (data) {
          return data;
        },
        async: _azboxApi!.getProjects(),
        strategy: CacheOrAsyncStrategy(),
      );

      if (result is List<dynamic>) {
        projects = result;
      }
    }

    var project = projects.firstWhere((p) => p['id'] == _azboxApi!.projectId, orElse: () => null);

    if (project != null) {
      List projectLanguages = project['data']['languages'];
      for (String projectLanguage in projectLanguages) {
        String? localeStr = Code.codes[projectLanguage];
        if (localeStr != null) {
          locales.add(localeStr.toLocale());
        }
      }
    } else {
      locales = [_deviceLocale];
    }
    return locales;
  }

  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      data = await loadTranslationData(_locale);
      _translations = Translations(data);
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> loadBaseLangTranslationData(Locale locale) async {
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

    String language = Code.codes.keys.firstWhere((k) => Code.codes[k] == locale.toStringWithSeparator(), orElse: () => Code.codes.keys.first);

    // Get last date time loaded for incremental sync (specific per language)
    // Only use afterUpdatedAt if we have previously successfully loaded this language
    // For first-time language loads, don't use afterUpdatedAt
    String afterUpdatedAtKey = 'afterUpdatedAt_$language';
    dynamic cacheAfterUpdatedAt = CacheStorage().read(afterUpdatedAtKey);
    DateTime? afterUpdatedAt = cacheAfterUpdatedAt is String ? DateTime.parse(cacheAfterUpdatedAt) : null;
    
    // If afterUpdatedAt is null, this is the first time loading this language
    bool isFirstTimeLoad = afterUpdatedAt == null;

    if (_azboxApi != null) {
      // Use CacheOrAsyncStrategy: check cache first, only call API if cache is missing or expired
      // TTL set to 24 hours (86400000 ms) for keywords as they don't change frequently
      var result = await FlutterCacheStrategy().execute<Map<String, dynamic>?>(
        keyCache: 'keywords_$language',
        serializer: (data) {
          // If cached data is an empty map, return null to force API call
          if (data is Map && (data.isEmpty || data.length == 0)) {
            return null;
          }
          return data;
        },
        async: _azboxApi?.getKeywords(
          language: language.toUpperCase(), 
          afterUpdatedAt: isFirstTimeLoad ? null : afterUpdatedAt,
        ),
        strategy: CacheOrAsyncStrategy(),
        timeToLiveValue: 24 * 60 * 60 * 1000, // 24 hours in milliseconds
      );

      if (result is Map<String, dynamic>?) {
        data = result;
        // If we got an empty map from cache or API, clear cache and try again without afterUpdatedAt
        if (data != null && data.isEmpty) {
          await FlutterCacheStrategy().clearCache(keyCache: 'keywords_$language');
          // Try again without afterUpdatedAt (first time load)
          data = await _azboxApi?.getKeywords(language: language.toUpperCase(), afterUpdatedAt: null);
        }
      }
    }

    if (data == null || data.isEmpty) return {};

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
    await CacheStorage().write('locale', locale.toString());
    if (kDebugMode) {
      print('Locale $locale saved');
    }
  }

  static Future<void> initAzbox(String apiKey, String projectId) async {
    String? strLocale;
    final dynamic cacheLocale = CacheStorage().read('locale');
    if (cacheLocale is String) {
      strLocale = cacheLocale;
    }
    _savedLocale = strLocale?.toLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    _azboxApi = AzboxAPI(apiKey: apiKey, project: projectId);
    supportedLocales = await getSupportedLocales();

    if (kDebugMode) {
      print('Supported locales: $supportedLocales');
      print('Azbox localization initialized');
    }
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    await CacheStorage().write('locale', null);
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
    if (countryCode != null && countryCode!.isNotEmpty && countryCode != locale.countryCode) {
      return false;
    }
    if (scriptCode != null && scriptCode != locale.scriptCode) {
      return false;
    }

    return true;
  }
}
