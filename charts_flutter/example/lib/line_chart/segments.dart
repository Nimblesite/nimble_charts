// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Example of a stacked area chart with changing styles within each line.
///
/// Each series of data in this example contains different values for color,
/// dashPattern, or strokeWidthPx between each datum. The line and area skirt
/// will be rendered in segments, with the styling of the series changing when
/// these data attributes change.
///
/// Note that if a dashPattern or strokeWidth value is not found for a
/// particular datum, then the chart will fall back to use the value defined in
/// the [charts.LineRendererConfig]. This could be used, for example, to define
/// a default dash pattern for the series, with only a specific datum called out
/// with a different pattern.
library;

// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';

import 'package:flutter/material.dart';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:nimble_charts/flutter.dart' as charts;

class SegmentsLineChart extends StatelessWidget {
  const SegmentsLineChart(this.seriesList, {super.key, this.animate = true});

  /// Creates a [charts.LineChart] with sample data and no transition.
  factory SegmentsLineChart.withSampleData() => SegmentsLineChart(
        _createSampleData(),
      );

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SegmentsLineChart.withRandomData() =>
      SegmentsLineChart(_createRandomData());
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  /// Create random data.
  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    // Series of data with static dash pattern and stroke width. The colorFn
    // accessor will colorize each datum (for all three series).
    final colorChangeData = [
      LinearSales(0, random.nextInt(100), null, 2),
      LinearSales(1, random.nextInt(100), null, 2),
      LinearSales(2, random.nextInt(100), null, 2),
      LinearSales(3, random.nextInt(100), null, 2),
      LinearSales(4, random.nextInt(100), null, 2),
      LinearSales(5, random.nextInt(100), null, 2),
      LinearSales(6, random.nextInt(100), null, 2),
    ];

    // Series of data with changing color and dash pattern.
    final dashPatternChangeData = [
      LinearSales(0, random.nextInt(100), [2, 2], 2),
      LinearSales(1, random.nextInt(100), [2, 2], 2),
      LinearSales(2, random.nextInt(100), [4, 4], 2),
      LinearSales(3, random.nextInt(100), [4, 4], 2),
      LinearSales(4, random.nextInt(100), [4, 4], 2),
      LinearSales(5, random.nextInt(100), [8, 3, 2, 3], 2),
      LinearSales(6, random.nextInt(100), [8, 3, 2, 3], 2),
    ];

    // Series of data with changing color and stroke width.
    final strokeWidthChangeData = [
      LinearSales(0, random.nextInt(100), null, 2),
      LinearSales(1, random.nextInt(100), null, 2),
      LinearSales(2, random.nextInt(100), null, 4),
      LinearSales(3, random.nextInt(100), null, 4),
      LinearSales(4, random.nextInt(100), null, 4),
      LinearSales(5, random.nextInt(100), null, 6),
      LinearSales(6, random.nextInt(100), null, 6),
    ];

    // Generate 2 shades of each color so that we can style the line segments.
    final blue = charts.MaterialPalette.blue.makeShades(2);
    final red = charts.MaterialPalette.red.makeShades(2);
    final green = charts.MaterialPalette.green.makeShades(2);

    return [
      charts.Series<LinearSales, int>(
        id: 'Color Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? blue[1] : blue[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: colorChangeData,
      ),
      charts.Series<LinearSales, int>(
        id: 'Dash Pattern Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? red[1] : red[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: dashPatternChangeData,
      ),
      charts.Series<LinearSales, int>(
        id: 'Stroke Width Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? green[1] : green[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: strokeWidthChangeData,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) => charts.LineChart(
        seriesList,
        defaultRenderer:
            charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate,
      );

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    // Series of data with static dash pattern and stroke width. The colorFn
    // accessor will colorize each datum (for all three series).
    final colorChangeData = [
      LinearSales(0, 5, null, 2),
      LinearSales(1, 15, null, 2),
      LinearSales(2, 25, null, 2),
      LinearSales(3, 75, null, 2),
      LinearSales(4, 100, null, 2),
      LinearSales(5, 90, null, 2),
      LinearSales(6, 75, null, 2),
    ];

    // Series of data with changing color and dash pattern.
    final dashPatternChangeData = [
      LinearSales(0, 5, [2, 2], 2),
      LinearSales(1, 15, [2, 2], 2),
      LinearSales(2, 25, [4, 4], 2),
      LinearSales(3, 75, [4, 4], 2),
      LinearSales(4, 100, [4, 4], 2),
      LinearSales(5, 90, [8, 3, 2, 3], 2),
      LinearSales(6, 75, [8, 3, 2, 3], 2),
    ];

    // Series of data with changing color and stroke width.
    final strokeWidthChangeData = [
      LinearSales(0, 5, null, 2),
      LinearSales(1, 15, null, 2),
      LinearSales(2, 25, null, 4),
      LinearSales(3, 75, null, 4),
      LinearSales(4, 100, null, 4),
      LinearSales(5, 90, null, 6),
      LinearSales(6, 75, null, 6),
    ];

    // Generate 2 shades of each color so that we can style the line segments.
    final blue = charts.MaterialPalette.blue.makeShades(2);
    final red = charts.MaterialPalette.red.makeShades(2);
    final green = charts.MaterialPalette.green.makeShades(2);

    return [
      charts.Series<LinearSales, int>(
        id: 'Color Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? blue[1] : blue[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: colorChangeData,
      ),
      charts.Series<LinearSales, int>(
        id: 'Dash Pattern Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? red[1] : red[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: dashPatternChangeData,
      ),
      charts.Series<LinearSales, int>(
        id: 'Stroke Width Change',
        // Light shade for even years, dark shade for odd.
        colorFn: (sales, _) => sales.year.isEven ? green[1] : green[0],
        dashPatternFn: (sales, _) => sales.dashPattern,
        strokeWidthPxFn: (sales, _) => sales.strokeWidthPx,
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: strokeWidthChangeData,
      ),
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  LinearSales(this.year, this.sales, this.dashPattern, this.strokeWidthPx);
  final int year;
  final int sales;
  final List<int>? dashPattern;
  final double strokeWidthPx;
}
