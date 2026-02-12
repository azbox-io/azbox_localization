## 1.0.16

* Improved API performance by fetching only the current project.

## 1.0.15

* Fixed API error handling when `errors` field is null to avoid `NoSuchMethodError` and return a proper `AZError`.

## 1.0.14

* Increased cache TTL for keywords to 24 hours to improve performance and reduce API usage

## 1.0.13

* Fixed language switching and dropdown display issues

## 1.0.12

* Fixed language switching issue by making afterUpdatedAt language-specific

## 1.0.11

* Enhanced offline experience by checking cache first before making API calls

## 1.0.10

* Optimized cache strategy to prioritize cache over API calls, significantly reducing network requests
* Improved incremental synchronization logic for better cache management

## 1.0.9

* Update intl

## 1.0.8

* Fixed when get language list

## 1.0.7

* Change icon size

## 1.0.6

* Added Flutter Web compatibility for cache strategy
* Updated dependencies to latest versions
* Improved platform-specific storage handling

## 1.0.5

* If it does not find supportedLocales, take the deviceLocale

## 1.0.4

* Updated dependencies.

## 1.0.3

* Use cache strategy for projects and keywords.

## 1.0.2

* Added Dropdown Language Selector to select between the supported locales.
* `capitalize` option when use `translate()`

## 1.0.1

* `supportedLocales` is no longer needed since it is obtained from the project languages.

## 1.0.0

* Bug fixing.

## 0.0.1

* Initial release.
