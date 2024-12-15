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

/// Bar chart with default hidden series legend example
library;

// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;

/// A bar chart example demonstrating a series legend with a default hidden
/// series.
///
/// The chart displays multiple series of data with a legend, where one series
/// is hidden by default when the chart is first rendered.
class DefaultHiddenSeriesLegend extends StatelessWidget {
  /// Creates a [DefaultHiddenSeriesLegend] with the given series list.
  ///
  /// [seriesList] The list of series to display in the chart.
  /// [animate] Determines whether the chart will animate when data changes.
  const DefaultHiddenSeriesLegend(
    this.seriesList, {
    super.key,
    this.animate = true,
  });

  /// Creates a [DefaultHiddenSeriesLegend] with sample data.
  ///
  /// Creates a bar chart with sample data that demonstrates the default hidden
  /// series behavior.
  factory DefaultHiddenSeriesLegend.withSampleData() =>
      DefaultHiddenSeriesLegend(
        _createSampleData(),
      );

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory DefaultHiddenSeriesLegend.withRandomData() =>
      DefaultHiddenSeriesLegend(_createRandomData());
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  /// Create random data.
  static List<charts.Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();

    final desktopSalesData = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];

    final tabletSalesData = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];

    final mobileSalesData = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];

    final otherSalesData = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: tabletSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: mobileSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Other',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: otherSalesData,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) => charts.BarChart(
        seriesList,
        animate: animate,
        barGroupingType: charts.BarGroupingType.grouped,
        // Add the series legend behavior to the chart to turn on series
        // legends. By default the legend will display above the chart.
        behaviors: [
          charts.SeriesLegend(
            // Configures the "Other" series to be hidden on first chart draw.
            defaultHiddenSeries: const ['Other'],
          ),
        ],
      );

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      OrdinalSales('2014', 5),
      OrdinalSales('2015', 25),
      OrdinalSales('2016', 100),
      OrdinalSales('2017', 75),
    ];

    final tabletSalesData = [
      OrdinalSales('2014', 25),
      OrdinalSales('2015', 50),
      OrdinalSales('2016', 10),
      OrdinalSales('2017', 20),
    ];

    final mobileSalesData = [
      OrdinalSales('2014', 10),
      OrdinalSales('2015', 15),
      OrdinalSales('2016', 50),
      OrdinalSales('2017', 45),
    ];

    final otherSalesData = [
      OrdinalSales('2014', 20),
      OrdinalSales('2015', 35),
      OrdinalSales('2016', 15),
      OrdinalSales('2017', 10),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: tabletSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: mobileSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Other',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: otherSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type representing sales data for a given year.
///
/// This class is used to represent a single data point in the chart,
/// containing a year and its corresponding sales value.
class OrdinalSales {
  /// Creates a new [OrdinalSales] data point.
  ///
  /// [year] The year for this sales data point.
  /// [sales] The sales amount for this data point.
  OrdinalSales(this.year, this.sales);

  /// The year of this sales data point.
  final String year;

  /// The sales amount for this data point.
  final int sales;
}
