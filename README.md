
<p align="center"><img src="https://azbox.io/wp-content/uploads/2022/03/Recurso-2.png" width="600"/></p>

<h1 align="center"> 
Easy and Fast internationalization for your Flutter Apps
</h1>

[![Pub Version](https://img.shields.io/pub/v/azbox-localization?style=flat-square&logo=dart)](https://pub.dev/packages/azbox-localization)
![Code Climate issues](https://img.shields.io/github/issues/azbox-io/azbox-localization?style=flat-square)
![GitHub closed issues](https://img.shields.io/github/issues-closed/azbox-io/azbox-localization?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/azbox-io/azbox-localization?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/azbox-io/azbox-localization?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/azbox-io/azbox-localization?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/azbox-io/azbox-localization?style=flat-square)
![Coveralls github branch](https://img.shields.io/coveralls/github/azbox-io/azbox-localization/dev?style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/azbox-io/azbox-localization/Flutter%20Tester?longCache=true&style=flat-square&logo=github)
![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/azbox-io/azbox-localization?style=flat-square)
![GitHub license](https://img.shields.io/github/license/azbox-io/azbox-localization?style=flat-square)

## Why Azbox?

- 🚀 Easy translations for many languages
- 🔌 Load translations as JSON, CSV, Yaml, Xml
- 💾 React and persist to locale changes
- ⚡ Supports gender, nesting, RTL locales and more
- ↩️ Fallback locale keys redirection
- ⁉️ Error widget for missing translations
- ❤️ Extension methods on `Text` and `BuildContext`
- 💻 Code generation for localization files and keys.
- 🛡️ Null safety
- 🖨️ Customizable logger.

## Getting Started

### 🔩 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  azbox-localization: <last_version>
```

### ⚙️ Configuration app

Add Azbox widget like in example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:azbox/azbox.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Azbox.ensureInitialized();
  
  runApp(
    Azbox(
      supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: MyHomePage()
    );
  }
}
```

[**Full example**](https://github.com/azbox-io/azbox-localization/blob/master/example/lib/main.dart)

### 📜 Azbox localization widget properties

| Properties              | Required | Default                   | Description                                                                                                                                                                   |
| ----------------------- | -------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| key                     | false    |                           | Widget key.                                                                                                                                                                   |
| child                   | true     |                           | Place for your main page widget.                                                                                                                                              |
| supportedLocales        | true     |                           | List of supported locales.                                                                                                                                                    |
| fallbackLocale          | false    |                           | Returns the locale when the locale is not in the list `supportedLocales`.                                                                                                     |
| startLocale             | false    |                           | Overrides device locale.                                                                                                                                                      |
| saveLocale              | false    | `true`                    | Save locale in device storage.                                                                                                                                                |
| useFallbackTranslations | false    | `false`                   | If a localization key is not found in the locale file, try to use the fallbackLocale file.                                                                                    |
| useOnlyLangCode         | false    | `false`                   | Trigger for using only language code for reading localization files.</br></br>Example:</br>`en.json //useOnlyLangCode: true`</br>`en-US.json //useOnlyLangCode: false`        |
| errorWidget             | false    | `FutureErrorWidget()`     | Shows a custom error widget when an error occurs.                                                                                                                             |

## Usage

### 🔥 Initialize library

Call `Azbox.ensureInitialized()` in your main before runApp.

```dart
void main() async{
  // ...
  // Needs to be called so that we can await for Azbox.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await Azbox.ensureInitialized();
  // ...
  runApp(....)
  // ...
}
```

### 🔥 Change or get locale

Azbox localization uses extension methods [BuildContext] for access to locale.

It's the easiest way change locale or get parameters 😉.

ℹ️ No breaking changes, you can use old the static method `Azbox.of(context)`

Example:

```dart
context.setLocale(Locale('en', 'US'));

print(context.locale.toString());
```

### 🔥 Translate `translate()`

Main function for translate your language keys

You can use extension methods of [String] or [Text] widget, you can also use `translate()` as a static function.

```dart
Text('title').translate() //Text widget

print('title'.translate()); //String

var title = translate('title') //Static function

Text(context.translate('title')) //Extension on BuildContext
```

#### Arguments:

| Name      | Type                  | Description                                                                         |
| --------- | --------------------- | ----------------------------------------------------------------------------------- |
| args      | `List<String>`        | List of localized strings. Replaces `{}` left to right                              |
| namedArgs | `Map<String, String>` | Map of localized strings. Replaces the name keys `{key_name}` according to its name |
| gender    | `String`              | Gender switcher. Changes the localized string based on gender string                |

Example:

``` json
{
   "msg":"{} are written in the {} language",
   "msg_named":"Azbox localization is written in the {lang} language",
   "msg_mixed":"{} are written in the {lang} language",
   "gender":{
      "male":"Hi man ;) {}",
      "female":"Hello girl :) {}",
      "other":"Hello {}"
   }
}
```

```dart
// args
Text('msg').translate(args: ['Azbox localization', 'Dart']),

// namedArgs
Text('msg_named').translate(namedArgs: {'lang': 'Dart'}),

// args and namedArgs
Text('msg_mixed').translate(args: ['Azbox localization'], namedArgs: {'lang': 'Dart'}),

// gender
Text('gender').translate(gender: _gender ? "female" : "male"),

```

### 🔥 Linked translations:

If there's a translation key that will always have the same concrete text as another one you can just link to it. To link to another translation key, all you have to do is to prefix its contents with an `@:` sign followed by the full name of the translation key including the namespace you want to link to.

Example:
```json
{
  ...
  "example": {
    "hello": "Hello",
    "world": "World!",
    "helloWorld": "@:example.hello @:example.world"
  }
  ...
}
```

```dart
print('example.helloWorld'.translate()); //Output: Hello World!
```

You can also do nested anonymous and named arguments inside the linked messages.

Example:

```json
{
  ...
  "date": "{currentDate}.",
  "dateLogging": "INFO: the date today is @:date"
  ...
}
```
```dart
print('dateLogging'.translate(namedArguments: {'currentDate': DateTime.now().toIso8601String()})); //Output: INFO: the date today is 2020-11-27T16:40:42.657.
```

#### Formatting linked translations:

Formatting linked locale messages
If the language distinguishes cases of character, you may need to control the case of the linked locale messages. Linked messages can be formatted with modifier `@.modifier:key`

The below modifiers are available currently.

- `upper`: Uppercase all characters in the linked message.
- `lower`: Lowercase all characters in the linked message.
- `capitalize`: Capitalize the first character in the linked message.

Example:

```json
{
  ...
  "example": {
    "fullName": "Full Name",
    "emptyNameError": "Please fill in your @.lower:example.fullName"
  }
  ...
}
```

Output:

```dart
print('example.emptyNameError'.translate()); //Output: Please fill in your full name
```

### 🔥 Reset locale `resetLocale()`

Reset locale to device locale

Example:

```dart
RaisedButton(
  onPressed: (){
    context.resetLocale();
  },
  child: Text(LocaleKeys.reset_locale).translate(),
)
```

### 🔥 Get device locale `deviceLocale`

Get device locale

Example:

```dart
print(${context.deviceLocale.toString()}) // OUTPUT: en_US
```

### 🔥 Delete save locale `deleteSaveLocale()`

Clears a saved locale from device storage

Example:

```dart
RaisedButton(
  onPressed: (){
    context.deleteSaveLocale();
  },
  child: Text(LocaleKeys.reset_locale).translate(),
)
```

### 🔥 Get Azbox localization widget properties

At any time, you can take the main [properties](#-azbox-localization-widget-properties) of the Azbox localization widget using [BuildContext].

Are supported: supportedLocales, fallbackLocale, localizationDelegates.

Example:

```dart
print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, ru_RU]

print(context.fallbackLocale); // output: en_US
```

## 💻 Code generation

Code generation supports only json files, for more information run in terminal `flutter pub run azbox_localization:generate -h`

### Command line arguments

| Arguments                    | Short | Default               | Description                                                                 |
| ---------------------------- | ----- | --------------------- | --------------------------------------------------------------------------- |
| --help                       | -h    |                       | Help info                                                                   |
| --source-dir                 | -S    | resources/langs       | Folder containing localization files                                        |
| --source-file                | -s    | First file            | File to use for localization                                                |
| --output-dir                 | -O    | lib/generated         | Output folder stores for the generated file                                 |
| --output-file                | -o    | codegen_loader.g.dart | Output file name                                                            |
| --format                     | -f    | json                  | Support json or keys formats                                                |
| --[no-]skip-unnecessary-keys | -u    | false                 | Ignores keys defining nested object except for pluarl(), gender() keywords. |

### 🔌 Localization asset loader class

Steps:

1. Open your terminal in the folder's path containing your project
2. Run in terminal `flutter pub run azbox_localization:generate`
3. Change asset loader and past import.

  ```dart
  import 'generated/codegen_loader.g.dart';
  ...
  void main(){
    runApp(Azbox(
      child: MyApp(),
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    ));
  }
  ...
  ```
  
4. All done!

### 🔑 Localization keys

If you have many localization keys and are confused, key generation will help you. The code editor will automatically prompt keys

Steps:
1. Open your terminal in the folder's path containing your project 
2. Run in terminal `flutter pub run azbox_localization:generate -f keys -o locale_keys.g.dart`
3. Past import.

```dart
import 'generated/locale_keys.g.dart';
```
4. All done!

How to use generated keys:

```dart
print(LocaleKeys.title.translate()); //String
//or
Text(LocaleKeys.title).translate(); //Widget
```

## ➕ Extensions helpers

### String to locale

```dart
'en_US'.toLocale(); // Locale('en', 'US')

//with custom separator
'en|US'.toLocale(separator: '|') // Locale('en', 'US')
```
### Locale to String with separator

```dart
Locale('en', 'US').toStringWithSeparator(separator: '|') // en|US
```
