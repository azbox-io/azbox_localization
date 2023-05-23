import 'package:flutter/widgets.dart';
import 'localization.dart';

/// {@template translate}
/// Main function for translate your language keys
/// [key] Localization key
/// [BuildContext] The location in the tree where this widget builds
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
/// Text('msg').translate(args: ['Azbox localization', 'Dart']), // args
/// Text('msg_named').translate(namedArgs: {'lang': 'Dart'}),   // namedArgs
/// Text('msg_mixed').translate(args: ['Azbox localization'], namedArgs: {'lang': 'Dart'}), // args and namedArgs
/// Text('gender').translate(gender: _gender ? "female" : "male"), // gender
/// ```
/// {@endtemplate}
String translate(
    String key, {
      BuildContext? context,
      List<String>? args,
      Map<String, String>? namedArgs,
      bool? capitalize = true,
      String? gender,
    }) {
  return context != null
      ? Localization.of(context)!
      .translate(key, args: args, namedArgs: namedArgs, gender: gender, capitalize: capitalize)
      : Localization.instance
      .translate(key, args: args, namedArgs: namedArgs, gender: gender, capitalize: capitalize);
}

bool translateExists(String key) {
  return Localization.instance
      .exists(key);
}