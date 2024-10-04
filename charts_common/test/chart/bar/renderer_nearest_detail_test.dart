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
import 'package:nimble_charts_common/src/chart/bar/bar_renderer.dart';
import 'package:nimble_charts_common/src/chart/bar/bar_renderer_config.dart';
import 'package:nimble_charts_common/src/chart/bar/bar_target_line_renderer.dart';
import 'package:nimble_charts_common/src/chart/bar/bar_target_line_renderer_config.dart';
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer.dart';
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer_config.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart';
import 'package:nimble_charts_common/src/common/color.dart';
import 'package:nimble_charts_common/src/data/series.dart';
import 'package:test/test.dart';

import '../../mox.mocks.dart';

/// Datum/Row for the chart.
class MyRow {
  MyRow(this.campaign, this.clickCount);
  final String campaign;
  final int clickCount;
}

/// Datum for the time series chart
class MyDateTimeRow {
  MyDateTimeRow(this.time, this.clickCount);
  final DateTime time;
  final int clickCount;
}

void main() {
  final date0 = DateTime(2018, 2);
  final date1 = DateTime(2018, 2, 7);
  final dateOutsideViewport = DateTime(2018);

  /////////////////////////////////////////
  // Convenience methods for creating mocks.
  /////////////////////////////////////////
  BaseBarRenderer<dynamic, dynamic, dynamic> configureBaseRenderer(
    BaseBarRenderer<dynamic, dynamic, dynamic> renderer,
    bool vertical,
  ) {
    final context = MockChartContext();
    when(context.chartContainerIsRtl).thenReturn(false);
    when(context.isRtl).thenReturn(false);
    final verticalChart = MockChart();
    when(verticalChart.vertical).thenReturn(vertical);
    when(verticalChart.context).thenReturn(context);
    renderer.onAttach(verticalChart);

    final layoutBounds = vertical
        ? const Rectangle<int>(70, 20, 230, 100)
        : const Rectangle<int>(70, 20, 100, 230);
    renderer.layout(layoutBounds, layoutBounds);
    return renderer;
  }

  BaseBarRenderer<dynamic, dynamic, dynamic> makeBarRenderer({
    required bool vertical,
    required BarGroupingType groupType,
  }) {
    final renderer =
        BarRenderer(config: BarRendererConfig(groupingType: groupType));
    configureBaseRenderer(renderer, vertical);
    return renderer;
  }

  BaseBarRenderer<dynamic, dynamic, dynamic> makeBarTargetRenderer({
    required bool vertical,
    required BarGroupingType groupType,
  }) {
    final renderer = BarTargetLineRenderer(
      config: BarTargetLineRendererConfig(groupingType: groupType),
    );
    configureBaseRenderer(renderer, vertical);
    return renderer;
  }

  MutableSeries<String> makeSeries({
    required String id,
    String? seriesCategory,
    bool vertical = true,
  }) {
    final data = <MyRow>[
      MyRow('camp0', 10),
      MyRow('camp1', 10),
    ];

    final series = MutableSeries(
      Series<MyRow, String>(
        id: id,
        data: data,
        domainFn: (row, _) => row.campaign,
        measureFn: (row, _) => row.clickCount,
        seriesCategory: seriesCategory,
      ),
    )
      ..measureOffsetFn = ((_) => 0.0)
      ..colorFn = (_) => Color.fromHex(code: '#000000');

    // Mock the Domain axis results.
    final domainAxis = MockOrdinalAxis();
    when(domainAxis.rangeBand).thenReturn(100);
    final domainOffset = vertical ? 70.0 : 20.0;
    when(domainAxis.getLocation('camp0'))
        .thenReturn(domainOffset + 10.0 + 50.0);
    when(domainAxis.getLocation('camp1'))
        .thenReturn(domainOffset + 10.0 + 100.0 + 10.0 + 50.0);
    when(domainAxis.getLocation('outsideViewport')).thenReturn(-51);

    if (vertical) {
      when(domainAxis.getDomain(100)).thenReturn('camp0');
      when(domainAxis.getDomain(93)).thenReturn('camp0');
      when(domainAxis.getDomain(130)).thenReturn('camp0');
      when(domainAxis.getDomain(65)).thenReturn('outsideViewport');
    } else {
      when(domainAxis.getDomain(50)).thenReturn('camp0');
      when(domainAxis.getDomain(43)).thenReturn('camp0');
      when(domainAxis.getDomain(80)).thenReturn('camp0');
    }
    series.setAttr(domainAxisKey, domainAxis);

    // Mock the Measure axis results.
    final measureAxis = MockAxis<num>();
    if (vertical) {
      when(measureAxis.getLocation(0.0)).thenReturn(20.0 + 100.0);
      when(measureAxis.getLocation(10.0)).thenReturn(20.0 + 100.0 - 10.0);
      when(measureAxis.getLocation(20.0)).thenReturn(20.0 + 100.0 - 20.0);
    } else {
      when(measureAxis.getLocation(0.0)).thenReturn(70);
      when(measureAxis.getLocation(10.0)).thenReturn(70.0 + 10.0);
      when(measureAxis.getLocation(20.0)).thenReturn(70.0 + 20.0);
    }
    series.setAttr(measureAxisKey, measureAxis);

    return series;
  }

  MutableSeries<DateTime> makeDateTimeSeries({
    required String id,
    String? seriesCategory,
    bool vertical = true,
  }) {
    final data = <MyDateTimeRow>[
      MyDateTimeRow(date0, 10),
      MyDateTimeRow(date1, 10),
    ];

    final series = MutableSeries(
      Series<MyDateTimeRow, DateTime>(
        id: id,
        data: data,
        domainFn: (row, _) => row.time,
        measureFn: (row, _) => row.clickCount,
        seriesCategory: seriesCategory,
      ),
    )
      ..measureOffsetFn = ((_) => 0.0)
      ..colorFn = (_) => Color.fromHex(code: '#000000');

    // Mock the Domain axis results.
    final domainAxis = MockAxis<DateTime>();
    when(domainAxis.rangeBand).thenReturn(100);
    final domainOffset = vertical ? 70.0 : 20.0;
    when(domainAxis.getLocation(date0)).thenReturn(domainOffset + 10.0 + 50.0);
    when(domainAxis.getLocation(date1))
        .thenReturn(domainOffset + 10.0 + 100.0 + 10.0 + 50.0);
    when(domainAxis.getLocation(dateOutsideViewport)).thenReturn(-51);

    series.setAttr(domainAxisKey, domainAxis);

    // Mock the Measure axis results.
    final measureAxis = MockAxis<num>();
    if (vertical) {
      when(measureAxis.getLocation(0.0)).thenReturn(20.0 + 100.0);
      when(measureAxis.getLocation(10.0)).thenReturn(20.0 + 100.0 - 10.0);
      when(measureAxis.getLocation(20.0)).thenReturn(20.0 + 100.0 - 20.0);
    } else {
      when(measureAxis.getLocation(0.0)).thenReturn(70);
      when(measureAxis.getLocation(10.0)).thenReturn(70.0 + 10.0);
      when(measureAxis.getLocation(20.0)).thenReturn(70.0 + 20.0);
    }
    series.setAttr(measureAxisKey, measureAxis);

    return series;
  }

  late bool selectNearestByDomain;

  setUp(() {
    selectNearestByDomain = true;
  });

  /////////////////////////////////////////
  // Additional edge test cases
  /////////////////////////////////////////
  group('edge cases', () {
    test('hit target on missing data in group should highlight group', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..data.clear(),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(31)); // 2 + 49 - 20
      expect(closest.measureDistance, equals(0));
    });

    test('all series without data is skipped', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..data.clear(),
        makeSeries(id: 'bar')..data.clear(),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(0));
    });

    test('single overlay series is skipped', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..overlaySeries = true,
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(31)); // 2 + 49 - 20
      expect(closest.measureDistance, equals(0));
    });

    test('all overlay series is skipped', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..overlaySeries = true,
        makeSeries(id: 'bar')..overlaySeries = true,
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(0));
    });
  });

  /////////////////////////////////////////
  // Vertical BarRenderer
  /////////////////////////////////////////
  group('Vertical BarRenderer', () {
    test('hit test works on bar', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[makeSeries(id: 'foo')];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));
    });

    test('hit test expands to grouped bars', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(31)); // 2 + 49 - 20
      expect(next.measureDistance, equals(0));
    });

    test('hit test expands to stacked bars', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('foo'));
      expect(next.datum, equals(seriesList[0].data[0]));
      expect(next.domainDistance, equals(0));
      expect(next.measureDistance, equals(5.0));
    });

    test('hit test expands to grouped stacked', () {
      // Setup
      final renderer = makeBarRenderer(
        vertical: true,
        groupType: BarGroupingType.groupedStacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo0', seriesCategory: 'c0'),
        makeSeries(id: 'bar0', seriesCategory: 'c0'),
        makeSeries(id: 'foo1', seriesCategory: 'c1'),
        makeSeries(id: 'bar1', seriesCategory: 'c1'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(4));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar0'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final other1 = details[1];
      expect(other1.domain, equals('camp0'));
      expect(other1.series?.id, equals('foo0'));
      expect(other1.datum, equals(seriesList[0].data[0]));
      expect(other1.domainDistance, equals(0));
      expect(other1.measureDistance, equals(5));

      final other2 = details[2];
      expect(other2.domain, equals('camp0'));
      expect(other2.series?.id, equals('bar1'));
      expect(other2.datum, equals(seriesList[3].data[0]));
      expect(other2.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other2.measureDistance, equals(0));

      final other3 = details[3];
      expect(other3.domain, equals('camp0'));
      expect(other3.series?.id, equals('foo1'));
      expect(other3.datum, equals(seriesList[2].data[0]));
      expect(other3.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other3.measureDistance, equals(5));
    });

    test('hit test works above bar', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[makeSeries(id: 'foo')];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(90));
    });

    test('hit test works between bars in a group', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 50.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(1));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(1));
      expect(next.measureDistance, equals(0));
    });

    test('no selection for bars outside of viewport', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..data.add(MyRow('outsideViewport', 20)),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      // Note: point is in the axis, over a bar outside of the viewport.
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(65, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(0));
    });
  });

  /////////////////////////////////////////
  // Horizontal BarRenderer
  /////////////////////////////////////////
  group('Horizontal BarRenderer', () {
    test('hit test works on bar', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: false, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 13.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));
    });

    test('hit test expands to grouped bars', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: false, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(31)); // 2 + 49 - 20
      expect(next.measureDistance, equals(0));
    });

    test('hit test expands to stacked bars', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: false, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(0));
      expect(next.measureDistance, equals(5.0));
    });

    test('hit test expands to grouped stacked', () {
      // Setup
      final renderer = makeBarRenderer(
        vertical: false,
        groupType: BarGroupingType.groupedStacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo0', seriesCategory: 'c0', vertical: false),
        makeSeries(id: 'bar0', seriesCategory: 'c0', vertical: false),
        makeSeries(id: 'foo1', seriesCategory: 'c1', vertical: false),
        makeSeries(id: 'bar1', seriesCategory: 'c1', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(4));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo0'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final other1 = details[1];
      expect(other1.domain, equals('camp0'));
      expect(other1.series?.id, equals('bar0'));
      expect(other1.datum, equals(seriesList[1].data[0]));
      expect(other1.domainDistance, equals(0));
      expect(other1.measureDistance, equals(5));

      final other2 = details[2];
      expect(other2.domain, equals('camp0'));
      expect(other2.series?.id, equals('foo1'));
      expect(other2.datum, equals(seriesList[2].data[0]));
      expect(other2.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other2.measureDistance, equals(0));

      final other3 = details[3];
      expect(other3.domain, equals('camp0'));
      expect(other3.series?.id, equals('bar1'));
      expect(other3.datum, equals(seriesList[3].data[0]));
      expect(other3.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other3.measureDistance, equals(5));
    });

    test('hit test works above bar', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: false, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 100.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(90));
    });

    test('hit test works between bars in a group', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: false, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 50.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(1));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(1));
      expect(next.measureDistance, equals(0));
    });
  });

  /////////////////////////////////////////
  // Vertical BarTargetRenderer
  /////////////////////////////////////////
  group('Vertical BarTargetRenderer', () {
    test('hit test works above target', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.stacked,
      );
      final seriesList = <MutableSeries<String>>[makeSeries(id: 'foo')];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(90));
    });

    test('hit test expands to grouped bar targets', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(31)); // 2 + 49 - 20
      expect(next.measureDistance, equals(5));
    });

    test('hit test expands to stacked bar targets', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.stacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('foo'));
      expect(next.datum, equals(seriesList[0].data[0]));
      expect(next.domainDistance, equals(0));
      expect(next.measureDistance, equals(15.0));
    });

    test('hit test expands to grouped stacked', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.groupedStacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo0', seriesCategory: 'c0'),
        makeSeries(id: 'bar0', seriesCategory: 'c0'),
        makeSeries(id: 'foo1', seriesCategory: 'c1'),
        makeSeries(id: 'bar1', seriesCategory: 'c1'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(4));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('bar0'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final other1 = details[1];
      expect(other1.domain, equals('camp0'));
      expect(other1.series?.id, equals('foo0'));
      expect(other1.datum, equals(seriesList[0].data[0]));
      expect(other1.domainDistance, equals(0));
      expect(other1.measureDistance, equals(15));

      final other2 = details[2];
      expect(other2.domain, equals('camp0'));
      expect(other2.series?.id, equals('bar1'));
      expect(other2.datum, equals(seriesList[3].data[0]));
      expect(other2.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other2.measureDistance, equals(5));

      final other3 = details[3];
      expect(other3.domain, equals('camp0'));
      expect(other3.series?.id, equals('foo1'));
      expect(other3.datum, equals(seriesList[2].data[0]));
      expect(other3.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other3.measureDistance, equals(15));
    });

    test('hit test works between targets in a group', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo'),
        makeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 50.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(1));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(1));
      expect(next.measureDistance, equals(5));
    });

    test('no selection for targets outside of viewport', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo')..data.add(MyRow('outsideViewport', 20)),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      // Note: point is in the axis, over a bar outside of the viewport.
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(65, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(0));
    });
  });

  /////////////////////////////////////////
  // Horizontal BarTargetRenderer
  /////////////////////////////////////////
  group('Horizontal BarTargetRenderer', () {
    test('hit test works above target', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: false,
        groupType: BarGroupingType.stacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 100.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(90));
    });

    test('hit test expands to grouped bar targets', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: false,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(31)); // 2 + 49 - 20
      expect(next.measureDistance, equals(5));
    });

    test('hit test expands to stacked bar targets', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: false,
        groupType: BarGroupingType.stacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(0));
      expect(next.measureDistance, equals(15));
    });

    test('hit test expands to grouped stacked', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: false,
        groupType: BarGroupingType.groupedStacked,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo0', seriesCategory: 'c0', vertical: false),
        makeSeries(id: 'bar0', seriesCategory: 'c0', vertical: false),
        makeSeries(id: 'foo1', seriesCategory: 'c1', vertical: false),
        makeSeries(id: 'bar1', seriesCategory: 'c1', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 20.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(4));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo0'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final other1 = details[1];
      expect(other1.domain, equals('camp0'));
      expect(other1.series?.id, equals('bar0'));
      expect(other1.datum, equals(seriesList[1].data[0]));
      expect(other1.domainDistance, equals(0));
      expect(other1.measureDistance, equals(15));

      final other2 = details[2];
      expect(other2.domain, equals('camp0'));
      expect(other2.series?.id, equals('foo1'));
      expect(other2.datum, equals(seriesList[2].data[0]));
      expect(other2.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other2.measureDistance, equals(5));

      final other3 = details[3];
      expect(other3.domain, equals('camp0'));
      expect(other3.series?.id, equals('bar1'));
      expect(other3.datum, equals(seriesList[3].data[0]));
      expect(other3.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other3.measureDistance, equals(15));
    });

    test('hit test works between bars in a group', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: false,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<String>>[
        makeSeries(id: 'foo', vertical: false),
        makeSeries(id: 'bar', vertical: false),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 5.0, 20.0 + 10.0 + 50.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals('camp0'));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(1));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals('camp0'));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(1));
      expect(next.measureDistance, equals(5));
    });
  });

  /////////////////////////////////////////
  // Bar renderer with datetime axis
  /////////////////////////////////////////
  group('with date time axis and vertical bar', () {
    test('hit test works on bar', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.stacked);
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(1));
      final closest = details[0];
      expect(closest.domain, equals(date0));
      expect(closest.series, equals(seriesList[0]));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));
    });

    test('hit test expands to grouped bars', () {
      // Setup
      final renderer =
          makeBarRenderer(vertical: true, groupType: BarGroupingType.grouped);
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo'),
        makeDateTimeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals(date0));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(0));

      final next = details[1];
      expect(next.domain, equals(date0));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(31)); // 2 + 49 - 20
      expect(next.measureDistance, equals(0));
    });

    test('hit test expands to stacked bar targets', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.stacked,
      );
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo'),
        makeDateTimeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 13.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals(date0));
      expect(closest.series?.id, equals('bar'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals(date0));
      expect(next.series?.id, equals('foo'));
      expect(next.datum, equals(seriesList[0].data[0]));
      expect(next.domainDistance, equals(0));
      expect(next.measureDistance, equals(15.0));
    });

    test('hit test expands to grouped stacked', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.groupedStacked,
      );
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo0', seriesCategory: 'c0'),
        makeDateTimeSeries(id: 'bar0', seriesCategory: 'c0'),
        makeDateTimeSeries(id: 'foo1', seriesCategory: 'c1'),
        makeDateTimeSeries(id: 'bar1', seriesCategory: 'c1'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 20.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(4));

      // For vertical stacked bars, the first series is at the top of the stack.
      final closest = details[0];
      expect(closest.domain, equals(date0));
      expect(closest.series?.id, equals('bar0'));
      expect(closest.datum, equals(seriesList[1].data[0]));
      expect(closest.domainDistance, equals(0));
      expect(closest.measureDistance, equals(5));

      final other1 = details[1];
      expect(other1.domain, equals(date0));
      expect(other1.series?.id, equals('foo0'));
      expect(other1.datum, equals(seriesList[0].data[0]));
      expect(other1.domainDistance, equals(0));
      expect(other1.measureDistance, equals(15));

      final other2 = details[2];
      expect(other2.domain, equals(date0));
      expect(other2.series?.id, equals('bar1'));
      expect(other2.datum, equals(seriesList[3].data[0]));
      expect(other2.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other2.measureDistance, equals(5));

      final other3 = details[3];
      expect(other3.domain, equals(date0));
      expect(other3.series?.id, equals('foo1'));
      expect(other3.datum, equals(seriesList[2].data[0]));
      expect(other3.domainDistance, equals(31)); // 2 + 49 - 20
      expect(other3.measureDistance, equals(15));
    });

    test('hit test works between targets in a group', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo'),
        makeDateTimeSeries(id: 'bar'),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(70.0 + 10.0 + 50.0, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(2));

      final closest = details[0];
      expect(closest.domain, equals(date0));
      expect(closest.series?.id, equals('foo'));
      expect(closest.datum, equals(seriesList[0].data[0]));
      expect(closest.domainDistance, equals(1));
      expect(closest.measureDistance, equals(5));

      final next = details[1];
      expect(next.domain, equals(date0));
      expect(next.series?.id, equals('bar'));
      expect(next.datum, equals(seriesList[1].data[0]));
      expect(next.domainDistance, equals(1));
      expect(next.measureDistance, equals(5));
    });

    test('no selection for targets outside of viewport', () {
      // Setup
      final renderer = makeBarTargetRenderer(
        vertical: true,
        groupType: BarGroupingType.grouped,
      );
      final seriesList = <MutableSeries<DateTime>>[
        makeDateTimeSeries(id: 'foo')
          ..data.add(MyDateTimeRow(dateOutsideViewport, 20)),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      // Note: point is in the axis, over a bar outside of the viewport.
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point<double>(65, 20.0 + 100.0 - 5.0),
        selectNearestByDomain,
        null,
      );

      // Verify
      expect(details.length, equals(0));
    });
  });
}
