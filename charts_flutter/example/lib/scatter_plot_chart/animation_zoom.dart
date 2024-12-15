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

/// Example of a line chart with pan and zoom enabled via
/// [charts.PanAndZoomBehavior].
library;

// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';

import 'package:flutter/material.dart';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:nimble_charts/flutter.dart' as charts;

class ScatterPlotAnimationZoomChart extends StatelessWidget {
  const ScatterPlotAnimationZoomChart(
    this.seriesList, {
    super.key,
    this.animate = true,
  });

  /// Creates a [charts.ScatterPlotChart] with sample data and no transition.
  factory ScatterPlotAnimationZoomChart.withSampleData() =>
      ScatterPlotAnimationZoomChart(
        _createSampleData(),
      );

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory ScatterPlotAnimationZoomChart.withRandomData() =>
      ScatterPlotAnimationZoomChart(_createRandomData());
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  /// Create random data.
  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    final data = <LinearSales>[];

    double makeRadius(int value) => (random.nextInt(value) + 2).toDouble();

    for (var i = 0; i < 100; i++) {
      data.add(LinearSales(i, random.nextInt(100), makeRadius(4)));
    }

    const maxMeasure = 100;

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (sales, _) {
          // Color bucket the measure column value into 3 distinct colors.
          final bucket = sales.sales / maxMeasure;

          if (bucket < 1 / 3) {
            return charts.MaterialPalette.blue.shadeDefault;
          } else if (bucket < 2 / 3) {
            return charts.MaterialPalette.red.shadeDefault;
          } else {
            return charts.MaterialPalette.green.shadeDefault;
          }
        },
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        radiusPxFn: (sales, _) => sales.radius,
        data: data,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) => charts.ScatterPlotChart(
        seriesList,
        animate: animate,
        behaviors: [
          charts.PanAndZoomBehavior(),
        ],
      );

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      LinearSales(0, 5, 3),
      LinearSales(10, 25, 5),
      LinearSales(12, 75, 4),
      LinearSales(13, 225, 5),
      LinearSales(16, 50, 4),
      LinearSales(24, 75, 3),
      LinearSales(25, 100, 3),
      LinearSales(34, 150, 5),
      LinearSales(37, 10, 4.5),
      LinearSales(45, 300, 8),
      LinearSales(52, 15, 4),
      LinearSales(56, 200, 7),
    ];

    const maxMeasure = 300;

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (sales, _) {
          // Color bucket the measure column value into 3 distinct colors.
          final bucket = sales.sales / maxMeasure;

          if (bucket < 1 / 3) {
            return charts.MaterialPalette.blue.shadeDefault;
          } else if (bucket < 2 / 3) {
            return charts.MaterialPalette.red.shadeDefault;
          } else {
            return charts.MaterialPalette.green.shadeDefault;
          }
        },
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        radiusPxFn: (sales, _) => sales.radius,
        data: data,
      ),
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  LinearSales(this.year, this.sales, this.radius);
  final int year;
  final int sales;
  final double radius;
}
