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

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/common/base_chart.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/selection/select_nearest.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/selection/selection_trigger.dart';
import 'package:nimble_charts_common/src/chart/common/datum_details.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart';
import 'package:nimble_charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:nimble_charts_common/src/chart/common/series_datum.dart';
import 'package:nimble_charts_common/src/common/gesture_listener.dart';
import 'package:nimble_charts_common/src/data/series.dart';
import 'package:test/test.dart';

class MockChart extends Mock implements BaseChart<String> {
  GestureListener lastListener;

  @override
  GestureListener addGestureListener(GestureListener listener) {
    lastListener = listener;
    return listener;
  }

  @override
  void removeGestureListener(GestureListener listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
  }
}

class MockSelectionModel extends Mock
    implements MutableSelectionModel<String> {}

void main() {
  MockChart chart;
  MockSelectionModel hoverSelectionModel;
  MockSelectionModel clickSelectionModel;
  List<String> series1Data;
  List<String> series2Data;
  MutableSeries<String> series1;
  MutableSeries<String> series2;
  DatumDetails<String> details10;
  DatumDetails<String> details1Series2;
  DatumDetails<String> details20;
  DatumDetails<String> details3;

  SelectNearest<String> makeBehavior(
      SelectionModelType selectionModelType, SelectionTrigger eventTrigger,
      {bool selectClosestSeries,
      SelectionMode selectionMode = SelectionMode.expandToDomain,
      int maximumDomainDistancePx,}) {
    final var behavior = SelectNearest<String>(
        selectionModelType: selectionModelType,
        selectionMode: selectionMode,
        selectClosestSeries: selectClosestSeries,
        eventTrigger: eventTrigger,
        maximumDomainDistancePx: maximumDomainDistancePx,);

    behavior.attachTo(chart);

    return behavior;
  }

  void setupChart(
      {Point<double> forPoint,
      bool isWithinRenderer,
      List<DatumDetails<String>> respondWithDetails,
      List<MutableSeries<String>> seriesList,}) {
    when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
      when(chart.getNearestDatumDetailPerSeries(forPoint, true))
        .thenReturn(respondWithDetails);
      when(chart.currentSeriesList).thenReturn(seriesList);
    }

  setUp(() {
    hoverSelectionModel = MockSelectionModel();
    clickSelectionModel = MockSelectionModel();

    chart = MockChart();
    when(chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(hoverSelectionModel);
    when(chart.getSelectionModel(SelectionModelType.action))
        .thenReturn(clickSelectionModel);

    series1Data = ['myDomain1', 'myDomain2', 'myDomain3'];

    series1 = MutableSeries<String>(Series(
        id: 'mySeries1',
        data: ['myDatum1', 'myDatum2', 'myDatum3'],
        domainFn: (_, i) => series1Data[i],
        measureFn: (_, __) => null,),);

    details10 = DatumDetails(
        datum: 'myDatum1',
        domain: 'myDomain1',
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);
    details20 = DatumDetails(
        datum: 'myDatum2',
        domain: 'myDomain2',
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);
    details3 = DatumDetails(
        datum: 'myDatum3',
        domain: 'myDomain3',
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);

    series2Data = ['myDomain1'];

    series2 = MutableSeries<String>(Series(
        id: 'mySeries2',
        data: ['myDatum1s2'],
        domainFn: (_, i) => series2Data[i],
        measureFn: (_, __) => null,),);

    details1Series2 = DatumDetails(
        datum: 'myDatum1s2',
        domain: 'myDomain1',
        series: series2,
        domainDistance: 10,
        measureDistance: 20,);
  });

  tearDown(resetMockitoState);

  group('SelectNearest trigger handling', () {
    test('single series selects detail', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true,);
      const var point = Point<double>(100, 100);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1],),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
      // Shouldn't be listening to anything else.
      expect(chart.lastListener.onTap, isNull);
      expect(chart.lastListener.onDragStart, isNull);
    });

    test('can listen to tap', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.action, SelectionTrigger.tap,
          selectClosestSeries: true,);
      const point = Point<double>(100, 100);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      // Act
      chart.lastListener.onTapTest(point);
      chart.lastListener.onTap(point);

      // Validate
      verify(clickSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1],),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can listen to drag', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.pressHold,
          selectClosestSeries: true,);

      const var startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      const var updatePoint1 = Point<double>(200, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      const updatePoint2 = Point<double>(300, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1],);

      const var endPoint = Point<double>(400, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1],);

      // Act
      chart.lastListener.onTapTest(startPoint);
      chart.lastListener.onDragStart(startPoint);
      chart.lastListener.onDragUpdate(updatePoint1, 1);
      chart.lastListener.onDragUpdate(updatePoint2, 1);
      chart.lastListener.onDragEnd(endPoint, 1, 0);

      // Validate
      // details1 was tripped 2 times (startPoint & updatePoint1)
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1],),).called(2);
      // details2 was tripped for updatePoint2
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details20.datum)], [series1],),);
      // dragEnd deselects even though we are over details3.
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can listen to drag after long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.longPressHold,
          selectClosestSeries: true,);

      const startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      const var updatePoint1 = Point<double>(200, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1],);

      const var endPoint = Point<double>(400, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1],);

      // Act 1
      chart.lastListener.onTapTest(startPoint);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);

      // Act 2
      // verify no interaction yet.
      chart.lastListener.onLongPress(startPoint);
      chart.lastListener.onDragStart(startPoint);
      chart.lastListener.onDragUpdate(updatePoint1, 1);
      chart.lastListener.onDragEnd(endPoint, 1, 0);

      // Validate
      // details1 was tripped 2 times (longPress & dragStart)
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1],),).called(2);
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details20.datum)], [series1],),);
      // dragEnd deselects even though we are over details3.
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('no trigger before long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.longPressHold,
          selectClosestSeries: true,);

      const startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);

      const updatePoint1 = Point<double>(200, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1],);

      const endPoint = Point<double>(400, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1],);

      // Act
      chart.lastListener.onTapTest(startPoint);
      chart.lastListener.onDragStart(startPoint);
      chart.lastListener.onDragUpdate(updatePoint1, 1);
      chart.lastListener.onDragEnd(endPoint, 1, 0);

      // Validate
      // No interaction, didn't long press first.
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Details', () {
    test('expands to domain and includes closest series', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true,);
      const var point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
        SeriesDatum(series2, details1Series2.datum),
      ], [
        series1,
      ]),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not expand to domain', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectionMode: SelectionMode.single, selectClosestSeries: true,);
      const var point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1],),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not include closest series', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: false,);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
        SeriesDatum(series2, details1Series2.datum),
      ], [],),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not include overlay series', () {
      // Setup chart with an overlay series.
      series2.overlaySeries = true;

      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true,);
      const var point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
      ], [
        series1,
      ]),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('selection does not exceed maximumDomainDistancePx', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true, maximumDomainDistancePx: 1,);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('adds overlapping points from same series if there are any', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectionMode: SelectionMode.selectOverlapping,
          selectClosestSeries: true,);
      const point = Point<double>(100, 100);
      final series = MutableSeries<String>(Series(
          id: 'overlappingSeries',
          data: ['datum1', 'datum2'],
          domainFn: (_, i) => series1Data[i],
          measureFn: (_, __) => null,),);
      // Two points covering the mouse position.
      final details1 = DatumDetails(
          datum: 'datum1',
          domain: 'myDomain1',
          series: series,
          radiusPx: 10,
          domainDistance: 4,
          relativeDistance: 5,);
      final details2 = DatumDetails(
          datum: 'datum2',
          domain: 'myDomain1',
          series: series,
          radiusPx: 10,
          domainDistance: 7,
          relativeDistance: 9,);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details1,
        details2,
      ], seriesList: [
        series,
      ],);

      // Act
      chart.lastListener.onHover(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series, details1.datum),
        SeriesDatum(series, details2.datum),
      ], [
        series,
      ]),);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      final SelectNearest behavior = makeBehavior(
          SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true,);
      const point = Point<double>(100, 100);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1],);
      expect(chart.lastListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(chart.lastListener, isNull);
    });
  });
}

*/
