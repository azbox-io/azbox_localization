
import 'package:azbox/azbox.dart';
import 'package:azbox/src/azbox_controller.dart';
import 'package:azbox/src/utils/utils.dart';
import 'package:azbox/src/widgets/az_dropdown_controller.dart';
import 'package:azbox/src/widgets/languages.dart';
import 'package:flutter/material.dart';

///Provides a customizable [DropdownButton] for all languages
class LanguagePickerDropdown extends StatefulWidget {
  const LanguagePickerDropdown(
      {super.key, this.itemBuilder,
        this.controller,
        this.onValuePicked,
        this.textStyle,
        this.languages});

  ///This function will be called to build the child of DropdownMenuItem
  ///If it is not provided, default one will be used which displays
  ///flag image, isoCode and phoneCode in a row.
  ///Check _buildDefaultMenuItem method for details.
  final ItemBuilder? itemBuilder;

  ///This function will be called whenever a Language item is selected.
  final ValueChanged<Language>? onValuePicked;

  /// Text style
  final TextStyle? textStyle;

  /// An optional controller.
  final LanguagePickerDropdownController? controller;

  /// List of languages available in this picker.
  final List<Language>? languages;

  @override
  LanguagePickerDropdownState createState() => LanguagePickerDropdownState();
}

class LanguagePickerDropdownState extends State<LanguagePickerDropdown> {
  late List<Language> _languages;
  late Language _selectedLanguage;
  late TextStyle _textStyle;

  @override
  void initState() {
    _languages = widget.languages ?? supportedLanguages();
   if (widget.controller != null) {
      _selectedLanguage = widget.controller!.value;
    } else {
     _selectedLanguage = getSelectedLanguage();
    }

    widget.controller?.addListener(() {
      setState(() {
        _selectedLanguage = widget.controller!.value;
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected language based on current context locale when widget rebuilds
    // This ensures the dropdown shows the correct language when returning to the screen
    if (widget.controller == null) {
      final currentLocale = context.locale;
      final currentLanguage = _languages.firstWhere(
        (language) => language.isoCode == currentLocale.toStringWithSeparator(),
        orElse: () => _selectedLanguage,
      );
      if (currentLanguage != _selectedLanguage) {
        setState(() {
          _selectedLanguage = currentLanguage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _textStyle = widget.textStyle ?? const TextStyle();
    
    // Get current language from context locale to ensure correct display
    // This is a computed value, not state, so it's safe to use in build
    final currentLocale = context.locale;
    final displayedLanguage = widget.controller != null 
        ? _selectedLanguage 
        : _languages.firstWhere(
            (language) => language.isoCode == currentLocale.toStringWithSeparator(),
            orElse: () => _selectedLanguage,
          );
    
    List<DropdownMenuItem<Language>> items = _languages
        .map((language) => DropdownMenuItem<Language>(
        value: language,
        child: widget.itemBuilder != null
            ? widget.itemBuilder!(language)
            : _buildDefaultMenuItem(language)))
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<Language>(
        isExpanded: true,
        onChanged: (value) {
          context.setLocale(value!.isoCode.toLocale());
          setState(() {
            _selectedLanguage = value;
            widget.onValuePicked!(value);
          });
        },
        items: items,
        value: displayedLanguage,
      ),
    );
  }

  Widget _buildDefaultMenuItem(Language language) {
    return Align(
        alignment: Alignment.centerRight,
        child: Text(
            language.name,
            style: _textStyle,
            textAlign: TextAlign.right));
  }

  Language getSelectedLanguage() {
    List<Language> languages = Languages.defaultLanguages;
    // Try to get from internalLocale first, but fallback to first supported language
    final localeString = AzboxController.internalLocale.toStringWithSeparator();
    return languages.firstWhere(
      (language) => language.isoCode == localeString,
      orElse: () => supportedLanguages().first,
    );
  }

  List<Language> supportedLanguages() {
    List<Language> languages = Languages.defaultLanguages;
    List<Language> selectedLanguages = [];
    List<Locale> locales = AzboxController.supportedLocales;
    for (Locale locale in locales) {
      selectedLanguages.addAll(languages.where((language) => language.isoCode == locale.toStringWithSeparator()));
    }
   return selectedLanguages;
  }
}