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
// EXCLUDE_FROM_GALLERY_DOCS_START
// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nimble_charts/flutter.dart' as charts;

/// This is just a simple line chart with a behavior that adds slider controls.
///
/// A Slider behavior is added manually to enable slider controls, with an
/// initial position at 1 along the domain axis.
///
/// An onChange event handler has been configured to demonstrate updating a div
/// with data from the slider's current position. An "initial" drag state event
/// will be fired when the chart is drawn because an initial domain value is
/// set.
///
/// [charts.Slider.moveSliderToDomain] can be called to programmatically position the
/// slider. This is useful for synchronizing the slider with external elements.
class SliderLine extends StatefulWidget {
  const SliderLine(this.seriesList, {super.key, this.animate = true});

  /// Creates a [LineChart] with sample data and no transition.
  factory SliderLine.withSampleData() => SliderLine(
        _createSampleData(),
      );

  factory SliderLine.withRandomData() => SliderLine(_createRandomData());
  final List<charts.Series<LinearSales, int>> seriesList;
  final bool animate;

  @override
  State<StatefulWidget> createState() => _SliderCallbackState();

  /// Create random data.
  static List<charts.Series<LinearSales, int>> _createRandomData() {
    final random = Random();

    final data = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, random.nextInt(100)),
      LinearSales(3, random.nextInt(100)),
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: data,
      ),
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      LinearSales(0, 5),
      LinearSales(1, 25),
      LinearSales(2, 100),
      LinearSales(3, 75),
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (sales, _) => sales.year,
        measureFn: (sales, _) => sales.sales,
        data: data,
      ),
    ];
  }
}

class _SliderCallbackState extends State<SliderLine> {
  num? _sliderDomainValue;
  String? _sliderDragState;
  Point<int>? _sliderPosition;

  void _onSliderChange<T extends num>(
    Point<int> point,
    T? domain,
    String roleId,
    charts.SliderListenerDragState dragState,
  ) {
    void rebuild(_) {
      setState(() {
        _sliderDomainValue = domain;
        _sliderDragState = dragState.toString();
        _sliderPosition = point;
      });
    }

    SchedulerBinding.instance.addPostFrameCallback(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(
        height: 150,
        child: charts.LineChart(
          widget.seriesList,
          animate: widget.animate,
          behaviors: [
            charts.Slider<int>(
              initialDomainValue: 1,
              onChangeCallback: _onSliderChange<int>,
            ),
          ],
        ),
      ),
    ];

    if (_sliderDomainValue != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('Slider domain value: $_sliderDomainValue'),
        ),
      );
    }
    if (_sliderPosition != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'Slider position: ${_sliderPosition!.x}, ${_sliderPosition!.y}',
          ),
        ),
      );
    }
    if (_sliderDragState != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('Slider drag state: $_sliderDragState'),
        ),
      );
    }

    return Column(children: children);
  }
}

/// Sample linear data type.
class LinearSales {
  LinearSales(this.year, this.sales);
  final int year;
  final int sales;
}
