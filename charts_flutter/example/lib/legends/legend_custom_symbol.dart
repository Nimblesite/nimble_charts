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

/// Bar chart with custom symbol in legend example.
library;

// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';

// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:nimble_charts/flutter.dart';
import 'package:nimble_charts_common/common.dart' as common;

/// Example custom renderer that renders [IconData].
///
/// This is used to show that legend symbols can be assigned a custom symbol.
class IconRenderer extends charts.CustomSymbolRenderer {
  IconRenderer(this.iconData);
  final IconData iconData;

  @override
  Widget build(
    BuildContext context, {
    required Size size,
    common.Color? color,
    bool enabled = true,
  }) {
    // Lighten the color if the symbol is not enabled
    // Example: If user has tapped on a Series deselecting it.
    var localColor = color;
    if (localColor != null && !enabled) {
      localColor = localColor.withAlpha(.26);
    }

    return SizedBox.fromSize(
      size: size,
      child: Icon(iconData, color: localColor?.toDartColor(), size: 12),
    );
  }
}

class LegendWithCustomSymbol extends StatelessWidget {
  const LegendWithCustomSymbol(
    this.seriesList, {
    super.key,
    this.animate = true,
  });

  factory LegendWithCustomSymbol.withSampleData() => LegendWithCustomSymbol(
        _createSampleData(),
      );

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory LegendWithCustomSymbol.withRandomData() =>
      LegendWithCustomSymbol(_createRandomData());
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
        // Add the legend behavior to the chart to turn on legends.
        // By default the legend will display above the chart.
        //
        // To change the symbol used in the legend, set the renderer attribute
        // of symbolRendererKey to a SymbolRenderer.
        behaviors: [charts.SeriesLegend()],
        defaultRenderer: charts.BarRendererConfig(
          symbolRenderer: IconRenderer(Icons.cloud),
        ),
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

/// Sample ordinal data type.
class OrdinalSales {
  OrdinalSales(this.year, this.sales);
  final String year;
  final int sales;
}
