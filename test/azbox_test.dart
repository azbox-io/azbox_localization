import 'dart:async';
import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:azbox/azbox.dart';
import 'package:azbox/src/azbox_controller.dart';
import 'package:azbox/src/localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var printLog = [];

dynamic overridePrint(Function() testFn) => () {
  var spec = ZoneSpecification(print: (_, __, ___, String msg) {
    // Add to log instead of printing to stdout
    printLog.add(msg);
  });
  return Zone.current.fork(specification: spec).run(testFn);
};

void main() {
  group('localization', () {
    var r1 = AzboxController(
        apiKey: '',
        projectId: '',
        forceLocale: const Locale('en'),
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        );
    var r2 = AzboxController(
        apiKey: '',
        projectId: '',
        forceLocale: const Locale('en', 'us'),
        useFallbackTranslations: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        saveLocale: false);
    
    setUpAll(() async {
      await r1.loadTranslations();
      await r2.loadTranslations();
      Localization.load(const Locale('en'), translations: r1.translations);
    });
    test('is a localization object', () {
      expect(Localization.instance, isInstanceOf<Localization>());
    });
    test('is a singleton', () {
      expect(Localization.instance, Localization.instance);
    });

    test('is a localization object', () {
      expect(Localization.instance, isInstanceOf<Localization>());
    });

    test('load() succeeds', () async {
      expect(
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
    });

    test('load() with fallback succeeds', () async {
      expect(
          Localization.load(const Locale('en'),
              translations: r1.translations,
              fallbackTranslations: r2.translations),
          true);
    });

    test('merge fallbackLocale with locale without country code succeeds',
            () async {
          await AzboxController(
            apiKey: '',
            projectId: '',
            forceLocale: const Locale('es', 'AR'),
            useFallbackTranslations: true,
            onLoadError: (FlutterError e) {
              throw e;
            },
            saveLocale: false,
          ).loadTranslations();
        });

    test('localeFromString() succeeds', () async {
      expect(const Locale('ar'), 'ar'.toLocale());
      expect(const Locale('ar', 'DZ'), 'ar_DZ'.toLocale());
      expect(const Locale.fromSubtags(languageCode: 'ar', scriptCode: 'Arab'),
          'ar_Arab'.toLocale());
      expect(
          const Locale.fromSubtags(
              languageCode: 'ar', scriptCode: 'Arab', countryCode: 'DZ'),
          'ar_Arab_DZ'.toLocale());
    });

    test('load() Failed assertion', () async {
      try {
        Localization.load(const Locale('en'), translations: null);
      } on AssertionError catch (e) {
        // throw  AssertionError('Expected ArgumentError');
        expect(e, isAssertionError);
      }
    });

    test('load() correctly sets locale path', () async {
      expect(
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
      expect(Localization.instance.translate('path'), 'path/en.json');
    });

    test('load() respects useOnlyLangCode', () async {
      expect(
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
      expect(Localization.instance.translate('path'), 'path/en.json');

      expect(
          Localization.load(const Locale('en', 'us'),
              translations: r2.translations),
          true);
      expect(Localization.instance.translate('path'), 'path/en-us.json');
    });

    test('controller loads saved locale', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'en',
      });
      await Azbox.ensureInitialized();
      final controller =AzboxController(
        apiKey: '',
        projectId: '',
        useFallbackTranslations: true,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        saveLocale: true,
      );
      expect(controller.locale, const Locale('en'));

      SharedPreferences.setMockInitialValues({});
    });

    /// E.g. if user saved a locale that was removed in a later version
    test('controller loads fallback if saved locale is not supported',
            () async {
          SharedPreferences.setMockInitialValues({
            'locale': 'de',
          });
          await Azbox.ensureInitialized();
          final controller = AzboxController(
            apiKey: '',
            projectId: '',
            useFallbackTranslations: true,
            onLoadError: (FlutterError e) {
              log(e.toString());
            },
            saveLocale: true,
          );
          expect(controller.locale, const Locale('fb'));

          SharedPreferences.setMockInitialValues({});
        });

    group('locale', () {
      test('locale supports device locale', () {
        const en = Locale('en');
        const en2 = Locale('en', '');
        const enUS = Locale('en', 'US');
        const enGB = Locale('en', 'GB');
        expect(en.supports(enUS), isTrue);
        expect(en2.supports(enUS), isTrue);
        expect(enUS.supports(enUS), isTrue);
        expect(enGB.supports(enUS), isFalse);

        const zh = Locale('zh', '');
        const zh2 = Locale('zh', '');
        const zhCN = Locale('zh', 'CN');
        const zhHans =
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
        const zhHant =
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
        const zhHansCN = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');
        expect(zh.supports(zhHansCN), isTrue);
        expect(zh2.supports(zhHansCN), isTrue);
        expect(zhCN.supports(zhHansCN), isTrue);
        expect(zhHans.supports(zhHansCN), isTrue);
        expect(zhHant.supports(zhHansCN), isFalse);
        expect(zhHansCN.supports(zhHansCN), isTrue);
      });

      test('select locale from device locale', () {
        const en = Locale('en', '');
        const zh = Locale('zh', '');
        const zhHans =
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
        const zhHant =
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
        const zhHansCN = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');

        expect(
          AzboxController.selectLocaleFrom([en, zh], zhHansCN),
          zh,
        );
        expect(
          AzboxController.selectLocaleFrom(
              [zhHant, zhHans], zhHansCN),
          zhHans,
        );
      });
    });

    group('tr', () {
      var r = AzboxController(
          apiKey: '',
          projectId: '',
          forceLocale: const Locale('en'),
          useFallbackTranslations: true,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          saveLocale: false);

      setUpAll(() async {
        await r.loadTranslations();
        Localization.load(const Locale('en'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
      });
      test('finds and returns resource', () {
        expect(Localization.instance.translate('test'), 'test');
      });

      test('can resolve resource in any nest level', () {
        expect(
          Localization.instance.translate('nested.super.duper.nested'),
          'nested.super.duper.nested',
        );
      });
      test('can resolve resource that has a key with dots', () {
        expect(
          Localization.instance.translate('nested.but.not.nested'),
          'nested but not nested',
        );
      });

      test('won\'t fail for missing key (no periods)', () {
        expect(
          Localization.instance.translate('Processing'),
          'Processing',
        );
      });

      test('won\'t fail for missing key with periods', () {
        expect(
          Localization.instance.translate('Processing.'),
          'Processing.',
        );
      });

      test('can resolve linked locale messages', () {
        expect(Localization.instance.translate('linked'), 'this is linked');
      });

      test('can resolve linked locale messages and apply modifiers', () {
        expect(Localization.instance.translate('linkAndModify'),
            'this is linked and MODIFIED');
      });

      test('can resolve multiple linked locale messages and apply modifiers',
              () {
            expect(Localization.instance.translate('linkMany'), 'many Locale messages');
          });

      test('can resolve linked locale messages with brackets', () {
        expect(Localization.instance.translate('linkedWithBrackets'),
            'linked with brackets.');
      });

      test('can resolve any number of nested arguments', () {
        expect(
            Localization.instance
                .translate('nestedArguments', args: ['a', 'argument', '!']),
            'this is a nested argument!');
      });

      test('can resolve nested named arguments', () {
        expect(
            Localization.instance.translate('nestedNamedArguments', namedArgs: {
              'firstArg': 'this',
              'secondArg': 'named argument',
              'thirdArg': '!'
            }),
            'this is a nested named argument!');
      });

      test('returns missing resource as provided', () {
        expect(Localization.instance.translate('test_missing'), 'test_missing');
      });

      test('reports missing resource', overridePrint(() {
        printLog = [];
        expect(Localization.instance.translate('test_missing'), 'test_missing');
        final logIterator = printLog.iterator;
        logIterator.moveNext();
        expect(logIterator.current,
            contains('Localization key [test_missing] not found'));
        logIterator.moveNext();
        expect(logIterator.current,
            contains('Fallback localization key [test_missing] not found'));
      }));

      test('uses fallback translations', overridePrint(() {
        printLog = [];
        expect(Localization.instance.translate('test_missing_fallback'), 'fallback!');
      }));

      test('reports missing resource with fallback', overridePrint(() {
        printLog = [];
        expect(Localization.instance.translate('test_missing_fallback'), 'fallback!');
        expect(printLog.first,
            contains('Localization key [test_missing_fallback] not found'));
      }));

      test('returns resource and replaces argument', () {
        expect(
          Localization.instance.translate('test_replace_one', args: ['one']),
          'test replace one',
        );
      });
      test('returns resource and replaces argument in any nest level', () {
        expect(
          Localization.instance
              .translate('nested.super.duper.nested_with_arg', args: ['what a nest']),
          'nested.super.duper.nested_with_arg what a nest',
        );
      });

      test('returns resource and replaces argument sequentially', () {
        expect(
          Localization.instance.translate('test_replace_two', args: ['one', 'two']),
          'test replace one two',
        );
      });

      test('return resource and replaces named argument', () {
        expect(
          Localization.instance.translate('test_replace_named',
              namedArgs: {'arg1': 'one', 'arg2': 'two'}),
          'test named replace one two',
        );
      });

      test('returns resource and replaces named argument in any nest level',
              () {
            expect(
              Localization.instance.translate('nested.super.duper.nested_with_named_arg',
                  namedArgs: {'arg': 'what a nest'}),
              'nested.super.duper.nested_with_named_arg what a nest',
            );
          });

      test('gender returns the correct resource', () {
        expect(
          Localization.instance.translate('gender', gender: 'male'),
          'Hi man ;)',
        );
        expect(
          Localization.instance.translate('gender', gender: 'female'),
          'Hello girl :)',
        );
      });

      test('gender returns the correct resource and replaces args', () {
        expect(
          Localization.instance
              .translate('gender_and_replace', gender: 'male', args: ['one']),
          'Hi one man ;)',
        );
        expect(
          Localization.instance
              .translate('gender_and_replace', gender: 'female', args: ['one']),
          'Hello one girl :)',
        );
      });
    });
});
}