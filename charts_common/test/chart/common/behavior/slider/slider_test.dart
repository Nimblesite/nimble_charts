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

@Tags(['skip-file'])
library;

import 'package:test/test.dart';
/*

import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:nimble_charts_common/src/chart/cartesian/cartesian_chart.dart';
import 'package:nimble_charts_common/src/chart/common/base_chart.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/selection/selection_trigger.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/slider/slider.dart';
import 'package:nimble_charts_common/src/chart/common/datum_details.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart';
import 'package:nimble_charts_common/src/common/gesture_listener.dart';
import 'package:nimble_charts_common/src/common/math.dart';
import 'package:nimble_charts_common/src/data/series.dart';
import 'package:test/test.dart';

class MockChart extends Mock implements CartesianChart {
  GestureListener lastGestureListener;

  LifecycleListener lastLifecycleListener;

  @override
  bool vertical = true;

  @override
  GestureListener addGestureListener(GestureListener listener) {
    lastGestureListener = listener;
    return listener;
  }

  @override
  void removeGestureListener(GestureListener listener) {
    expect(listener, equals(lastGestureListener));
    lastGestureListener = null;
  }

  @override
  LifecycleListener addLifecycleListener(LifecycleListener listener) =>
      lastLifecycleListener = listener;

  @override
  bool removeLifecycleListener(LifecycleListener listener) {
    expect(listener, equals(lastLifecycleListener));
    lastLifecycleListener = null;
    return true;
  }
}

class MockDomainAxis extends Mock implements NumericAxis {
  @override
  double getDomain(num location) => location / 20.0;

  @override
  double getLocation(num domain) => domain * 20.0;
}

void main() {
  MockChart chart;
  MockDomainAxis domainAxis;
  MockDomainAxis measureAxis;
  ImmutableSeries series1;
  DatumDetails details1;
  DatumDetails details2;
  DatumDetails details3;

  SliderTester tester;

  Slider makeBehavior(SelectionTrigger eventTrigger,
      {Point<double> handleOffset,
      Rectangle<int> handleSize,
      double initialDomainValue,
      SliderListenerCallback onChangeCallback,
      bool snapToDatum = false,
      SliderHandlePosition handlePosition = SliderHandlePosition.middle,}) {
    final var behavior = Slider(
        eventTrigger: eventTrigger,
        initialDomainValue: initialDomainValue,
        onChangeCallback: onChangeCallback,
        snapToDatum: snapToDatum,
        style: SliderStyle(
            handleOffset: handleOffset, handlePosition: handlePosition,),);

    behavior.attachTo(chart);

    tester = SliderTester(behavior);

    // Mock out chart layout by assigning bounds to the layout view.
    tester.layout(
        const Rectangle<int>(0, 0, 200, 200), const Rectangle<int>(0, 0, 200, 200),);

    return behavior;
  }

  void setupChart(
      {Point<double> forPoint,
      bool isWithinRenderer,
      List<DatumDetails> respondWithDetails,}) {
    when(chart.domainAxis).thenReturn(domainAxis);
    when(chart.getMeasureAxis()).thenReturn(measureAxis);

    when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
      when(chart.getNearestDatumDetailPerSeries(forPoint, true))
        .thenReturn(respondWithDetails);
    }

  setUp(() {
    chart = MockChart();

    domainAxis = MockDomainAxis();

    measureAxis = MockDomainAxis();

    series1 = MutableSeries(Series(
        id: 'mySeries1',
        data: [],
        domainFn: (_, __) {},
        measureFn: (_, __) => null,),);

    details1 = DatumDetails(
        chartPosition: const NullablePoint(20, 80),
        datum: 'myDatum1',
        domain: 1.0,
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);
    details2 = DatumDetails(
        chartPosition: const NullablePoint(40, 80),
        datum: 'myDatum2',
        domain: 2.0,
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);
    details3 = DatumDetails(
        chartPosition: const NullablePoint(90, 80),
        datum: 'myDatum3',
        domain: 4.5,
        series: series1,
        domainDistance: 10,
        measureDistance: 20,);
  });

  group('Slider trigger handling', () {
    test('can listen to tap and drag', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),);

      const startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const updatePoint1 = Point<double>(50, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const var updatePoint2 = Point<double>(100, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const endPoint = Point<double>(120, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);
      chart.lastGestureListener.onTap(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint1, 1);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint2, 1);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));
    });

    test('slider handle can render at top', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),
          handlePosition: SliderHandlePosition.top,);

      const startPoint = Point<double>(100, 0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const updatePoint1 = Point<double>(50, 0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const updatePoint2 = Point<double>(100, 0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const var endPoint = Point<double>(120, 0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);
      chart.lastGestureListener.onTap(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, -10, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint1, 1);
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(45, -10, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint2, 1);
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, -10, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, -10, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, -10, 10, 20)));
    });

    test('can listen to press hold', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.pressHold,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),);

      const var startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const updatePoint1 = Point<double>(50, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const var updatePoint2 = Point<double>(100, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const var endPoint = Point<double>(120, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);
      chart.lastGestureListener.onLongPress(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint1, 1);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint2, 1);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));
    });

    test('can listen to long press hold', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.longPressHold,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),);

      const startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const updatePoint1 = Point<double>(50, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const updatePoint2 = Point<double>(100, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const endPoint = Point<double>(120, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);
      chart.lastGestureListener.onLongPress(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint1, 1);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint2, 1);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));
    });

    test('no position update before long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.longPressHold,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),);

      const var startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const var updatePoint1 = Point<double>(50, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const var updatePoint2 = Point<double>(100, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const var endPoint = Point<double>(120, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));
    });

    test('can snap to datum', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),
          snapToDatum: true,);

      const var startPoint = Point<double>(100, 100);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1],);

      const var updatePoint1 = Point<double>(50, 100);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2],);

      const updatePoint2 = Point<double>(100, 100);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      const endPoint = Point<double>(120, 100);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],);

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      chart.lastGestureListener.onTapTest(startPoint);
      chart.lastGestureListener.onTap(startPoint);

      // Start the drag.
      chart.lastGestureListener.onDragStart(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point. The slider should follow the mouse during
      // each drag update.
      chart.lastGestureListener.onDragUpdate(updatePoint1, 1);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener.onDragUpdate(updatePoint2, 1);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener.onDragUpdate(endPoint, 1);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd. This is where we expect the snap to occur.
      chart.lastGestureListener.onDragEnd(endPoint, 1, 1);

      expect(tester.domainCenterPoint, equals(const Point<int>(90, 100)));
      expect(tester.domainValue, equals(4.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(85, 90, 10, 20)));
    });
  });

  group('Slider manual control', () {
    test('can set domain position', () {
      // Setup chart matches point with single domain single series.
      final slider = makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),
          initialDomainValue: 1,);

      setupChart();

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      // Verify initial position.
      expect(tester.domainCenterPoint, equals(const Point(20, 100)));
      expect(tester.domainValue, equals(1.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(15, 90, 10, 20)));

      // Move to first domain value.
      slider.moveSliderToDomain(2);
      expect(tester.domainCenterPoint, equals(const Point(40, 100)));
      expect(tester.domainValue, equals(2.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(35, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(5);
      expect(tester.domainCenterPoint, equals(const Point(100, 100)));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(7.5);
      expect(tester.domainCenterPoint, equals(const Point(150, 100)));
      expect(tester.domainValue, equals(7.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(145, 90, 10, 20)));
    });

    test('can set domain and measure position when handle position is manual',
        () {
      // Setup chart matches point with single domain single series.
      final slider = makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: const Point<double>(0, 0),
          handleSize: const Rectangle<int>(0, 0, 10, 20),
          initialDomainValue: 1,
          handlePosition: SliderHandlePosition.manual,);

      setupChart();

      // Act
      chart.lastLifecycleListener.onAxisConfigured();

      // Verify initial position.
      expect(tester.domainCenterPoint, equals(const Point(20, 100)));
      expect(tester.domainValue, equals(1.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(15, 190, 10, 20)));

      // Move to first domain value.
      slider.moveSliderToDomain(2, measure: 5);
      expect(tester.domainCenterPoint, equals(const Point(40, 100)));
      expect(tester.domainValue, equals(2.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(35, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(5, measure: 7);
      expect(tester.domainCenterPoint, equals(const Point(100, 100)));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(const Rectangle<int>(95, 130, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(7.5, measure: 3);
      expect(tester.domainCenterPoint, equals(const Point(150, 100)));
      expect(tester.domainValue, equals(7.5));
      expect(tester.handleBounds, equals(const Rectangle<int>(145, 50, 10, 20)));
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      final behavior = makeBehavior(SelectionTrigger.tapAndDrag);

      const point = Point<double>(100, 100);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details1],);
      expect(chart.lastGestureListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(chart.lastGestureListener, isNull);
    });
  });
}

*/
