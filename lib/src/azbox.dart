import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:async';

import 'package:azbox/src/azbox_controller.dart';
import 'localization.dart';

part 'extensions/localex.dart';
part 'extensions/stringx.dart';

class Azbox extends StatefulWidget {

  /// The AZbox API Key.
  /// create it here https://azbox.io/
  final String apiKey;

  /// The project Id associated with your project.
  final String project;

  /// Place for your main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  final Widget Function(FlutterError? message)? errorWidget;

  Azbox({
    Key? key,
    required this.apiKey,
    required this.project,
    required this.child,
    required this.supportedLocales,
    this.fallbackLocale,
    this.startLocale,
    this.useFallbackTranslations = false,
    this.saveLocale = true,
    this.errorWidget,
  })  : assert(supportedLocales.isNotEmpty),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AzboxState createState() => _AzboxState();

  // ignore: library_private_types_in_public_api
  static _AzboxProvider? of(BuildContext context) =>
      _AzboxProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async =>
      await AzboxController.initAzbox();
}

class _AzboxState extends State<Azbox> {
  _AzboxDelegate? delegate;
  AzboxController? localizationController;
  FlutterError? translationsLoadError;

  @override
  void initState() {
    localizationController = AzboxController(
      apiKey: widget.apiKey,
      project: widget.project,
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      useFallbackTranslations: widget.useFallbackTranslations,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (translationsLoadError != null) {
      return widget.errorWidget != null
          ? widget.errorWidget!(translationsLoadError)
          : ErrorWidget(translationsLoadError!);
    }
    return _AzboxProvider(
      widget,
      localizationController!,
      delegate: _AzboxDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
      ),
    );
  }
}

class _AzboxProvider extends InheritedWidget {
  final Azbox parent;
  final AzboxController _localeState;
  final Locale? currentLocale;
  final _AzboxDelegate delegate;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  _AzboxProvider(this.parent, this._localeState,
      {Key? key, required this.delegate})
      : currentLocale = _localeState.locale,
        super(key: key, child: parent.child);

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSaveLocale() async {
    await _localeState.deleteSaveLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_AzboxProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _AzboxProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AzboxProvider>();
}

class _AzboxDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale>? supportedLocales;
  final AzboxController? localizationController;

  _AzboxDelegate(
      {this.localizationController, this.supportedLocales}) {
    if (kDebugMode) {
      print('Init Localization Delegate');
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    if (kDebugMode) {
      print('Load Localization Delegate');
    }
    if (localizationController!.translations == null) {
      await localizationController!.loadTranslations();
    }

    Localization.load(value,
        translations: localizationController!.translations,
        fallbackTranslations: localizationController!.fallbackTranslations);
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}