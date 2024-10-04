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

import 'dart:math' show Rectangle;

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/collision_report.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/draw_strategy/tick_draw_strategy.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/numeric_tick_provider.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick.dart';
import 'package:nimble_charts_common/src/chart/common/base_chart.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/range_annotation.dart';
import 'package:nimble_charts_common/src/chart/common/chart_context.dart';
import 'package:nimble_charts_common/src/chart/line/line_chart.dart';
import 'package:nimble_charts_common/src/common/graphics_factory.dart';
import 'package:nimble_charts_common/src/common/material_palette.dart';
import 'package:nimble_charts_common/src/data/series.dart';
import 'package:test/test.dart';

class MockContext extends Mock implements ChartContext {}

class ConcreteChart extends LineChart {
  LifecycleListener<num> lastListener;

  final _domainAxis = ConcreteNumericAxis();

  final _primaryMeasureAxis = ConcreteNumericAxis();

  @override
  LifecycleListener<num> addLifecycleListener(LifecycleListener<num> listener) {
    lastListener = listener;
    return super.addLifecycleListener(listener);
  }

  @override
  bool removeLifecycleListener(LifecycleListener<num> listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
    return super.removeLifecycleListener(listener);
  }

  @override
  Axis<num> get domainAxis => _domainAxis;

  @override
  NumericAxis getMeasureAxis({String axisId}) => _primaryMeasureAxis;
}

class ConcreteNumericAxis extends NumericAxis {
  ConcreteNumericAxis()
      : super(
          tickProvider: MockTickProvider(),
        );
}

class MockTickProvider extends Mock implements NumericTickProvider {}

class MockGraphicsFactory extends Mock implements GraphicsFactory {}

class MockTickDrawStrategy extends Mock implements TickDrawStrategy<num> {}

void main() {
  Rectangle<int> drawBounds;
  Rectangle<int> domainAxisBounds;
  Rectangle<int> measureAxisBounds;

  ConcreteChart chart0;

  Series<MyRow, int> series1;
  final s1D1 = MyRow(0, 11);
  final s1D2 = MyRow(1, 12);
  final s1D3 = MyRow(2, 13);

  Series<MyRow, int> series2;
  final s2D1 = MyRow(3, 21);
  final s2D2 = MyRow(4, 22);
  final s2D3 = MyRow(5, 23);

  const dashPattern = <int>[2, 3];

  List<RangeAnnotationSegment<num>> annotations1;

  List<RangeAnnotationSegment<num>> annotations2;

  List<LineAnnotationSegment<num>> annotations3;

  ConcreteChart makeChart() {
    final chart = ConcreteChart();

    final context = MockContext();
    when(context.chartContainerIsRtl).thenReturn(false);
    when(context.isRtl).thenReturn(false);
    chart.context = context;

    return chart;
  }

  /// Initializes the [chart], draws the [seriesList], and configures mock axis
  /// layout bounds.
  void drawSeriesList(
    ConcreteChart chart,
    List<Series<MyRow, int>> seriesList,
  ) {
    final graphicsFactory = MockGraphicsFactory();
    final drawStrategy = MockTickDrawStrategy();
    final tickProvider = MockTickProvider();
    final ticks = <Tick<num>>[];
    when(
      tickProvider.getTicks(
        context: anyNamed('context'),
        graphicsFactory: anyNamed('graphicsFactory'),
        scale: anyNamed('scale'),
        formatter: anyNamed('formatter'),
        formatterValueCache: anyNamed('formatterValueCache'),
        tickDrawStrategy: anyNamed('tickDrawStrategy'),
        orientation: anyNamed('orientation'),
        viewportExtensionEnabled: anyNamed('viewportExtensionEnabled'),
      ),
    ).thenReturn(ticks);
    when(drawStrategy.collides(ticks, any)).thenReturn(
      CollisionReport<num>(
        ticks: [],
        ticksCollide: false,
        alternateTicksUsed: false,
      ),
    );

    chart0.domainAxis
      ..autoViewport = true
      ..graphicsFactory = graphicsFactory
      ..tickDrawStrategy = drawStrategy
      ..tickProvider = tickProvider
      ..resetDomains();

    chart0.getMeasureAxis()
      ..autoViewport = true
      ..graphicsFactory = graphicsFactory
      ..tickDrawStrategy = drawStrategy
      ..tickProvider = tickProvider
      ..resetDomains();

    chart0.draw(seriesList);

    chart0.domainAxis.layout(domainAxisBounds, drawBounds);

    chart0.getMeasureAxis().layout(measureAxisBounds, drawBounds);

    chart0.lastListener.onAxisConfigured();
  }

  setUpAll(() {
    drawBounds = const Rectangle<int>(0, 0, 100, 100);
    domainAxisBounds = const Rectangle<int>(0, 0, 100, 100);
    measureAxisBounds = const Rectangle<int>(0, 0, 100, 100);
  });

  setUp(() {
    chart0 = makeChart();

    series1 = Series<MyRow, int>(
      id: 's1',
      data: [s1D1, s1D2, s1D3],
      domainFn: (row, _) => row.campaign,
      measureFn: (row, _) => row.count,
      colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
    );

    series2 = Series<MyRow, int>(
      id: 's2',
      data: [s2D1, s2D2, s2D3],
      domainFn: (row, _) => row.campaign,
      measureFn: (row, _) => row.count,
      colorFn: (_, __) => MaterialPalette.red.shadeDefault,
    );

    annotations1 = [
      RangeAnnotationSegment(
        1,
        2,
        RangeAnnotationAxisType.domain,
        startLabel: 'Ann 1',
      ),
      RangeAnnotationSegment(
        4,
        5,
        RangeAnnotationAxisType.domain,
        color: MaterialPalette.gray.shade200,
        endLabel: 'Ann 2',
      ),
      RangeAnnotationSegment(
        5,
        5.5,
        RangeAnnotationAxisType.measure,
        startLabel: 'Really long tick start label',
        endLabel: 'Really long tick end label',
      ),
      RangeAnnotationSegment(
        10,
        15,
        RangeAnnotationAxisType.measure,
        startLabel: 'Ann 4 Start',
        endLabel: 'Ann 4 End',
      ),
      RangeAnnotationSegment(
        16,
        22,
        RangeAnnotationAxisType.measure,
        startLabel: 'Ann 5 Start',
        endLabel: 'Ann 5 End',
      ),
    ];

    annotations2 = [
      RangeAnnotationSegment(1, 2, RangeAnnotationAxisType.domain),
      RangeAnnotationSegment(
        4,
        5,
        RangeAnnotationAxisType.domain,
        color: MaterialPalette.gray.shade200,
      ),
      RangeAnnotationSegment(
        8,
        10,
        RangeAnnotationAxisType.domain,
        color: MaterialPalette.gray.shade300,
      ),
    ];

    annotations3 = [
      LineAnnotationSegment(
        1,
        RangeAnnotationAxisType.measure,
        startLabel: 'Ann 1 Start',
        endLabel: 'Ann 1 End',
      ),
      LineAnnotationSegment(
        4,
        RangeAnnotationAxisType.measure,
        startLabel: 'Ann 2 Start',
        endLabel: 'Ann 2 End',
        color: MaterialPalette.gray.shade200,
        dashPattern: dashPattern,
      ),
    ];
  });

  group('RangeAnnotation', () {
    test('renders the annotations', () {
      // Setup
      final behavior = RangeAnnotation<num>(annotations1);
      final tester = RangeAnnotationTester(behavior);
      behavior.attachTo(chart0);

      final seriesList = [series1, series2];

      // Act
      drawSeriesList(chart0, seriesList);

      // Verify
      expect(chart0.domainAxis.getLocation(2), equals(40.0));
      expect(
        tester.doesAnnotationExist(
          startPosition: 20.0,
          endPosition: 40.0,
          color: MaterialPalette.gray.shade100,
          startLabel: 'Ann 1',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.vertical,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 80.0,
          endPosition: 100.0,
          color: MaterialPalette.gray.shade200,
          endLabel: 'Ann 2',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.vertical,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );

      // Verify measure annotations
      expect(chart0.getMeasureAxis().getLocation(11).round(), equals(33));
      expect(
        tester.doesAnnotationExist(
          startPosition: 0.0,
          endPosition: 2.78,
          color: MaterialPalette.gray.shade100,
          startLabel: 'Really long tick start label',
          endLabel: 'Really long tick end label',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.horizontal,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 27.78,
          endPosition: 55.56,
          color: MaterialPalette.gray.shade100,
          startLabel: 'Ann 4 Start',
          endLabel: 'Ann 4 End',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.horizontal,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 61.11,
          endPosition: 94.44,
          color: MaterialPalette.gray.shade100,
          startLabel: 'Ann 5 Start',
          endLabel: 'Ann 5 End',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.horizontal,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
    });

    test('extends the domain axis when annotations fall outside the range', () {
      // Setup
      final behavior = RangeAnnotation<num>(annotations2);
      final tester = RangeAnnotationTester(behavior);
      behavior.attachTo(chart0);

      final seriesList = [series1, series2];

      // Act
      drawSeriesList(chart0, seriesList);

      // Verify
      expect(chart0.domainAxis.getLocation(2), equals(20.0));
      expect(
        tester.doesAnnotationExist(
          startPosition: 10.0,
          endPosition: 20.0,
          color: MaterialPalette.gray.shade100,
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.vertical,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 40.0,
          endPosition: 50.0,
          color: MaterialPalette.gray.shade200,
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.vertical,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 80.0,
          endPosition: 100.0,
          color: MaterialPalette.gray.shade300,
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.vertical,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
    });

    test('test dash pattern equality', () {
      // Setup
      final behavior = RangeAnnotation<num>(annotations3);
      final tester = RangeAnnotationTester(behavior);
      behavior.attachTo(chart0);

      final seriesList = [series1, series2];

      // Act
      drawSeriesList(chart0, seriesList);

      // Verify
      expect(chart0.domainAxis.getLocation(2), equals(40.0));
      expect(
        tester.doesAnnotationExist(
          startPosition: 0.0,
          endPosition: 0.0,
          color: MaterialPalette.gray.shade100,
          startLabel: 'Ann 1 Start',
          endLabel: 'Ann 1 End',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.horizontal,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
      expect(
        tester.doesAnnotationExist(
          startPosition: 13.64,
          endPosition: 13.64,
          color: MaterialPalette.gray.shade200,
          dashPattern: dashPattern,
          startLabel: 'Ann 2 Start',
          endLabel: 'Ann 2 End',
          labelAnchor: AnnotationLabelAnchor.end,
          labelDirection: AnnotationLabelDirection.horizontal,
          labelPosition: AnnotationLabelPosition.auto,
        ),
        equals(true),
      );
    });

    test('cleans up', () {
      // Setup
      final behavior = RangeAnnotation<num>(annotations2);
      behavior.attachTo(chart0);

      // Act
      behavior.removeFrom(chart0);

      // Verify
      expect(chart0.lastListener, isNull);
    });
  });
}

class MyRow {
  MyRow(this.campaign, this.count);
  final int campaign;
  final int count;
}

*/
