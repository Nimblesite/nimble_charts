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

import 'dart:math' show Rectangle;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimble_charts/src/behaviors/chart_behavior.dart';
import 'package:nimble_charts/src/widget_layout_delegate.dart';
import 'package:nimble_charts_common/common.dart' as common
    show BehaviorPosition, InsideJustification, OutsideJustification;

const chartContainerLayoutID = 'chartContainer';

// I couldn't get mockito to work with Widget return type, so fake it is.
class FakeBuildableBehavior implements BuildableBehavior {
  FakeBuildableBehavior(
    this.position,
    this.outsideJustification,
    this.insideJustification,
    this.drawAreaBounds,
  );
  @override
  common.BehaviorPosition position;
  @override
  common.OutsideJustification outsideJustification;
  @override
  common.InsideJustification insideJustification;
  @override
  Rectangle<int>? drawAreaBounds;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

void main() {
  group('widget layout test', () {
    final chartKey = UniqueKey();
    final behaviorKey = UniqueKey();
    const behaviorID = 'behavior';
    const totalSize = Size(200, 100);
    const behaviorSize = Size(50, 50);

    /// Creates widget for testing.
    Widget createWidget(
      Size chartSize,
      Size behaviorSize,
      common.BehaviorPosition position,
      // Using these defaults, copied from DatumLegend.
      {
      required Rectangle<int> drawAreaBounds,
      common.OutsideJustification outsideJustification =
          common.OutsideJustification.startDrawArea,
      common.InsideJustification insideJustification =
          common.InsideJustification.topStart,
      bool isRTL = false,
    }) {
      // Create a mock buildable behavior that returns information about the
      // position and justification desired.
      final behavior = FakeBuildableBehavior(
        position,
        outsideJustification,
        insideJustification,
        drawAreaBounds,
      );

      // The 'chart' widget that expands to the full size allowed to test that
      // the behavior widget's size affects the size given to the chart.
      final chart = LayoutId(
        key: chartKey,
        id: chartContainerLayoutID,
        child: Container(),
      );

      // A behavior widget
      final behaviorWidget = LayoutId(
        key: behaviorKey,
        id: behaviorID,
        child: SizedBox.fromSize(size: behaviorSize),
      );

      // Create a the widget that uses the layout delegate that is being tested.
      final layout = CustomMultiChildLayout(
        delegate: WidgetLayoutDelegate(
          chartContainerLayoutID,
          {behaviorID: behavior},
          isRTL,
        ),
        children: [chart, behaviorWidget],
      );

      final container = Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: chartSize.width,
          height: chartSize.height,
          child: layout,
        ),
      );

      return container;
    }

    // Verifies the expected results.
    void verifyExpectedLayoutBounds(
      WidgetTester tester,
      Size expectedChartSize,
      Offset expectedChartOffset,
      Offset expectedBehaviorOffset,
    ) {
      final chartBox = switch (tester.firstRenderObject(find.byKey(chartKey))) {
        final RenderBox box => box,
        _ => throw StateError('Expected RenderBox for chart'),
      };
      expect(chartBox.size, equals(expectedChartSize));

      final chartOffset = chartBox.localToGlobal(Offset.zero);
      expect(chartOffset, equals(expectedChartOffset));

      final behaviorBox =
          switch (tester.firstRenderObject(find.byKey(behaviorKey))) {
        final RenderBox box => box,
        _ => throw StateError('Expected RenderBox for behavior'),
      };
      final behaviorOffset = behaviorBox.localToGlobal(Offset.zero);
      expect(behaviorOffset, equals(expectedBehaviorOffset));
    }

    testWidgets('Position top - start draw area justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const drawAreaBounds = Rectangle<int>(25, 50, 150, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to draw area
      const expectedBehaviorOffset = Offset(25, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position bottom - end draw area justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.bottom;
      const outsideJustification = common.OutsideJustification.endDrawArea;
      const drawAreaBounds = Rectangle<int>(25, 0, 125, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the bottom, so the chart is offset by 0.
      const expectedChartOffset = Offset.zero;
      // Behavior is aligned to draw area and offset to the bottom.
      const expectedBehaviorOffset = Offset(100, 50);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position start - start draw area justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const drawAreaBounds = Rectangle<int>(75, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the start (left) since this is NOT a RTL
      // so the chart is offset to the right by the behavior width of 50.
      const expectedChartOffset = Offset(50, 0);
      // Behavior is aligned to draw area.
      const expectedBehaviorOffset = Offset(0, 25);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position end - end draw area justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.end;
      const outsideJustification = common.OutsideJustification.endDrawArea;
      const drawAreaBounds = Rectangle<int>(25, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the right (left) since this is NOT a RTL
      // so no offset for the chart.
      const expectedChartOffset = Offset.zero;
      // Behavior is aligned to draw area and offset to the right of the
      // chart.
      const expectedBehaviorOffset = Offset(150, 25);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position top - start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const outsideJustification = common.OutsideJustification.start;
      const drawAreaBounds = Rectangle<int>(25, 50, 150, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to the start, so no offset
      const expectedBehaviorOffset = Offset.zero;

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position top - end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const outsideJustification = common.OutsideJustification.end;
      const drawAreaBounds = Rectangle<int>(25, 50, 150, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to the end, so it is offset by total size minus
      // the behavior size.
      const expectedBehaviorOffset = Offset(150, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position start - start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const outsideJustification = common.OutsideJustification.start;
      const drawAreaBounds = Rectangle<int>(75, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the start (left) since this is NOT a RTL
      // so the chart is offset to the right by the behavior width of 50.
      const expectedChartOffset = Offset(50, 0);
      // No offset because it is start justified.
      const expectedBehaviorOffset = Offset.zero;

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position start - end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const outsideJustification = common.OutsideJustification.end;
      const drawAreaBounds = Rectangle<int>(75, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the start (left) since this is NOT a RTL
      // so the chart is offset to the right by the behavior width of 50.
      const expectedChartOffset = Offset(50, 0);
      // End justified, total height minus behavior height
      const expectedBehaviorOffset = Offset(0, 50);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position inside - top start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.inside;
      const drawAreaBounds = Rectangle<int>(25, 25, 175, 75);

      // Behavior is layered on top, chart uses the full size.
      const expectedChartSize = Size(200, 100);
      // No offset since chart takes up full size.
      const expectedChartOffset = Offset.zero;
      // Top start justified, no offset
      const expectedBehaviorOffset = Offset.zero;

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('Position inside - top end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.inside;
      const insideJustification = common.InsideJustification.topEnd;
      const drawAreaBounds = Rectangle<int>(25, 25, 175, 75);

      // Behavior is layered on top, chart uses the full size.
      const expectedChartSize = Size(200, 100);
      // No offset since chart takes up full size.
      const expectedChartOffset = Offset.zero;
      // Offset to the top end
      const expectedBehaviorOffset = Offset(150, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          insideJustification: insideJustification,
          drawAreaBounds: drawAreaBounds,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position top - start draw area justified',
        (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const drawAreaBounds = Rectangle<int>(0, 50, 175, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to start draw area, which is to the left in RTL
      const expectedBehaviorOffset = Offset(125, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position bottom - end draw area justified',
        (tester) async {
      const behaviorPosition = common.BehaviorPosition.bottom;
      const outsideJustification = common.OutsideJustification.endDrawArea;
      const drawAreaBounds = Rectangle<int>(0, 0, 175, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the bottom, so the chart is offset by 0.
      const expectedChartOffset = Offset.zero;
      // Behavior is aligned to end draw area (left) and offset to the bottom.
      const expectedBehaviorOffset = Offset(0, 50);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position start - start draw area justified',
        (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const drawAreaBounds = Rectangle<int>(0, 25, 125, 75);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Chart is on the left, so no offset.
      const expectedChartOffset = Offset.zero;
      // Behavior is positioned at the start (right) and start draw area.
      const expectedBehaviorOffset = Offset(150, 25);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position end - end draw area justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.end;
      const outsideJustification = common.OutsideJustification.endDrawArea;
      const drawAreaBounds = Rectangle<int>(75, 25, 125, 75);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Chart is to the left of the behavior because of RTL.
      const expectedChartOffset = Offset(50, 0);
      // Behavior is aligned to end draw area.
      const expectedBehaviorOffset = Offset(0, 50);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position top - start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const outsideJustification = common.OutsideJustification.start;
      const drawAreaBounds = Rectangle<int>(25, 50, 150, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to the end, offset by behavior size.
      const expectedBehaviorOffset = Offset(150, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position top - end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.top;
      const outsideJustification = common.OutsideJustification.end;
      const drawAreaBounds = Rectangle<int>(25, 50, 150, 50);

      // Behavior takes up 50 height, so 50 height remains for the chart.
      const expectedChartSize = Size(200, 50);
      // Behavior is positioned on the top, so the chart is offset by 50.
      const expectedChartOffset = Offset(0, 50);
      // Behavior is aligned to the end, no offset.
      const expectedBehaviorOffset = Offset.zero;

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position start - start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const outsideJustification = common.OutsideJustification.start;
      const drawAreaBounds = Rectangle<int>(75, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the right since this is RTL so the chart is
      // has no offset.
      const expectedChartOffset = Offset.zero;
      // No offset because it is start justified.
      const expectedBehaviorOffset = Offset(150, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position start - end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.start;
      const outsideJustification = common.OutsideJustification.end;
      const drawAreaBounds = Rectangle<int>(75, 25, 150, 50);

      // Behavior takes up 50 width, so 150 width remains for the chart.
      const expectedChartSize = Size(150, 100);
      // Behavior is positioned at the right since this is RTL so the chart is
      // has no offset.
      const expectedChartOffset = Offset.zero;
      // End justified, total height minus behavior height
      const expectedBehaviorOffset = Offset(150, 50);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          outsideJustification: outsideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position inside - top start justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.inside;
      const drawAreaBounds = Rectangle<int>(25, 25, 175, 75);

      // Behavior is layered on top, chart uses the full size.
      const expectedChartSize = Size(200, 100);
      // No offset since chart takes up full size.
      const expectedChartOffset = Offset.zero;
      // Offset to the right
      const expectedBehaviorOffset = Offset(150, 0);

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });

    testWidgets('RTL - Position inside - top end justified', (tester) async {
      const behaviorPosition = common.BehaviorPosition.inside;
      const insideJustification = common.InsideJustification.topEnd;
      const drawAreaBounds = Rectangle<int>(25, 25, 175, 75);

      // Behavior is layered on top, chart uses the full size.
      const expectedChartSize = Size(200, 100);
      // No offset since chart takes up full size.
      const expectedChartOffset = Offset.zero;
      // No offset, since end is to the left.
      const expectedBehaviorOffset = Offset.zero;

      await tester.pumpWidget(
        createWidget(
          totalSize,
          behaviorSize,
          behaviorPosition,
          insideJustification: insideJustification,
          drawAreaBounds: drawAreaBounds,
          isRTL: true,
        ),
      );

      verifyExpectedLayoutBounds(
        tester,
        expectedChartSize,
        expectedChartOffset,
        expectedBehaviorOffset,
      );
    });
  });
}
