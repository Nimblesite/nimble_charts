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

import 'package:nimble_charts_common/src/chart/cartesian/axis/linear/linear_scale.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/numeric_extents.dart'
    show NumericExtents;
import 'package:nimble_charts_common/src/chart/cartesian/axis/scale.dart'
    show RangeBandConfig, ScaleOutputExtent, StepSizeConfig;
import 'package:test/test.dart';

const EPSILON = 0.001;

void main() {
  group('Stacking bars', () {
    test('basic apply survives copy and reset', () {
      final scale = LinearScale()
        ..addDomain(100.0)
        ..addDomain(130.0)
        ..addDomain(200.0)
        ..addDomain(170.0)
        ..range = const ScaleOutputExtent(2000, 1000);

      expect(scale.range!.start, equals(2000));
      expect(scale.range!.end, equals(1000));
      expect(scale.range!.diff, equals(-1000));

      expect(scale.dataExtent.min, equals(100.0));
      expect(scale.dataExtent.max, equals(200.0));

      expect(scale[100.0], closeTo(2000, EPSILON));
      expect(scale[200.0], closeTo(1000, EPSILON));
      expect(scale[166.0], closeTo(1340, EPSILON));
      expect(scale[0.0], closeTo(3000, EPSILON));
      expect(scale[300.0], closeTo(0, EPSILON));

      // test copy
      final other = scale.copy();
      expect(other[166.0], closeTo(1340, EPSILON));
      expect(other.range!.start, equals(2000));
      expect(other.range!.end, equals(1000));

      // test reset
      other
        ..resetDomain()
        ..resetViewportSettings()
        ..addDomain(10.0)
        ..addDomain(20.0);
      expect(other.dataExtent.min, equals(10.0));
      expect(other.dataExtent.max, equals(20.0));
      expect(other.viewportDomain.min, equals(10.0));
      expect(other.viewportDomain.max, equals(20.0));

      expect(other[15.0], closeTo(1500, EPSILON));
      // original scale shouldn't have been touched.
      expect(scale[166.0], closeTo(1340, EPSILON));

      // should always return true.
      expect(scale.canTranslate(3.14), isTrue);
    });

    test('viewport assigned domain extent applies to scale', () {
      final scale = LinearScale()
        ..keepViewportWithinData = false
        ..addDomain(50.0)
        ..addDomain(70.0)
        ..viewportDomain = const NumericExtents(100.0, 200.0)
        ..range = const ScaleOutputExtent(0, 200);

      expect(scale[200.0], closeTo(200, EPSILON));
      expect(scale[100.0], closeTo(0, EPSILON));
      expect(scale[50.0], closeTo(-100, EPSILON));
      expect(scale[150.0], closeTo(100, EPSILON));

      scale
        ..resetDomain()
        ..resetViewportSettings()
        ..addDomain(50.0)
        ..addDomain(100.0)
        ..viewportDomain = const NumericExtents(0.0, 100.0)
        ..range = const ScaleOutputExtent(0, 200);

      expect(scale[0.0], closeTo(0, EPSILON));
      expect(scale[100.0], closeTo(200, EPSILON));
      expect(scale[50.0], closeTo(100, EPSILON));
      expect(scale[200.0], closeTo(400, EPSILON));
    });

    test('comparing domain and range to viewport handles extent edges', () {
      final scale = LinearScale()
        ..range = const ScaleOutputExtent(1000, 1400)
        ..domainOverride = const NumericExtents(100.0, 300.0)
        ..viewportDomain = const NumericExtents(200.0, 300.0);

      expect(scale.viewportDomain, equals(const NumericExtents(200.0, 300.0)));

      expect(scale[210.0], closeTo(1040, EPSILON));
      expect(scale[400.0], closeTo(1800, EPSILON));
      expect(scale[100.0], closeTo(600, EPSILON));

      expect(scale.compareDomainValueToViewport(199.0), equals(-1));
      expect(scale.compareDomainValueToViewport(200.0), equals(0));
      expect(scale.compareDomainValueToViewport(201.0), equals(0));
      expect(scale.compareDomainValueToViewport(299.0), equals(0));
      expect(scale.compareDomainValueToViewport(300.0), equals(0));
      expect(scale.compareDomainValueToViewport(301.0), equals(1));

      expect(scale.isRangeValueWithinViewport(999), isFalse);
      expect(scale.isRangeValueWithinViewport(1100), isTrue);
      expect(scale.isRangeValueWithinViewport(1401), isFalse);
    });

    test('scale applies in reverse', () {
      final scale = LinearScale()
        ..range = const ScaleOutputExtent(1000, 1400)
        ..domainOverride = const NumericExtents(100.0, 300.0)
        ..viewportDomain = const NumericExtents(200.0, 300.0);

      expect(scale.reverse(1040), closeTo(210.0, EPSILON));
      expect(scale.reverse(1800), closeTo(400.0, EPSILON));
      expect(scale.reverse(600), closeTo(100.0, EPSILON));
    });

    test('scale works with a range from larger to smaller', () {
      final scale = LinearScale()
        ..range = const ScaleOutputExtent(1400, 1000)
        ..domainOverride = const NumericExtents(100.0, 300.0)
        ..viewportDomain = const NumericExtents(200.0, 300.0);

      expect(scale[200.0], closeTo(1400.0, EPSILON));
      expect(scale[250.0], closeTo(1200.0, EPSILON));
      expect(scale[300.0], closeTo(1000.0, EPSILON));
    });

    test('scaleFactor and translate applies to scale', () {
      final scale = LinearScale()
        ..range = const ScaleOutputExtent(1000, 1200)
        ..domainOverride = const NumericExtents(100.0, 200.0)
        ..setViewportSettings(4, -50);

      expect(scale[100.0], closeTo(950.0, EPSILON));
      expect(scale[200.0], closeTo(1750.0, EPSILON));
      expect(scale[150.0], closeTo(1350.0, EPSILON));
      expect(scale[106.25], closeTo(1000.0, EPSILON));
      expect(scale[131.25], closeTo(1200.0, EPSILON));

      expect(scale.compareDomainValueToViewport(106.0), equals(-1));
      expect(scale.compareDomainValueToViewport(106.25), equals(0));
      expect(scale.compareDomainValueToViewport(107.0), equals(0));

      expect(scale.compareDomainValueToViewport(131.0), equals(0));
      expect(scale.compareDomainValueToViewport(131.25), equals(0));
      expect(scale.compareDomainValueToViewport(132.0), equals(1));

      expect(scale.isRangeValueWithinViewport(999), isFalse);
      expect(scale.isRangeValueWithinViewport(1100), isTrue);
      expect(scale.isRangeValueWithinViewport(1201), isFalse);
    });

    test('scale handles single point', () {
      final domainScale = LinearScale()
        ..range = const ScaleOutputExtent(1000, 1200)
        ..addDomain(50.0);

      // A single point should render in the middle of the scale.
      expect(domainScale[50.0], closeTo(1100.0, EPSILON));
    });

    test('testAllZeros', () {
      final measureScale = LinearScale()
        ..range = const ScaleOutputExtent(1000, 1200)
        ..addDomain(0.0);

      expect(measureScale[0.0], closeTo(1100.0, EPSILON));
    });

    test('scale calculates step size', () {
      final scale = LinearScale()
        ..rangeBandConfig = RangeBandConfig.percentOfStep(1)
        ..addDomain(1.0)
        ..addDomain(3.0)
        ..addDomain(11.0)
        ..range = const ScaleOutputExtent(100, 200);

      // 1 - 11 has 6 steps of size 2, 0 - 12
      expect(scale.rangeBand, closeTo(100.0 / 6.0, EPSILON));
    });

    test('scale applies rangeBand to detected step size', () {
      final scale = LinearScale()
        ..rangeBandConfig = RangeBandConfig.percentOfStep(0.5)
        ..addDomain(1.0)
        ..addDomain(2.0)
        ..addDomain(10.0)
        ..range = const ScaleOutputExtent(100, 200);

      // 100 range / 10 steps * 0.5percentStep = 5
      expect(scale.rangeBand, closeTo(5.0, EPSILON));
    });

    test('scale stepSize calculation survives copy', () {
      final scale = LinearScale()
        ..stepSizeConfig = const StepSizeConfig.fixedDomain(1)
        ..rangeBandConfig = RangeBandConfig.percentOfStep(1)
        ..addDomain(1.0)
        ..addDomain(3.0)
        ..range = const ScaleOutputExtent(100, 200);
      expect(scale.copy().rangeBand, closeTo(100.0 / 3.0, EPSILON));
    });

    test('scale rangeBand calculation survives copy', () {
      final scale = LinearScale()
        ..rangeBandConfig = const RangeBandConfig.fixedPixel(123)
        ..addDomain(1.0)
        ..addDomain(3.0)
        ..range = const ScaleOutputExtent(100, 200);

      expect(scale.copy().rangeBand, closeTo(123, EPSILON));
    });

    test('scale rangeBand works for single domain value', () {
      final scale = LinearScale()
        ..rangeBandConfig = RangeBandConfig.percentOfStep(1)
        ..addDomain(1.0)
        ..range = const ScaleOutputExtent(100, 200);

      expect(scale.rangeBand, closeTo(100, EPSILON));
    });

    test('scale rangeBand works for multiple domains of the same value', () {
      final scale = LinearScale()
        ..rangeBandConfig = RangeBandConfig.percentOfStep(1)
        ..addDomain(1.0)
        ..addDomain(1.0)
        ..range = const ScaleOutputExtent(100, 200);

      expect(scale.rangeBand, closeTo(100.0, EPSILON));
    });

    test('scale rangeBand is zero when no domains are added', () {
      final scale = LinearScale()..range = const ScaleOutputExtent(100, 200);

      expect(scale.rangeBand, closeTo(0.0, EPSILON));
    });

    test('scale domain info reset on resetDomain', () {
      final scale = LinearScale()
        ..addDomain(1.0)
        ..addDomain(3.0)
        ..range = const ScaleOutputExtent(100, 200)
        ..setViewportSettings(1000, 2000)
        ..resetDomain()
        ..resetViewportSettings();
      expect(scale.viewportScalingFactor, closeTo(1.0, EPSILON));
      expect(scale.viewportTranslatePx, closeTo(0, EPSILON));
      expect(scale.range, equals(const ScaleOutputExtent(100, 200)));
    });

    // [MutableScale.addDomain] doesn't allow nulls, yet
    // LinearScaleDomainInfo.addDomainValue does. Leaving this
    // here for posterity, but the library does not support nulls
    // in this way currently
    test(
      'scale handles null domain values',
      () {
        final scale = LinearScale()
          ..rangeBandConfig = RangeBandConfig.percentOfStep(1)
          ..addDomain(1.0)
          // ..addDomain(null)
          ..addDomain(3.0)
          ..addDomain(11.0)
          ..range = const ScaleOutputExtent(100, 200);

        expect(scale.rangeBand, closeTo(100.0 / 6.0, EPSILON));
      },
      skip: true,
    );

    test('scale domainOverride survives copy', () {
      final scale = LinearScale()
        ..keepViewportWithinData = false
        ..addDomain(1.0)
        ..addDomain(3.0)
        ..range = const ScaleOutputExtent(100, 200)
        ..setViewportSettings(2, 10)
        ..domainOverride = const NumericExtents(0.0, 100.0);

      final other = scale.copy();

      expect(other.domainOverride, equals(const NumericExtents(0.0, 100.0)));
      expect(other[5.0], closeTo(120.0, EPSILON));
    });

    test('scale calculates a scaleFactor given a domain window', () {
      final scale = LinearScale()
        ..addDomain(100.0)
        ..addDomain(130.0)
        ..addDomain(200.0)
        ..addDomain(170.0);

      expect(scale.computeViewportScaleFactor(10), closeTo(10, EPSILON));
      expect(scale.computeViewportScaleFactor(100), closeTo(1, EPSILON));
    });
  });
}
