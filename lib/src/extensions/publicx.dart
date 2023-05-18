import 'package:azbox/azbox.dart';
import 'package:azbox/src/localization.dart';
import 'package:flutter/widgets.dart';

import '../public.dart' as az;

/// Text widget extension method for access to [translate()]
/// Example :
/// ```dart
/// Text('title').translate()
/// ```
extension TextTranslateExtension on Text {
  /// {@macro translate}
  Text translate(
      {List<String>? args,
        BuildContext? context,
        Map<String, String>? namedArgs,
        String? gender}) =>
      Text(
          az.translate(
            data ?? '',
            context: context,
            args: args,
            namedArgs: namedArgs,
            gender: gender,
          ),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);
}

/// Strings extension method for access to [translate()]
/// Example :
/// ```dart
/// 'title'.translate()
/// ```
extension StringTranslateExtension on String {
  /// {@macro translate}
  String translate({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) =>
      az.translate(this,
          context: context, args: args, namedArgs: namedArgs, gender: gender);

  bool trExists() => az.translateExists(this);
}

/// BuildContext extension method for access to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSaveLocale()]
///
/// Example :
///
/// ```dart
/// context.locale = Locale('en', 'US');
/// print(context.locale.toString());
///
/// context.deleteSaveLocale();
///
/// print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, es_ES]
/// print(context.fallbackLocale);   // output: en_US
/// ```
extension BuildContextAzboxExtension on BuildContext {
  /// Get current locale
  Locale get locale => Azbox.of(this)!.locale;

  /// Change app locale
  Future<void> setLocale(Locale val) async =>
      Azbox.of(this)!.setLocale(val);

  /// Get List of supported locales.
  List<Locale> get supportedLocales =>
      Azbox.of(this)!.supportedLocales;

  /// Get fallback locale
  Locale? get fallbackLocale => Azbox.of(this)!.fallbackLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// return
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates =>
      Azbox.of(this)!.delegates;

  /// Clears a saved locale from device storage
  Future<void> deleteSaveLocale() =>
      Azbox.of(this)!.deleteSaveLocale();

  /// Getting device locale from platform
  Locale get deviceLocale => Azbox.of(this)!.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => Azbox.of(this)!.resetLocale();

  /// An extension method for translating your language keys.
  /// Subscribes the widget on current [Localization] that provided from context.
  /// Throws exception if [Localization] was not found.
  ///
  /// [key] Localization key
  /// [args] List of localized strings. Replaces {} left to right
  /// [namedArgs] Map of localized strings. Replaces the name keys {key_name} according to its name
  /// [gender] Gender switcher. Changes the localized string based on gender string
  ///
  /// Example:
  ///
  /// ```json
  /// {
  ///    "msg":"{} are written in the {} language",
  ///    "msg_named":"Azbox localization is written in the {lang} language",
  ///    "msg_mixed":"{} are written in the {lang} language",
  ///    "gender":{
  ///       "male":"Hi man ;) {}",
  ///       "female":"Hello girl :) {}",
  ///       "other":"Hello {}"
  ///    }
  /// }
  /// ```
  /// ```dart
  /// Text(context.translate('msg', args: ['Azbox localization', 'Dart']), // args
  /// Text(context.translate('msg_named', namedArgs: {'lang': 'Dart'}),   // namedArgs
  /// Text(context.translate('msg_mixed', args: ['Azbox localization'], namedArgs: {'lang': 'Dart'}), // args and namedArgs
  /// Text(context.translate('gender', gender: _gender ? "female" : "male"), // gender
  /// ```
  String translate(
      String key, {
        List<String>? args,
        Map<String, String>? namedArgs,
        String? gender,
      }) {
    final localization = Localization.of(this);

    if (localization == null) {
      throw const AZError();
    }

    return localization.translate(
      key,
      args: args,
      namedArgs: namedArgs,
      gender: gender,
    );
  }
}