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

// ignore_for_file: sort_constructors_first

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/bar/bar_renderer.dart';
import 'package:nimble_charts_common/src/chart/bar/bar_renderer_config.dart';
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer.dart';
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer_config.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart';
import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show MutableSeries;
import 'package:nimble_charts_common/src/common/color.dart';
import 'package:nimble_charts_common/src/common/material_palette.dart'
    show MaterialPalette;
import 'package:nimble_charts_common/src/data/series.dart' show Series;
import 'package:test/test.dart';

import '../../mox.mocks.dart';

/// Datum/Row for the chart.
class MyRow {
  final String campaign;
  final int? clickCount;
  MyRow(this.campaign, this.clickCount);
}

class FakeBarRenderer<D> extends BarRenderer<D> {
  int paintBarCallCount = 0;
  List<List<BarRendererElement<D>>> elementsPainted = [];

  factory FakeBarRenderer({
    required BarRendererConfig<D> config,
    required String rendererId,
  }) =>
      FakeBarRenderer._internal(config: config, rendererId: rendererId);

  FakeBarRenderer._internal({
    required super.config,
    required super.rendererId,
  }) : super.internal();

  @override
  void paintBar(
    ChartCanvas canvas,
    double animationPercent,
    Iterable<BarRendererElement<D>> barElements,
  ) {
    paintBarCallCount += 1;
    elementsPainted.add(List.of(barElements));
  }
}

void main() {
  // ignore: unused_local_variable
  late BarRenderer<dynamic> renderer;
  late List<MutableSeries<String>> seriesList;
  late List<MutableSeries<String>> groupedStackedSeriesList;

  /////////////////////////////////////////
  // Convenience methods for creating mocks.
  /////////////////////////////////////////
  // ignore: no_leading_underscores_for_local_identifiers
  BaseBarRenderer<dynamic, dynamic, dynamic> _configureBaseRenderer(
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

    return renderer;
  }

  BarRenderer<dynamic> makeRenderer({
    required BarRendererConfig<dynamic> config,
  }) {
    final renderer = BarRenderer(config: config);
    _configureBaseRenderer(renderer, true);
    return renderer;
  }

  FakeBarRenderer<dynamic> makeFakeRenderer({
    required BarRendererConfig<dynamic> config,
  }) {
    final renderer = FakeBarRenderer<dynamic>(
      config: config,
      rendererId: '123',
    );
    _configureBaseRenderer(renderer, true);
    return renderer;
  }

  setUp(() {
    final myFakeDesktopAData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    final myFakeTabletAData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    final myFakeMobileAData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    final myFakeDesktopBData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    final myFakeTabletBData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    final myFakeMobileBData = [
      MyRow('MyCampaign1', 5),
      MyRow('MyCampaign2', 25),
      MyRow('MyCampaign3', 100),
      MyRow('MyOtherCampaign', 75),
    ];

    seriesList = [
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Desktop',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeDesktopAData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Tablet',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeTabletAData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Mobile',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeMobileAData,
        ),
      ),
    ];

    groupedStackedSeriesList = [
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Desktop A',
          seriesCategory: 'A',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeDesktopAData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Tablet A',
          seriesCategory: 'A',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeTabletAData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Mobile A',
          seriesCategory: 'A',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeMobileAData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Desktop B',
          seriesCategory: 'B',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeDesktopBData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Tablet B',
          seriesCategory: 'B',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeTabletBData,
        ),
      ),
      MutableSeries<String>(
        Series<MyRow, String>(
          id: 'Mobile B',
          seriesCategory: 'B',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (row, _) => row.campaign,
          measureFn: (row, _) => row.clickCount,
          measureOffsetFn: (row, _) => 0,
          data: myFakeMobileBData,
        ),
      ),
    ];
  });

  group('preprocess', () {
    test('with grouped bars', () {
      renderer = makeRenderer(
        config: BarRendererConfig(groupingType: BarGroupingType.grouped),
      )..preprocessSeries(seriesList);

      expect(seriesList.length, equals(3));

      // Validate Desktop series.
      var series = seriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Tablet series.
      series = seriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Mobile series.
      series = seriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(2));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with grouped stacked bars', () {
      renderer = makeRenderer(
        config: BarRendererConfig(groupingType: BarGroupingType.groupedStacked),
      )..preprocessSeries(groupedStackedSeriesList);

      expect(groupedStackedSeriesList.length, equals(6));

      // Validate Desktop A series.
      var series = groupedStackedSeriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('A'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet A series.
      series = groupedStackedSeriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('A'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile A series.
      series = groupedStackedSeriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('A'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Desktop B series.
      series = groupedStackedSeriesList[3];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.5));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet B series.
      series = groupedStackedSeriesList[4];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.5));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile B series.
      series = groupedStackedSeriesList[5];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.5));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with stacked bars', () {
      renderer = makeRenderer(
        config: BarRendererConfig(groupingType: BarGroupingType.stacked),
      )..preprocessSeries(seriesList);

      expect(seriesList.length, equals(3));

      // Validate Desktop series.
      var series = seriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet series.
      series = seriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile series.
      series = seriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with stacked bars containing zero and null', () {
      // Set up some nulls and zeros in the data.
      seriesList[2].data[0] = MyRow('MyCampaign1', null);
      seriesList[2].data[2] = MyRow('MyCampaign3', 0);

      seriesList[1].data[1] = MyRow('MyCampaign2', null);
      seriesList[1].data[3] = MyRow('MyOtherCampaign', 0);

      seriesList[0].data[2] = MyRow('MyCampaign3', 0);

      renderer = makeRenderer(
        config: BarRendererConfig(groupingType: BarGroupingType.stacked),
      )..preprocessSeries(seriesList);

      expect(seriesList.length, equals(3));

      // Validate Desktop series.
      var series = seriesList[0];
      var elementsList = series.getAttr(barElementsKey);

      var element = elementsList![0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      element = elementsList[1];
      expect(element.measureOffset, equals(25));
      expect(element.measureOffsetPlusMeasure, equals(50));
      expect(series.measureOffsetFn!(1), equals(25));

      element = elementsList[2];
      expect(element.measureOffset, equals(100));
      expect(element.measureOffsetPlusMeasure, equals(100));
      expect(series.measureOffsetFn!(2), equals(100));

      element = elementsList[3];
      expect(element.measureOffset, equals(75));
      expect(element.measureOffsetPlusMeasure, equals(150));
      expect(series.measureOffsetFn!(3), equals(75));

      // Validate Tablet series.
      series = seriesList[1];

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));

      element = elementsList[1];
      expect(element.measureOffset, equals(25));
      expect(element.measureOffsetPlusMeasure, equals(25));
      expect(series.measureOffsetFn!(1), equals(25));

      element = elementsList[2];
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(100));
      expect(series.measureOffsetFn!(2), equals(0));

      element = elementsList[3];
      expect(element.measureOffset, equals(75));
      expect(element.measureOffsetPlusMeasure, equals(75));
      expect(series.measureOffsetFn!(3), equals(75));

      // Validate Mobile series.
      series = seriesList[2];
      elementsList = series.getAttr(barElementsKey);

      element = elementsList![0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(0));
      expect(series.measureOffsetFn!(0), equals(0));

      element = elementsList[1];
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(25));
      expect(series.measureOffsetFn!(1), equals(0));

      element = elementsList[2];
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(0));
      expect(series.measureOffsetFn!(2), equals(0));

      element = elementsList[3];
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(75));
      expect(series.measureOffsetFn!(3), equals(0));
    });
  });

  group('preprocess weight pattern', () {
    test('with grouped bars', () {
      renderer = makeRenderer(
        config: BarRendererConfig(
          groupingType: BarGroupingType.grouped,
          weightPattern: [3, 2, 1],
        ),
      )..preprocessSeries(seriesList);

      // Verify that bar group weights are proportional to the sum of the used
      // segments of weightPattern. The weightPattern should be distributed
      // amongst bars that share the same domain value.

      expect(seriesList.length, equals(3));

      // Validate Desktop series.
      var series = seriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(0.5));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Tablet series.
      series = seriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.5));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Mobile series.
      series = seriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(2));
      expect(series.getAttr(barGroupCountKey), equals(3));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.5 + 1 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 6));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(null));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with grouped stacked bars', () {
      renderer = makeRenderer(
        config: BarRendererConfig(
          groupingType: BarGroupingType.groupedStacked,
          weightPattern: [2, 1],
        ),
      )..preprocessSeries(groupedStackedSeriesList);

      // Verify that bar group weights are proportional to the sum of the used
      // segments of weightPattern. The weightPattern should be distributed
      // amongst bars that share the same domain and series category values.

      expect(groupedStackedSeriesList.length, equals(6));

      // Validate Desktop A series.
      var series = groupedStackedSeriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(stackKeyKey), equals('A'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet A series.
      series = groupedStackedSeriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(stackKeyKey), equals('A'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile A series.
      series = groupedStackedSeriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(stackKeyKey), equals('A'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));

      // Validate Desktop B series.
      series = groupedStackedSeriesList[3];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet B series.
      series = groupedStackedSeriesList[4];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile B series.
      series = groupedStackedSeriesList[5];
      expect(series.getAttr(barGroupIndexKey), equals(1));
      expect(series.getAttr(barGroupCountKey), equals(2));
      expect(series.getAttr(previousBarGroupWeightKey), equals(2 / 3));
      expect(series.getAttr(barGroupWeightKey), equals(1 / 3));
      expect(series.getAttr(stackKeyKey), equals('B'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with stacked bars - weightPattern not used', () {
      renderer = makeRenderer(
        config: BarRendererConfig(
          groupingType: BarGroupingType.stacked,
          weightPattern: [2, 1],
        ),
      )..preprocessSeries(seriesList);

      // Verify that weightPattern is not used, since stacked bars have only a
      // single group per domain value.

      expect(seriesList.length, equals(3));

      // Validate Desktop series.
      var series = seriesList[0];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      var elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      var element = elementsList[0];
      expect(element.barStackIndex, equals(2));
      expect(element.measureOffset, equals(10));
      expect(element.measureOffsetPlusMeasure, equals(15));
      expect(series.measureOffsetFn!(0), equals(10));

      // Validate Tablet series.
      series = seriesList[1];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(1));
      expect(element.measureOffset, equals(5));
      expect(element.measureOffsetPlusMeasure, equals(10));
      expect(series.measureOffsetFn!(0), equals(5));

      // Validate Mobile series.
      series = seriesList[2];
      expect(series.getAttr(barGroupIndexKey), equals(0));
      expect(series.getAttr(barGroupCountKey), equals(1));
      expect(series.getAttr(previousBarGroupWeightKey), equals(0.0));
      expect(series.getAttr(barGroupWeightKey), equals(1));
      expect(series.getAttr(stackKeyKey), equals('__defaultKey__'));

      elementsList = series.getAttr(barElementsKey);
      expect(elementsList!.length, equals(4));

      element = elementsList[0];
      expect(element.barStackIndex, equals(0));
      expect(element.measureOffset, equals(0));
      expect(element.measureOffsetPlusMeasure, equals(5));
      expect(series.measureOffsetFn!(0), equals(0));
    });

    test('with bar max width', () {
      // Helper to create series list for this test only.
      List<MutableSeries<String>> createSeriesList(List<MyRow> data) {
        final domainAxis = MockAxis<Object>();
        when(domainAxis.rangeBand).thenReturn(100);
        when(domainAxis.getLocation('MyCampaign1')).thenReturn(20);
        when(domainAxis.getLocation('MyCampaign2')).thenReturn(40);
        when(domainAxis.getLocation('MyCampaign3')).thenReturn(60);
        when(domainAxis.getLocation('MyOtherCampaign')).thenReturn(80);
        final measureAxis = MockAxis<num>();
        when(measureAxis.getLocation(0)).thenReturn(0);
        when(measureAxis.getLocation(5)).thenReturn(5);
        when(measureAxis.getLocation(75)).thenReturn(75);
        when(measureAxis.getLocation(100)).thenReturn(100);

        final color = Color.fromHex(code: '#000000');

        final series = MutableSeries<String>(
          Series<MyRow, String>(
            id: 'Desktop',
            domainFn: (row, _) => row.campaign,
            measureFn: (row, _) => row.clickCount,
            measureOffsetFn: (_, __) => 0,
            colorFn: (_, __) => color,
            fillColorFn: (_, __) => color,
            dashPatternFn: (_, __) => [1],
            data: data,
          ),
        )
          ..setAttr(domainAxisKey, domainAxis)
          ..setAttr(measureAxisKey, measureAxis);

        return [series];
      }

      final canvas = MockCanvas();

      final data = [
        MyRow('MyCampaign1', 5),
        MyRow('MyCampaign2', 0),
        MyRow('MyCampaign3', 100),
        MyRow('MyOtherCampaign', 75),
      ];
      final seriesList = createSeriesList(data);

      final renderer =
          makeFakeRenderer(config: BarRendererConfig(maxBarWidthPx: 40))
            ..preprocessSeries(seriesList)
            ..update(seriesList, false)
            ..paint(canvas, 1);

      expect(renderer.elementsPainted.length, 4);
      for (var i = 0; i < 4; i++) {
        final element = renderer.elementsPainted[i].single;
        expect(element.bounds!.width, 40);
      }
    });
  });

  group('null measure', () {
    test('only include null in draw if animating from a non null measure', () {
      // Helper to create series list for this test only.
      List<MutableSeries<String>> createSeriesList(List<MyRow> data) {
        final domainAxis = MockAxis<Object>();
        when(domainAxis.rangeBand).thenReturn(100);
        when(domainAxis.getLocation('MyCampaign1')).thenReturn(20);
        when(domainAxis.getLocation('MyCampaign2')).thenReturn(40);
        when(domainAxis.getLocation('MyCampaign3')).thenReturn(60);
        when(domainAxis.getLocation('MyOtherCampaign')).thenReturn(80);
        final measureAxis = MockAxis<num>();
        when(measureAxis.getLocation(0)).thenReturn(0);
        when(measureAxis.getLocation(5)).thenReturn(5);
        when(measureAxis.getLocation(75)).thenReturn(75);
        when(measureAxis.getLocation(100)).thenReturn(100);

        final color = Color.fromHex(code: '#000000');

        final series = MutableSeries<String>(
          Series<MyRow, String>(
            id: 'Desktop',
            domainFn: (row, _) => row.campaign,
            measureFn: (row, _) => row.clickCount,
            measureOffsetFn: (_, __) => 0,
            colorFn: (_, __) => color,
            fillColorFn: (_, __) => color,
            dashPatternFn: (_, __) => [1],
            data: data,
          ),
        )
          ..setAttr(domainAxisKey, domainAxis)
          ..setAttr(measureAxisKey, measureAxis);

        return [series];
      }

      final canvas = MockCanvas();

      final myDataWithNull = [
        MyRow('MyCampaign1', 5),
        MyRow('MyCampaign2', null),
        MyRow('MyCampaign3', 100),
        MyRow('MyOtherCampaign', 75),
      ];
      final seriesListWithNull = createSeriesList(myDataWithNull);

      final myDataWithMeasures = [
        MyRow('MyCampaign1', 5),
        MyRow('MyCampaign2', 0),
        MyRow('MyCampaign3', 100),
        MyRow('MyOtherCampaign', 75),
      ];
      final seriesListWithMeasures = createSeriesList(myDataWithMeasures);

      final renderer = makeFakeRenderer(
        config: BarRendererConfig(groupingType: BarGroupingType.grouped),
      )

        // Verify that only 3 bars are drawn for an initial draw with null data.
        ..preprocessSeries(seriesListWithNull)
        ..update(seriesListWithNull, true)
        ..paintBarCallCount = 0
        ..paint(canvas, 0.5);
      expect(renderer.paintBarCallCount, equals(3));

      // On animation complete, verify that only 3 bars are drawn.
      renderer
        ..paintBarCallCount = 0
        ..paint(canvas, 1);
      expect(renderer.paintBarCallCount, equals(3));

      // Change series list where there are measures on all values, verify all
      // 4 bars were drawn
      renderer
        ..preprocessSeries(seriesListWithMeasures)
        ..update(seriesListWithMeasures, true)
        ..paintBarCallCount = 0
        ..paint(canvas, 0.5);
      expect(renderer.paintBarCallCount, equals(4));

      // Change series to one with null measures, verifies all 4 bars drawn
      renderer
        ..preprocessSeries(seriesListWithNull)
        ..update(seriesListWithNull, true)
        ..paintBarCallCount = 0
        ..paint(canvas, 0.5);
      expect(renderer.paintBarCallCount, equals(4));

      // On animation complete, verify that only 3 bars are drawn.
      renderer
        ..paintBarCallCount = 0
        ..paint(canvas, 1);
      expect(renderer.paintBarCallCount, equals(3));
    });
  });

  group('renderer configuration', () {
    test('NoCornerStrategy always equals', () {
      const strategyOne = NoCornerStrategy();
      const strategyTwo = NoCornerStrategy();

      expect(strategyOne, equals(strategyTwo));
    });

    test('CornerStrategy with same radius is equals', () {
      const strategyOne = ConstCornerStrategy(1);
      const strategyTwo = ConstCornerStrategy(1);

      expect(strategyOne, equals(strategyTwo));
    });

    test('CornerStrategy with different radius is not equal', () {
      const strategyOne = ConstCornerStrategy(1);
      const strategyTwo = ConstCornerStrategy(2);

      expect(strategyOne, isNot(equals(strategyTwo)));
    });
  });
}
