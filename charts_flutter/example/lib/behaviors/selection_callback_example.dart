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

// ignore_for_file: lines_longer_than_80_chars

/// Timeseries chart with example of updating external state based on selection.
///
/// A SelectionModelConfig can be provided for each of the different
/// [charts.SelectionModel] (currently info and action).
///
/// [charts.SelectionModelType.info] is the default selection chart exploration type
/// initiated by some tap event. This is a different model from
/// [charts.SelectionModelType.action] which is typically used to select some value as
/// an input to some other UI component. This allows dual state of exploring
/// and selecting data via different touch events.
///
/// See [charts.SelectNearest] behavior on setting the different ways of triggering
/// [charts.SelectionModel] updates from hover & click events.
library;

// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';

import 'package:flutter/material.dart';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:nimble_charts/flutter.dart' as charts;

class SelectionCallbackExample extends StatefulWidget {
  const SelectionCallbackExample(
    this.seriesList, {
    super.key,
    this.animate = true,
  });

  /// Creates a [charts.TimeSeriesChart] with sample data and no transition.
  factory SelectionCallbackExample.withSampleData() => SelectionCallbackExample(
        _createSampleData(),
      );

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SelectionCallbackExample.withRandomData() =>
      SelectionCallbackExample(_createRandomData());
  final List<charts.Series<TimeSeriesSales, DateTime>> seriesList;
  final bool animate;

  /// Create random data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createRandomData() {
    final random = Random();

    final usData = [
      TimeSeriesSales(DateTime(2017, 9, 19), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 9, 26), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 10, 3), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 10, 10), random.nextInt(100)),
    ];

    final ukData = [
      TimeSeriesSales(DateTime(2017, 9, 19), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 9, 26), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 10, 3), random.nextInt(100)),
      TimeSeriesSales(DateTime(2017, 10, 10), random.nextInt(100)),
    ];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'US Sales',
        domainFn: (sales, _) => sales.time,
        measureFn: (sales, _) => sales.sales,
        data: usData,
      ),
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'UK Sales',
        domainFn: (sales, _) => sales.time,
        measureFn: (sales, _) => sales.sales,
        data: ukData,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => _SelectionCallbackState();

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final usData = [
      TimeSeriesSales(DateTime(2017, 9, 19), 5),
      TimeSeriesSales(DateTime(2017, 9, 26), 25),
      TimeSeriesSales(DateTime(2017, 10, 3), 78),
      TimeSeriesSales(DateTime(2017, 10, 10), 54),
    ];

    final ukData = [
      TimeSeriesSales(DateTime(2017, 9, 19), 15),
      TimeSeriesSales(DateTime(2017, 9, 26), 33),
      TimeSeriesSales(DateTime(2017, 10, 3), 68),
      TimeSeriesSales(DateTime(2017, 10, 10), 48),
    ];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'US Sales',
        domainFn: (sales, _) => sales.time,
        measureFn: (sales, _) => sales.sales,
        data: usData,
      ),
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'UK Sales',
        domainFn: (sales, _) => sales.time,
        measureFn: (sales, _) => sales.sales,
        data: ukData,
      ),
    ];
  }
}

class _SelectionCallbackState extends State<SelectionCallbackExample> {
  DateTime? _time;
  Map<String, num> _measures = {};

  // Listens to the underlying selection changes, and updates the information
  // relevant to building the primitive legend like information under the
  // chart.
  void _onSelectionChanged(charts.SelectionModel<DateTime> model) {
    final selectedDatum = model.selectedDatum;

    DateTime? time;
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      if (selectedDatum.first.datum is TimeSeriesSales) {
        final firstDatum = selectedDatum.first.datum as TimeSeriesSales;
        time = firstDatum.time;
        for (final datumPair in selectedDatum) {
          if (datumPair.datum is TimeSeriesSales) {
            final typedDatum = datumPair.datum as TimeSeriesSales;
            measures[datumPair.series.displayName!] = typedDatum.sales;
          }
        }
      }
    }

    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The children consist of a Chart and Text widgets below to hold the info.
    final children = <Widget>[
      SizedBox(
        height: 150,
        child: charts.TimeSeriesChart(
          widget.seriesList,
          animate: widget.animate,
          selectionModels: [
            charts.SelectionModelConfig(
              changedListener: _onSelectionChanged,
            ),
          ],
        ),
      ),
    ];

    // If there is a selection, then include the details.
    if (_time != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(_time.toString()),
        ),
      );
    }
    _measures.forEach((series, value) {
      children.add(Text('$series: $value'));
    });

    return Column(children: children);
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  TimeSeriesSales(this.time, this.sales);
  final DateTime time;
  final int sales;
}
