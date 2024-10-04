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

@Tags(['skip-file'])
library;

import 'package:test/test.dart';
/*

import 'dart:math';

import 'package:nimble_charts_common/src/chart/common/base_chart.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/initial_selection.dart';
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart';
import 'package:nimble_charts_common/src/chart/common/datum_details.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart';
import 'package:nimble_charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:nimble_charts_common/src/chart/common/series_datum.dart';
import 'package:nimble_charts_common/src/chart/common/series_renderer.dart';
import 'package:nimble_charts_common/src/data/series.dart';
import 'package:test/test.dart';

class FakeRenderer<D> extends BaseSeriesRenderer<D> {
  FakeRenderer() : super(rendererId: 'fake', layoutPaintOrder: 0);

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
      DatumDetails<D> details, SeriesDatum<D> seriesDatum,) => null;

  @override
  List<DatumDetails<D>> getNearestDatumDetailPerSeries(
    Point<double> chartPoint,
    bool byDomain,
    Rectangle<int> boundsOverride, {
    bool selectOverlappingPoints = false,
    bool selectExactEventLocation = false,
  }) =>
      null;

  @override
  void paint(ChartCanvas canvas, double animationPercent) {}

  @override
  void update(List<ImmutableSeries> seriesList, bool isAnimating) {}
}

class FakeChart extends BaseChart {
  @override
  List<DatumDetails> getDatumDetails(SelectionModelType type) => [];

  @override
  SeriesRenderer makeDefaultRenderer() => FakeRenderer();

  void requestOnDraw(List<MutableSeries> seriesList) {
    fireOnDraw(seriesList);
  }
}

void main() {
  FakeChart chart;
  MutableSeries series1;
  MutableSeries series2;
  MutableSeries series3;
  MutableSeries series4;
  const infoSelectionType = SelectionModelType.info;

  InitialSelection makeBehavior(SelectionModelType selectionModelType,
      {List<String> selectedSeries, List<SeriesDatumConfig> selectedData,}) {
    final var behavior = InitialSelection(
        selectionModelType: selectionModelType,
        selectedSeriesConfig: selectedSeries,
        selectedDataConfig: selectedData,);

    behavior.attachTo(chart);

    return behavior;
  }

  setUp(() {
    chart = FakeChart();

    series1 = MutableSeries(Series(
        id: 'mySeries1',
        data: ['A', 'B', 'C', 'D'],
        domainFn: (datum, __) => datum,
        measureFn: (_, __) => null,),);

    series2 = MutableSeries(Series(
        id: 'mySeries2',
        data: ['W', 'X', 'Y', 'Z'],
        domainFn: (datum, __) => datum,
        measureFn: (_, __) => null,),);

    series3 = MutableSeries(Series(
        id: 'mySeries3',
        data: ['W', 'X', 'Y', 'Z'],
        domainFn: (datum, __) => datum,
        measureFn: (_, __) => null,),);

    series4 = MutableSeries(Series(
        id: 'mySeries4',
        data: ['W', 'X', 'Y', 'Z'],
        domainFn: (datum, __) => datum,
        measureFn: (_, __) => null,),);
  });

  test('selects initial datum', () {
    makeBehavior(infoSelectionType,
        selectedData: [SeriesDatumConfig('mySeries1', 'C')],);

    chart.requestOnDraw([series1, series2]);

    final model = chart.getSelectionModel(infoSelectionType);

    expect(model.selectedSeries, hasLength(1));
    expect(model.selectedSeries[0], equals(series1));
    expect(model.selectedDatum, hasLength(1));
    expect(model.selectedDatum[0].series, equals(series1));
    expect(model.selectedDatum[0].datum, equals('C'));
  });

  test('selects multiple initial data', () {
    makeBehavior(infoSelectionType, selectedData: [
      SeriesDatumConfig('mySeries1', 'C'),
      SeriesDatumConfig('mySeries1', 'D'),
    ],);

    chart.requestOnDraw([series1, series2]);

    final model = chart.getSelectionModel(infoSelectionType);

    expect(model.selectedSeries, hasLength(1));
    expect(model.selectedSeries[0], equals(series1));
    expect(model.selectedDatum, hasLength(2));
    expect(model.selectedDatum[0].series, equals(series1));
    expect(model.selectedDatum[0].datum, equals('C'));
    expect(model.selectedDatum[1].series, equals(series1));
    expect(model.selectedDatum[1].datum, equals('D'));
  });

  test('selects initial series', () {
    makeBehavior(infoSelectionType, selectedSeries: ['mySeries2']);

    chart.requestOnDraw([series1, series2, series3, series4]);

    final model = chart.getSelectionModel(infoSelectionType);

    expect(model.selectedSeries, hasLength(1));
    expect(model.selectedSeries[0], equals(series2));
    expect(model.selectedDatum, isEmpty);
  });

  test('selects multiple series', () {
    makeBehavior(infoSelectionType,
        selectedSeries: ['mySeries2', 'mySeries4'],);

    chart.requestOnDraw([series1, series2, series3, series4]);

    final model = chart.getSelectionModel(infoSelectionType);

    expect(model.selectedSeries, hasLength(2));
    expect(model.selectedSeries[0], equals(series2));
    expect(model.selectedSeries[1], equals(series4));
    expect(model.selectedDatum, isEmpty);
  });

  test('selects series and datum', () {
    makeBehavior(infoSelectionType,
        selectedData: [SeriesDatumConfig('mySeries1', 'C')],
        selectedSeries: ['mySeries4'],);

    chart.requestOnDraw([series1, series2, series3, series4]);

    final model = chart.getSelectionModel(infoSelectionType);

    expect(model.selectedSeries, hasLength(2));
    expect(model.selectedSeries[0], equals(series1));
    expect(model.selectedSeries[1], equals(series4));
    expect(model.selectedDatum[0].series, equals(series1));
    expect(model.selectedDatum[0].datum, equals('C'));
  });

  test('selection model is reset when a new series is drawn', () {
    makeBehavior(infoSelectionType, selectedSeries: ['mySeries2']);

    chart.requestOnDraw([series1, series2, series3, series4]);

    final model = chart.getSelectionModel(infoSelectionType);

    // Verify initial selection is selected on first draw
    expect(model.selectedSeries, hasLength(1));
    expect(model.selectedSeries[0], equals(series2));
    expect(model.selectedDatum, isEmpty);

    // Request a draw with a new series list.
    chart.draw(
      [
        Series(
            id: 'mySeries2',
            data: ['W', 'X', 'Y', 'Z'],
            domainFn: (datum, __) => datum,
            measureFn: (_, __) => null,),
      ],
    );

    // Verify selection is cleared.
    expect(model.selectedSeries, isEmpty);
    expect(model.selectedDatum, isEmpty);
  });
}

*/
