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

import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/cartesian/cartesian_renderer.dart';
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart';
import 'package:nimble_charts_common/src/chart/common/datum_details.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart';
import 'package:nimble_charts_common/src/chart/common/series_datum.dart';
import 'package:nimble_charts_common/src/common/symbol_renderer.dart';
import 'package:test/test.dart';

import '../../mox.mocks.dart';

/// For testing viewport start / end.
class FakeCartesianRenderer extends BaseCartesianRenderer<dynamic> {
  FakeCartesianRenderer() : super(rendererId: 'fake', layoutPaintOrder: 0);

  @override
  List<DatumDetails<dynamic>> getNearestDatumDetailPerSeries(
    Point<double> chartPoint,
    bool byDomain,
    Rectangle<int>? boundsOverride, {
    bool selectOverlappingPoints = false,
    bool selectExactEventLocation = false,
  }) =>
      throw UnimplementedError();

  @override
  void paint(ChartCanvas canvas, double animationPercent) {}

  @override
  void update(List<ImmutableSeries<dynamic>> seriesList, bool isAnimating) {}

  @override
  SymbolRenderer get symbolRenderer => throw UnimplementedError();

  @override
  DatumDetails<dynamic> addPositionToDetailsForSeriesDatum(
    DatumDetails<dynamic> details,
    SeriesDatum<dynamic> seriesDatum,
  ) =>
      details;
}

void main() {
  late BaseCartesianRenderer<dynamic> renderer;

  setUp(() {
    renderer = FakeCartesianRenderer();
  });

  group('find viewport start', () {
    test('several domains are in the viewport', () {
      final data = [0, 1, 2, 3, 4, 5, 6];
      final axis = MockAxis<dynamic>();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(0);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);
      when(axis.compareDomainValueToViewport(4)).thenReturn(0);
      when(axis.compareDomainValueToViewport(5)).thenReturn(1);
      when(axis.compareDomainValueToViewport(6)).thenReturn(1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(2));
    });

    test('extents are all in the viewport, use the first domain', () {
      // Start of viewport is the same as the start of the domain.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(0);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(0));
    });

    test('is the first domain', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(0);
      when(axis.compareDomainValueToViewport(1)).thenReturn(1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(0));
    });

    test('is the last domain', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(3));
    });

    test('is the middle', () {
      final data = [0, 1, 2, 3, 4, 5, 6];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);
      when(axis.compareDomainValueToViewport(4)).thenReturn(1);
      when(axis.compareDomainValueToViewport(5)).thenReturn(1);
      when(axis.compareDomainValueToViewport(6)).thenReturn(1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(3));
    });

    test('viewport is between data', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(1));
    });

    // Error case, viewport shouldn't be set to the outside of the extents.
    // We still want to provide a value.
    test('all extents greater than viewport ', () {
      // Return the right most value as start of viewport.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(3));
    });

    // Error case, viewport shouldn't be set to the outside of the extents.
    // We still want to provide a value.
    test('all extents less than viewport ', () {
      // Return the left most value as the start of the viewport.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(-1);

      final start = renderer.findNearestViewportStart(
        axis,
        (index) => data[index!],
        data,
      );

      expect(start, equals(0));
    });
  });

  group('find viewport end', () {
    test('several domains are in the viewport', () {
      final data = [0, 1, 2, 3, 4, 5, 6];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(0);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);
      when(axis.compareDomainValueToViewport(4)).thenReturn(0);
      when(axis.compareDomainValueToViewport(5)).thenReturn(1);
      when(axis.compareDomainValueToViewport(6)).thenReturn(1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(4));
    });

    test('extents are all in the viewport, use the last domain', () {
      // Start of viewport is the same as the end of the domain.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(0);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(3));
    });

    test('is the first domain', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(0);
      when(axis.compareDomainValueToViewport(1)).thenReturn(1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(0));
    });

    test('is the last domain', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(3));
    });

    test('is the middle', () {
      final data = [0, 1, 2, 3, 4, 5, 6];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(0);
      when(axis.compareDomainValueToViewport(4)).thenReturn(1);
      when(axis.compareDomainValueToViewport(5)).thenReturn(1);
      when(axis.compareDomainValueToViewport(6)).thenReturn(1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(3));
    });

    test('viewport is between data', () {
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(0)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(1)).thenReturn(-1);
      when(axis.compareDomainValueToViewport(2)).thenReturn(1);
      when(axis.compareDomainValueToViewport(3)).thenReturn(1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(2));
    });

    // Error case, viewport shouldn't be set to the outside of the extents.
    // We still want to provide a value.
    test('all extents greater than viewport ', () {
      // Return the right most value as start of viewport.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(3));
    });

    // Error case, viewport shouldn't be set to the outside of the extents.
    // We still want to provide a value.
    test('all extents less than viewport ', () {
      // Return the left most value as the start of the viewport.
      final data = [0, 1, 2, 3];
      final axis = MockAxis();
      when(axis.compareDomainValueToViewport(any)).thenReturn(-1);

      final start =
          renderer.findNearestViewportEnd(axis, (index) => data[index!], data);

      expect(start, equals(0));
    });
  });
}
