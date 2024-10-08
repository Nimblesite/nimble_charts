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

import 'package:nimble_charts_common/common.dart';
import 'package:nimble_charts_common/src/chart/common/base_renderer_element.dart';

const percentInjectedKey =
    AttributeKey<bool>('PercentInjector.percentInjected');

/// Chart behavior that can inject series or domain percentages into each datum.
///
/// [totalType] configures the type of total to be calculated.
///
/// The measure values of each datum will be replaced by the percent of the
/// total measure value that each represents. The "raw" measure accessor
/// function on [MutableSeries] can still be used to get the original values.
///
/// Note that the results for measureLowerBound and measureUpperBound are not
/// currently well defined when converted into percentage values. This behavior
/// will replace them as percents to prevent bad axis results, but no effort is
/// made to bound them to within a "0 to 100%" data range.
///
/// Note that if the chart has a [Legend] that is capable of hiding series data,
/// then this behavior must be added after the [Legend] to ensure that it
/// calculates values after series have been potentially removed from the list.
class PercentInjector<D> implements ChartBehavior<D, BaseRendererElement<D>> {
  /// Constructs a [PercentInjector].
  ///
  /// [totalType] configures the type of data total to be calculated.
  PercentInjector({this.totalType = PercentInjectorTotalType.domain}) {
    // Set up chart draw cycle listeners.
    _lifecycleListener =
        LifecycleListener<D>(onPreprocess: _preProcess, onData: _onData);
  }
  late final LifecycleListener<D> _lifecycleListener;

  /// The type of data total to be calculated.
  final PercentInjectorTotalType totalType;

  @override
  void attachTo(BaseChart<D, BaseRendererElement<D>> chart) {
    chart.addLifecycleListener(_lifecycleListener);
  }

  @override
  void removeFrom(BaseChart<D, BaseRendererElement<D>> chart) {
    chart.removeLifecycleListener(_lifecycleListener);
  }

  /// Resets the state of the behavior when new data is drawn on the chart.
  void _onData(List<MutableSeries<D>> seriesList) {
    // Reset tracking of percentage injection for new data.
    for (final series in seriesList) {
      series.setAttr(percentInjectedKey, false);
    }
  }

  /// Injects percent of domain and/or series accessor functions into each
  /// series.
  ///
  /// These are injected in the preProcess phase in case other behaviors modify
  /// the [seriesList] between chart redraws.
  void _preProcess(List<MutableSeries<D>> seriesList) {
    var percentInjected = true;
    for (final series in seriesList) {
      percentInjected = percentInjected && series.getAttr(percentInjectedKey)!;
    }

    if (percentInjected) {
      return;
    }

    switch (totalType) {
      case PercentInjectorTotalType.domain:
      case PercentInjectorTotalType.domainBySeriesCategory:
        final totalsByDomain = <String, num>{};

        final useSeriesCategory =
            totalType == PercentInjectorTotalType.domainBySeriesCategory;

        // Walk the series and compute the domain total. Series total is
        // automatically computed by [MutableSeries].
        for (final series in seriesList) {
          final seriesCategory = series.seriesCategory;
          final rawMeasureFn = series.rawMeasureFn;
          final domainFn = series.domainFn;

          for (var index = 0; index < series.data.length; index++) {
            final domain = domainFn(index);
            final measure = rawMeasureFn(index) ?? 0.0;

            final key =
                useSeriesCategory ? '${seriesCategory}__$domain' : '$domain';

            totalsByDomain[key] = (totalsByDomain[key] ?? 0.0) + measure;
          }

          // Add percent of domain and series accessor functions.
          //
          // Replace the default measure accessor with one that computes the
          // percentage.
          series.measureFn = (index) {
            final measure = rawMeasureFn(index);

            if (measure == null || measure == 0.0) {
              return 0.0;
            }

            final domain = domainFn(index);

            final key = useSeriesCategory
                ? '${series.seriesCategory}__$domain'
                : '$domain';

            return measure / totalsByDomain[key]!;
          };

          // Replace the default measure lower bound accessor with one that
          // computes the  percentage.
          if (series.measureLowerBoundFn != null) {
            series.measureLowerBoundFn = (index) {
              final measureLowerBound = series.rawMeasureLowerBoundFn!(index);

              if (measureLowerBound == null || measureLowerBound == 0.0) {
                return 0.0;
              }

              final domain = domainFn(index);

              final key = useSeriesCategory
                  ? '${series.seriesCategory}__$domain'
                  : '$domain';

              return measureLowerBound / totalsByDomain[key]!;
            };
          }

          // Replace the default measure upper bound accessor with one that
          // computes the  percentage.
          if (series.measureUpperBoundFn != null) {
            series.measureUpperBoundFn = (index) {
              final measureUpperBound = series.rawMeasureUpperBoundFn!(index);

              if (measureUpperBound == null || measureUpperBound == 0.0) {
                return 0.0;
              }

              final domain = domainFn(index);

              final key = useSeriesCategory
                  ? '${series.seriesCategory}__$domain'
                  : '$domain';

              return measureUpperBound / totalsByDomain[key]!;
            };
          }

          series.setAttr(percentInjectedKey, true);
        }

      case PercentInjectorTotalType.series:
        for (final series in seriesList) {
          // Replace the default measure accessor with one that computes the
          // percentage.
          series.measureFn = (index) =>
              series.rawMeasureFn(index)! / series.seriesMeasureTotal;

          // Replace the default measure lower bound accessor with one that
          // computes the  percentage.
          if (series.measureLowerBoundFn != null) {
            series.measureLowerBoundFn = (index) =>
                (series.rawMeasureLowerBoundFn!(index) ?? 0) /
                series.seriesMeasureTotal;
          }

          // Replace the default measure upper bound accessor with one that
          // computes the  percentage.
          if (series.measureUpperBoundFn != null) {
            series.measureUpperBoundFn = (index) =>
                (series.rawMeasureUpperBoundFn!(index) ?? 0) /
                series.seriesMeasureTotal;
          }

          series.setAttr(percentInjectedKey, true);
        }
    }
  }

  @override
  String get role => 'PercentInjector';
}

/// Describes the type of data total that will be calculated by PercentInjector.
///
/// [domain] calculates the percentage of each datum's measure value out of the
/// total measure values for all data that share the same domain value.
///
/// [domainBySeriesCategory] calculates the percentage of each datum's measure
/// value out of the total measure values for all data that share the same
/// domain value and seriesCategory value. This should be enabled if the data
/// will be rendered by a series renderer that groups data by both domain and
/// series category, such as the "grouped stacked" mode of [BarRenderer].
///
/// [series] calculates the percentage of each datum's measure value out of the
/// total measure values for all data in that datum's series.
enum PercentInjectorTotalType { domain, domainBySeriesCategory, series }
