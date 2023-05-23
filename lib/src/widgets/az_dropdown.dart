
import 'package:azbox/azbox.dart';
import 'package:azbox/src/azbox_controller.dart';
import 'package:azbox/src/utils/utils.dart';
import 'package:azbox/src/widgets/az_dropdown_controller.dart';
import 'package:azbox/src/widgets/language.dart';
import 'package:azbox/src/widgets/languages.dart';
import 'package:flutter/material.dart';

///Provides a customizable [DropdownButton] for all languages
class LanguagePickerDropdown extends StatefulWidget {
  LanguagePickerDropdown(
      {this.itemBuilder,
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
  _LanguagePickerDropdownState createState() => _LanguagePickerDropdownState();
}

class _LanguagePickerDropdownState extends State<LanguagePickerDropdown> {
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
  Widget build(BuildContext context) {
    _textStyle = widget.textStyle ?? const TextStyle();
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
        value: _selectedLanguage,
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
    return languages.firstWhere((language) => language.isoCode == AzboxController.internalLocale.toStringWithSeparator(), orElse:() => supportedLanguages().first);
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