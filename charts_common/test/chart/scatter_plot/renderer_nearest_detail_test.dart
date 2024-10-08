import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/common.dart';
import 'package:test/test.dart';

import '../../mox.mocks.dart';

/// Datum/Row for the chart.
class MyRow {
  MyRow(
    this.campaignString,
    this.campaign,
    this.clickCount,
    this.radius,
    this.boundsRadius,
    this.shape,
  );
  final String campaignString;
  final int campaign;
  final int clickCount;
  final double radius;
  final double boundsRadius;
  final String shape;
}

void main() {
  late Rectangle<int> layout;

  MutableSeries<num> makeSeries({required String id, String? seriesCategory}) {
    final data = <MyRow>[];

    final series = MutableSeries(
      Series<MyRow, num>(
        id: id,
        data: data,
        radiusPxFn: (row, _) => row.radius,
        domainFn: (row, _) => row.campaign,
        measureFn: (row, _) => row.clickCount,
        seriesCategory: seriesCategory,
      ),
    )
      ..measureOffsetFn = ((_) => 0.0)
      ..colorFn = (_) => Color.fromHex(code: '#000000');

    // Mock the Domain axis results.
    final domainAxis = MockAxis<num>();
    when(domainAxis.rangeBand).thenReturn(100);

    when(domainAxis.getLocation(any))
        .thenAnswer((input) => 1.0 * (input.positionalArguments.first as num));
    series.setAttr(domainAxisKey, domainAxis);

    // Mock the Measure axis results.
    final measureAxis = MockAxis<num>();
    when(measureAxis.getLocation(any))
        .thenAnswer((input) => 1.0 * (input.positionalArguments.first as num));
    series.setAttr(measureAxisKey, measureAxis);

    return series;
  }

  setUp(() {
    layout = const Rectangle<int>(0, 0, 200, 100);
  });

  group('getNearestDatumDetailPerSeries', () {
    test(
        'with both selectOverlappingPoints and selectOverlappingPoints set to '
        'false', () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 20, 30, 6, 0, ''),
            MyRow('point2', 15, 20, 3, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(10, 20),
        false,
        layout,
        selectExactEventLocation: false,
        selectOverlappingPoints: false,
      );

      // Only the point nearest to the event location returned.
      expect(details.length, equals(1));
      expect((details.first.datum as MyRow).campaignString, 'point2');
    });

    test(
        'with both selectOverlappingPoints and selectOverlappingPoints set to '
        'true and there are points inside event', () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 15, 0, ''),
            MyRow('point2', 10, 20, 5, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(13, 23),
        false,
        layout,
        selectExactEventLocation: true,
        selectOverlappingPoints: true,
      );

      // Return only points inside the event location and skip other.
      expect(details.length, equals(2));
      expect((details[0].datum as MyRow).campaignString, 'point1');
      expect((details[1].datum as MyRow).campaignString, 'point2');
    });

    test(
        'with both selectOverlappingPoints and selectOverlappingPoints set to '
        'true and there are NO points inside event', () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 2, 0, ''),
            MyRow('point2', 10, 20, 3, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(5, 10),
        false,
        layout,
        selectExactEventLocation: true,
        selectOverlappingPoints: true,
      );

      // Since there are no points inside event, empty list is returned.
      expect(details.length, equals(0));
    });

    test(
        'with both selectOverlappingPoints == true and '
        'selectOverlappingPoints == false and there are points inside event',
        () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 15, 0, ''),
            MyRow('point2', 10, 20, 5, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(13, 23),
        false,
        layout,
        selectExactEventLocation: false,
        selectOverlappingPoints: true,
      );

      // Points inside the event location are returned.
      expect(details.length, equals(2));
      expect((details[0].datum as MyRow).campaignString, 'point1');
      expect((details[1].datum as MyRow).campaignString, 'point2');
    });

    test(
        'with both selectOverlappingPoints == true and '
        'selectOverlappingPoints == false and there are NO points inside event',
        () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 2, 0, ''),
            MyRow('point2', 10, 20, 3, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(5, 10),
        false,
        layout,
        selectExactEventLocation: false,
        selectOverlappingPoints: true,
      );

      // There are no points inside, so single nearest point is returned.
      expect(details.length, equals(1));
      expect((details[0].datum as MyRow).campaignString, 'point2');
    });

    test(
        'with both selectOverlappingPoints == false and '
        'selectOverlappingPoints == true and there are points inside event',
        () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 15, 0, ''),
            MyRow('point2', 10, 20, 5, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(13, 23),
        false,
        layout,
        selectExactEventLocation: true,
        selectOverlappingPoints: false,
      );

      // Only the nearest point from inside event location is returned.
      expect(details.length, equals(1));
      expect((details[0].datum as MyRow).campaignString, 'point2');
    });

    test(
        'with both selectOverlappingPoints == false and '
        'selectOverlappingPoints == true and there are NO points inside event',
        () {
      // Setup
      final renderer = PointRenderer<num>(config: PointRendererConfig())
        ..layout(layout, layout);
      final seriesList = <MutableSeries<num>>[
        makeSeries(id: 'foo')
          ..data.addAll(<MyRow>[
            MyRow('point1', 15, 30, 2, 0, ''),
            MyRow('point2', 10, 20, 3, 0, ''),
            MyRow('point3', 30, 40, 4, 0, ''),
          ]),
      ];
      renderer
        ..configureSeries(seriesList)
        ..preprocessSeries(seriesList)
        ..update(seriesList, false)
        ..paint(MockCanvas(), 1);

      // Act
      final details = renderer.getNearestDatumDetailPerSeries(
        const Point(5, 10),
        false,
        layout,
        selectExactEventLocation: true,
        selectOverlappingPoints: false,
      );

      // No points inside event, so empty list is returned.
      expect(details.length, equals(0));
    });
  });
}
