part of '../azbox.dart';

/// [Azbox] locale helper
extension Localex on Locale {
  /// Convert [locale] to String with custom separator
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}