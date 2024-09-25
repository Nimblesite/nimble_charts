# nimble_charts_common: charts_common Resurrected

This package is part of [nimble_charts](https://pub.dev/packages/nimble_charts). This package is toolkit agnostic and contains shared code. You could use this package to build your own charting Flutter UI library, or even use it for something like [Jaspr](https://pub.dev/packages/jaspr). Below is the documentation for the Flutter package.

![Charts Sample](https://raw.githubusercontent.com/Nimblesite/nimble_charts/main/charts.gif)

This project is a resurrection of the discontinued [charts_flutter](https://pub.dev/packages/charts_flutter). It aims to provide a robust and flexible charting package for Flutter developers.
[Nimblesite](https://www.nimblesite.co/) now maintains this library. While the package name has changed, we are working towards making this fork as compatible as possible with the original.

**🚀 Live Demo**: check out the [live WASM web app demo](https://nimblesite.github.io/nimble_charts/) to see the charts in action!

[![build_and_test](https://github.com/Nimblesite/nimble_charts/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/Nimblesite/nimble_charts/actions/workflows/build_and_test.yml)

## ❓ Why This Fork?

### Dart 3, Type Safety, Tests, and Bug Fixes

Type safety and rigourous tests ensure that this package is reliable and maintainable. We applied thousands of automatic and manual fixes to the code to bring type safety up, and ensure that it's harder to break this library. There are also many new widget tests with goldens, which means that changes should not affect the UI behavior.

This fork provides the most solid foundation for future development, and we will continue to maintain this library.

Please compare the `pubspec.yaml` file, `analysis_options.yaml` file and the test folder with other forks of this library. The difference is clear. This fork only works with Dart 3 and above, which has far better type safety and null safety. 

## 📊 Features

- A wide variety of chart types
- Customizable appearance and behavior
- Flutter-native implementation
- Supports both mobile and web platforms
- Improved documentation and extensive samples

## 🛠️ Installation

Add the following to your `pubspec.yaml`:

nimble_charts: ^0.4.0-beta

## 📝 Usage

This is a full app with a basic line chart.

```dart
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart';

typedef LinearSales = ({int year, int sales});

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LineChart(
                  [
                    Series<LinearSales, int>(
                      id: 'Sales',
                      colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
                      domainFn: (sales, _) => sales.year,
                      measureFn: (sales, _) => sales.sales,
                      data: [
                        (year: 0, sales: 5),
                        (year: 1, sales: 25),
                        (year: 2, sales: 100),
                        (year: 3, sales: 75),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
```

For more examples and detailed documentation, please refer to the example app and documentation.

## ⚖️ License
This project continues the original Google Charts library under the Apache 2.0 license. We honor the original licenses and attributions. See the [LICENSE](LICENSE) and [AUTHORS](AUTHORS) files for details. We are grateful to the Google team for their valuable work on this library.

## Running the Tests

There are many widget tests for the example app. Each of the widget tests create golden files. These golden files are generated with GitHub actions on Linux so they will always be slightly different to your local machine. If you want to run the tests locally, you need to run the following command:

```bash
flutter test --update-goldens
```

Please don't commit goldens in PRs. We will merge your branch to a temporary branch and then run the `generate_goldens.yaml` action to generate the goldens. If there are changes in the goldens, they will show up in the PR.

## What Has Changed?

The Fork occurred at 0.12.0 of the original charts_flutter

- Migrated all packages to Flutter V3
- Overhauled the code in an attempt to keep the same functionality. 
- Uses the [austerity](https://pub.dev/packages/austerity) package to apply hotfixes and bring type safety to the code.
- While the package may gain new features, we will attempt to keep the functionality in line with the original wherever possible.
- We had to disable many existing tests, but we are working on new widget and integration tests to fill the gap. We will also resurrect many of the old tests when time permits. Until there is sufficient test coverage, the package will remain in beta.

## 🤝 Contributing
Contributions are welcome! 

We won't accept new features at this time, but we will accept tests, warning fixes, documentation updates, and bug fixes.

Please pay attention to existing issues and branches before starting work. 

Otherwise, please feel free to submit a Pull Request.
