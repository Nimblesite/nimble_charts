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

// ignore_for_file: lines_longer_than_80_chars, cascade_invocations

import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart'
    show AxisOrientation;
import 'package:nimble_charts_common/src/chart/cartesian/axis/draw_strategy/base_tick_draw_strategy.dart'
    show BaseTickDrawStrategy;
import 'package:nimble_charts_common/src/chart/cartesian/axis/spec/axis_spec.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick.dart'
    show Tick;
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart';
import 'package:nimble_charts_common/src/chart/common/chart_context.dart';
import 'package:nimble_charts_common/src/common/graphics_factory.dart';
import 'package:nimble_charts_common/src/common/text_element.dart';
import 'package:nimble_charts_common/src/common/text_measurement.dart';
import 'package:nimble_charts_common/src/common/text_style.dart';
import 'package:test/test.dart';

import '../../../../mox.mocks.dart';

/// Implementation of [BaseTickDrawStrategy] that does nothing on draw.
class BaseTickDrawStrategyImpl<D> extends BaseTickDrawStrategy<D> {
  BaseTickDrawStrategyImpl(
    super.chartContext,
    super.graphicsFactory, {
    super.labelStyleSpec,
    super.axisLineStyleSpec,
    super.labelAnchor,
    super.labelJustification,
    super.labelOffsetFromAxisPx,
    super.labelCollisionOffsetFromAxisPx,
    super.labelOffsetFromTickPx,
    super.labelCollisionOffsetFromTickPx,
    super.minimumPaddingBetweenLabelsPx,
    super.labelRotation,
    super.labelCollisionRotation,
  });

  @override
  void draw(
    ChartCanvas canvas,
    Tick<D> tick, {
    required AxisOrientation orientation,
    required Rectangle<int> axisBounds,
    required Rectangle<int> drawAreaBounds,
    required bool isFirst,
    required bool isLast,
    bool collision = false,
  }) {}

  @override
  void drawLabel(
    ChartCanvas canvas,
    Tick<D> tick, {
    required AxisOrientation orientation,
    required Rectangle<int> axisBounds,
    required Rectangle<int>? drawAreaBounds,
    required bool isFirst,
    required bool isLast,
    bool collision = false,
  }) {
    super.drawLabel(
      canvas,
      tick,
      orientation: orientation,
      axisBounds: axisBounds,
      drawAreaBounds: drawAreaBounds,
      isFirst: isFirst,
      isLast: isLast,
      collision: collision,
    );
  }
}

/// Fake [TextElement] for testing.
///
/// [baseline] returns the same value as the [verticalSliceWidth] specified.
class FakeTextElement implements TextElement {
  FakeTextElement(
    this.text,
    this.textDirection,
    double horizontalSliceWidth,
    double verticalSliceWidth,
  ) : measurement = TextMeasurement(
          horizontalSliceWidth: horizontalSliceWidth,
          verticalSliceWidth: verticalSliceWidth,
        );

  @override
  final String text;

  @override
  final TextMeasurement measurement;

  @override
  TextStyle? textStyle;

  @override
  int? maxWidth;

  @override
  MaxWidthStrategy? maxWidthStrategy;

  @override
  TextDirection textDirection;

  @override
  double? opacity;
}

/// Helper function to create [Tick] for testing.
Tick<String> createTick(
  String value,
  double locationPx, {
  double? horizontalWidth,
  double? verticalWidth,
  TextDirection? textDirection,
  bool collision = false,
}) =>
    Tick<String>(
      value: value,
      locationPx: locationPx,
      textElement: FakeTextElement(
        value,
        textDirection ?? TextDirection.ltr,
        horizontalWidth ?? 0,
        verticalWidth ?? 15,
      ),
    );

void main() {
  late GraphicsFactory graphicsFactory;
  late ChartContext chartContext;

  setUpAll(() {
    graphicsFactory = MockGraphicsFactory();
    when(graphicsFactory.createLinePaint()).thenReturn(MockLinePaint());
    when(graphicsFactory.createTextPaint()).thenReturn(MockTextStyle());

    chartContext = MockChartContext();
    when(chartContext.chartContainerIsRtl).thenReturn(false);
    when(chartContext.isRtl).thenReturn(false);
  });

  group('collision detection - vertically drawn axis', () {
    test('ticks do not collide', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 8),
        createTick('B', 20, verticalWidth: 8),
        createTick('C', 30, verticalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide because it does not have minimum padding', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 8),
        createTick('B', 20, verticalWidth: 9),
        createTick('C', 30, verticalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('first tick causes collision', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 11),
        createTick('B', 20, verticalWidth: 10),
        createTick('C', 30, verticalWidth: 10),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('last tick causes collision', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 10),
        createTick('B', 20, verticalWidth: 10),
        createTick('C', 29, verticalWidth: 10),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks do not collide for inside tick label anchor', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 8),
        createTick('B', 25, verticalWidth: 8),
        createTick('C', 40, verticalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide for inside anchor - first tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 9),
        createTick('B', 25, verticalWidth: 8),
        createTick('C', 40, verticalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide for inside anchor - center tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 8),
        createTick('B', 25, verticalWidth: 9),
        createTick('C', 40, verticalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide for inside anchor - last tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, verticalWidth: 8),
        createTick('B', 25, verticalWidth: 8),
        createTick('C', 40, verticalWidth: 9),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - horizontally drawn axis', () {
    test('ticks do not collide for TickLabelAnchor.before', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 2,
        labelAnchor: TickLabelAnchor.before,
      );

      final ticks = [
        createTick('A', 10, horizontalWidth: 8),
        createTick('B', 20, horizontalWidth: 8),
        createTick('C', 30, horizontalWidth: 8),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks do not collide for TickLabelAnchor.inside', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick(
          'A',
          10,
          horizontalWidth: 10,
          textDirection: TextDirection.ltr,
        ),
        createTick(
          'B',
          25,
          horizontalWidth: 10,
          textDirection: TextDirection.center,
        ),
        createTick(
          'C',
          40,
          horizontalWidth: 10,
          textDirection: TextDirection.rtl,
        ),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide - first tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, horizontalWidth: 11),
        createTick('B', 25, horizontalWidth: 10),
        createTick('C', 40, horizontalWidth: 10),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide - middle tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, horizontalWidth: 10),
        createTick('B', 25, horizontalWidth: 11),
        createTick('C', 40, horizontalWidth: 10),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide - last tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, horizontalWidth: 10),
        createTick('B', 25, horizontalWidth: 10),
        createTick('C', 40, horizontalWidth: 11),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - unsorted ticks', () {
    test('ticks do not collide', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('C', 40, horizontalWidth: 10),
        createTick('B', 25, horizontalWidth: 10),
        createTick('A', 10, horizontalWidth: 10),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide - tick B is too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        minimumPaddingBetweenLabelsPx: 0,
        labelAnchor: TickLabelAnchor.inside,
      );

      final ticks = [
        createTick('A', 10, horizontalWidth: 10),
        createTick('C', 40, horizontalWidth: 10),
        createTick('B', 25, horizontalWidth: 11),
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - corner cases', () {
    test('null ticks do not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides(null, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('empty tick list do not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides([], AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('single tick does not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides(
        [createTick('A', 10, horizontalWidth: 10)],
        AxisOrientation.bottom,
      );

      expect(report.ticksCollide, isFalse);
    });
  });

  group('Draw Label', () {
    void setUpLabel(String text, {double? width}) =>
        when(graphicsFactory.createTextElement(text)).thenReturn(
          FakeTextElement(
            text,
            TextDirection.ltr,
            width ?? 0,
            15,
          ),
        );

    late BaseTickDrawStrategyImpl<String> drawStrategy;
    late List<Tick<String>> ticks;

    setUp(() {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      ticks = [
        createTick(
          'This label \nspans \n multiple lines!!!',
          0,
          horizontalWidth: 100,
          verticalWidth: 15,
        ),
        createTick(
          'A',
          20,
          horizontalWidth: 10,
          verticalWidth: 15,
        ),
      ];

      setUpLabel('This label', width: 30);
      setUpLabel('spans', width: 10);
      setUpLabel('multiple lines!!!', width: 60);
      setUpLabel('A', width: 10);
    });

    test('measureHorizontallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxisPx(collision: false);
      final sizes = drawStrategy.measureHorizontallyDrawnTicks(ticks, 250, 500);

      expect(sizes.preferredHeight, 15 * 3 + 4 + offset);
      expect(sizes.preferredWidth, 250);
    });

    test('measureVerticallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxisPx(collision: false);
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500);

      expect(sizes.preferredWidth, 60.0 + offset);
      expect(sizes.preferredHeight, 500);
    });

    test('measureVerticallyDrawnTicks - negative labelOffsetFromAxisPx', () {
      const offset = -500;
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromAxisPx: offset,
      );
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500);

      expect(sizes.preferredWidth, 0);
      expect(sizes.preferredHeight, 500);
    });

    test('Draw multiline label', () {
      final chartCanvas = MockCanvas();
      const axisBounds = Rectangle<int>(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks.first,
        orientation: AxisOrientation.bottom,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        isFirst: true,
        isLast: false,
      );

      final labelLine1 = verify(chartCanvas.drawText(captureAny, 0, 5))
          .captured
          .single as TextElement;
      expect(labelLine1.text, 'This label');

      final labelLine2 = verify(chartCanvas.drawText(captureAny, 0, 22))
          .captured
          .single as TextElement;
      expect(labelLine2.text, 'spans');

      final labelLine3 = verify(chartCanvas.drawText(captureAny, 0, 39))
          .captured
          .single as TextElement;
      expect(labelLine3.text, 'multiple lines!!!');
    });

    test('Draw single line label', () {
      final chartCanvas = MockCanvas();
      const axisBounds = Rectangle<int>(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks[1],
        orientation: AxisOrientation.top,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        isFirst: true,
        isLast: false,
      );

      final labelLine = verify(chartCanvas.drawText(captureAny, 20, 980))
          .captured
          .single as TextElement;
      expect(labelLine.text, 'A');
    });
  });

  group('Draw Label with collision', () {
    const collisionRotationDegrees = 45;
    const collisionRotationRadians = 0.7853981633974483;

    void setUpLabel(String text, {double? width}) =>
        when(graphicsFactory.createTextElement(text)).thenReturn(
          FakeTextElement(
            text,
            TextDirection.ltr,
            width ?? 0,
            15,
          ),
        );

    late BaseTickDrawStrategyImpl<String> drawStrategy;
    late List<Tick<String>> ticks;

    setUp(() {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelCollisionRotation: collisionRotationDegrees,
      );

      ticks = [
        createTick(
          'This label \nspans \n multiple lines!!!',
          0,
          horizontalWidth: 100,
          verticalWidth: 15,
          collision: true,
        ),
        createTick(
          'A',
          20,
          horizontalWidth: 10,
          verticalWidth: 15,
          collision: true,
        ),
      ];

      setUpLabel('This label', width: 30);
      setUpLabel('spans', width: 10);
      setUpLabel('multiple lines!!!', width: 60);
      setUpLabel('A', width: 10);
    });

    test('measureHorizontallyDrawnTicks', () {
      final sizes = drawStrategy.measureHorizontallyDrawnTicks(
        ticks,
        250,
        500,
        collision: true,
      );

      expect(sizes.preferredHeight, 64);
      expect(sizes.preferredWidth, 250);
    });

    test('measureVerticallyDrawnTicks', () {
      final sizes = drawStrategy.measureVerticallyDrawnTicks(
        ticks,
        250,
        500,
        collision: true,
      );

      expect(sizes.preferredWidth, 64);
      expect(sizes.preferredHeight, 500);
    });

    test('measureVerticallyDrawnTicks - negative labelOffsetFromAxisPx', () {
      const offset = -500;
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelCollisionRotation: 45,
        labelCollisionOffsetFromAxisPx: offset,
      );
      final sizes = drawStrategy.measureVerticallyDrawnTicks(
        ticks,
        250,
        500,
        collision: true,
      );

      expect(sizes.preferredWidth, 0);
      expect(sizes.preferredHeight, 500);
    });

    test('Draw multiline label', () {
      final chartCanvas = MockCanvas();
      const axisBounds = Rectangle<int>(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks.first,
        orientation: AxisOrientation.bottom,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        isFirst: true,
        isLast: false,
        collision: true,
      );

      final labelLine1 = verify(
        chartCanvas.drawText(
          captureAny,
          -5,
          5,
          rotation: collisionRotationRadians,
        ),
      ).captured.single;
      expect(labelLine1.text, 'This label');

      final labelLine2 = verify(
        chartCanvas.drawText(
          captureAny,
          -5,
          22,
          rotation: collisionRotationRadians,
        ),
      ).captured.single;
      expect(labelLine2.text, 'spans');

      final labelLine3 = verify(
        chartCanvas.drawText(
          captureAny,
          -5,
          39,
          rotation: collisionRotationRadians,
        ),
      ).captured.single;
      expect(labelLine3.text, 'multiple lines!!!');
    });

    test('Draw single line label', () {
      final chartCanvas = MockCanvas();
      const axisBounds = Rectangle<int>(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks[1],
        orientation: AxisOrientation.top,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        isFirst: true,
        isLast: false,
        collision: true,
      );

      final labelLine = verify(
        chartCanvas.drawText(
          captureAny,
          15,
          980,
          rotation: collisionRotationRadians,
        ),
      ).captured.single;
      expect(labelLine.text, 'A');
    });
  });

  group('Adjust width of labels based on size', () {
    void setUpLabel(String text, {double? width}) =>
        when(graphicsFactory.createTextElement(text)).thenReturn(
          FakeTextElement(
            text,
            TextDirection.ltr,
            width ?? 0,
            15,
          ),
        );

    late BaseTickDrawStrategyImpl<String> drawStrategy;
    late List<Tick<String>> ticks;

    setUp(() {
      ticks = [
        createTick(
          'This label is long',
          0,
          horizontalWidth: 50,
          verticalWidth: 15,
        ),
        createTick('Test', 0, horizontalWidth: 10, verticalWidth: 15),
      ];

      setUpLabel('This label is long', width: 50);
      setUpLabel('Test', width: 10);
    });

    test('Sets max width for vertical labels', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
      );

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement!.maxWidth, 25);
      expect(
        ticks.first.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
      expect(ticks.last.textElement!.maxWidth, 25);
      expect(
        ticks.last.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
    });

    test('Sets max width for vertical labels that are parallel to the axis ',
        () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
        labelRotation: 90,
      );

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement!.maxWidth, null);
      expect(ticks.first.textElement!.maxWidthStrategy, null);
      expect(ticks.last.textElement!.maxWidth, null);
      expect(ticks.last.textElement!.maxWidthStrategy, null);
    });

    test('Sets max width for vertical labels that are angled', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
        labelRotation: 45,
      );

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement!.maxWidth, 35);
      expect(
        ticks.first.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
      expect(ticks.last.textElement!.maxWidth, 35);
      expect(
        ticks.last.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
    });

    test('Sets max width for horizontal labels', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
        labelRotation: 90,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement!.maxWidth, 25);
      expect(
        ticks.first.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
      expect(ticks.last.textElement!.maxWidth, 25);
      expect(
        ticks.last.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
    });

    test('Sets max width for horizontal labels that are parallel to the axis',
        () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement!.maxWidth, null);
      expect(ticks.first.textElement!.maxWidthStrategy, null);
      expect(ticks.last.textElement!.maxWidth, null);
      expect(ticks.last.textElement!.maxWidthStrategy, null);
    });

    test('Sets max width for horizontal labels that are angled', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTickPx: 0,
        labelOffsetFromAxisPx: 0,
        labelRotation: 45,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement!.maxWidth, 35);
      expect(
        ticks.first.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
      expect(ticks.last.textElement!.maxWidth, 35);
      expect(
        ticks.last.textElement!.maxWidthStrategy,
        MaxWidthStrategy.ellipsize,
      );
    });
  });
}
