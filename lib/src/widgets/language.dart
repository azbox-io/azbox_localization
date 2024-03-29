import 'package:azbox/src/widgets/languages.dart';

class Language {
  Language(this.isoCode, this.name);

  final String name;
  final String isoCode;

  Language.fromMap(Map<String, String> map)
      : name = map['name']!,
        isoCode = map['isoCode']!;

  /// Returns the Language matching the given ISO code from the standard list.
  factory Language.fromIsoCode(String isoCode) =>
      Languages.defaultLanguages.firstWhere((l) => l.isoCode == isoCode);

  @override
  bool operator == (other) =>
      other is Language && name == other.name && isoCode == other.isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}