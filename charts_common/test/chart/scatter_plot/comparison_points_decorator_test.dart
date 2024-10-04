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

import 'dart:math' show Point, Rectangle;
import 'package:nimble_charts_common/src/chart/scatter_plot/comparison_points_decorator.dart';
import 'package:nimble_charts_common/src/chart/scatter_plot/point_renderer.dart';

import 'package:test/test.dart';

/// Datum/Row for the chart.
class MyRow {
  MyRow(this.campaign, this.clickCount);
  final int campaign;
  final int clickCount;
}

class TestComparisonPointsDecorator<D> extends ComparisonPointsDecorator<D> {
  List<Point<double>> testComputeBoundedPointsForElement(
    PointRendererElement<D> pointElement,
    Rectangle drawBounds,
  ) =>
      computeBoundedPointsForElement(pointElement, drawBounds);
}

void main() {
  TestComparisonPointsDecorator decorator;
  Rectangle bounds;

  setUp(() {
    decorator = TestComparisonPointsDecorator<num>();
    bounds = const Rectangle<int>(0, 0, 100, 100);
  });

  group('compute bounded points', () {
    test('with line inside bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 10,
          xLower: 5,
          xUpper: 50,
          y: 20,
          yLower: 20,
          yUpper: 20,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].x, equals(5.0));
      expect(points[0].y, equals(20.0));

      expect(points[1].x, equals(50.0));
      expect(points[1].y, equals(20.0));
    });

    test('with line entirely above bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 10,
          xLower: 5,
          xUpper: 50,
          y: -20,
          yLower: -20,
          yUpper: -20,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely below bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 10,
          xLower: 5,
          xUpper: 50,
          y: 120,
          yLower: 120,
          yUpper: 120,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely left of bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: -10,
          xLower: -5,
          xUpper: -50,
          y: 20,
          yLower: 20,
          yUpper: 50,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely right of bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 110,
          xLower: 105,
          xUpper: 150,
          y: 20,
          yLower: 20,
          yUpper: 50,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with horizontal line extending beyond bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 10,
          xLower: -10,
          xUpper: 110,
          y: 20,
          yLower: 20,
          yUpper: 20,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].x, equals(0.0));
      expect(points[0].y, equals(20.0));

      expect(points[1].x, equals(100.0));
      expect(points[1].y, equals(20.0));
    });

    test('with vertical line extending beyond bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 20,
          xLower: 20,
          xUpper: 20,
          y: 10,
          yLower: -10,
          yUpper: 110,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].x, equals(20.0));
      expect(points[0].y, equals(0.0));

      expect(points[1].x, equals(20.0));
      expect(points[1].y, equals(100.0));
    });

    test('with diagonal from top left to bottom right', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 50,
          xLower: -50,
          xUpper: 150,
          y: 50,
          yLower: -50,
          yUpper: 150,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].x, equals(0.0));
      expect(points[0].y, equals(0.0));

      expect(points[1].x, equals(100.0));
      expect(points[1].y, equals(100.0));
    });

    test('with diagonal from bottom left to top right', () {
      final element = PointRendererElement<num>(
        point: DatumPoint<num>(
          x: 50,
          xLower: -50,
          xUpper: 150,
          y: 50,
          yLower: 150,
          yUpper: -50,
        ),
        radiusPx: 0,
        boundsLineRadiusPx: 0,
        strokeWidthPx: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].x, equals(0.0));
      expect(points[0].y, equals(100.0));

      expect(points[1].x, equals(100.0));
      expect(points[1].y, equals(0.0));
    });
  });
}

*/
