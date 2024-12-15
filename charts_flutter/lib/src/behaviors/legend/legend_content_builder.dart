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

import 'package:flutter/widgets.dart' show BuildContext, Widget, hashValues;
import 'package:nimble_charts/src/behaviors/legend/legend.dart';
import 'package:nimble_charts/src/behaviors/legend/legend_entry_layout.dart';
import 'package:nimble_charts/src/behaviors/legend/legend_layout.dart';
import 'package:nimble_charts_common/common.dart' as common
    show Legend, LegendState, SeriesLegend;

/// Strategy for building a legend content widget.
abstract class LegendContentBuilder {
  /// Creates a new [LegendContentBuilder].
  const LegendContentBuilder();

  /// Builds a widget that represents the legend content.
  ///
  /// [context] The build context.
  /// [legendState] The current state of the legend.
  /// [legend] The legend behavior.
  /// [showMeasures] Whether to show measure values in the legend.
  Widget build(
    BuildContext context,
    common.LegendState legendState,
    common.Legend legend, {
    bool showMeasures,
  });
}

/// Base strategy for building a legend content widget.
///
/// Each legend entry is passed to a [LegendLayout] strategy to create a widget
/// for each legend entry. These widgets are then passed to a
/// [LegendEntryLayout] strategy to create the legend widget.
abstract class BaseLegendContentBuilder implements LegendContentBuilder {
  /// Strategy for creating one widget or each legend entry.
  LegendEntryLayout get legendEntryLayout;

  /// Strategy for creating the legend content widget from a list of widgets.
  ///
  /// This is typically the list of widgets from legend entries.
  LegendLayout get legendLayout;

  @override
  Widget build(
    BuildContext context,
    common.LegendState legendState,
    common.Legend legend, {
    bool showMeasures = false,
  }) {
    final entryWidgets = legendState.legendEntries.map((entry) {
      var isHidden = false;
      if (legend is common.SeriesLegend) {
        isHidden = legend.isSeriesHidden(entry.series.id);
      }

      return legendEntryLayout.build(
        context,
        entry,
        legend as TappableLegend,
        isHidden,
        showMeasures: showMeasures,
      );
    }).toList();

    return legendLayout.build(context, entryWidgets);
  }
}

// TODO: Expose settings for tabular layout.
/// Strategy that builds a tabular legend.
///
/// [legendEntryLayout] custom strategy for creating widgets for each legend
/// entry.
/// [legendLayout] custom strategy for creating legend widget from list of
/// widgets that represent a legend entry.
class TabularLegendContentBuilder extends BaseLegendContentBuilder {
  /// Creates a new [TabularLegendContentBuilder].
  ///
  /// [legendEntryLayout] Strategy for creating widgets for each legend entry.
  /// [legendLayout] Strategy for creating legend widget from list of widgets.
  TabularLegendContentBuilder({
    LegendEntryLayout? legendEntryLayout,
    LegendLayout? legendLayout,
  })  : legendEntryLayout =
            legendEntryLayout ?? const SimpleLegendEntryLayout(),
        legendLayout = legendLayout ?? TabularLegendLayout.horizontalFirst();

  /// Strategy for creating widgets for each legend entry.
  @override
  final LegendEntryLayout legendEntryLayout;

  /// Strategy for creating legend widget from list of widgets.
  @override
  final LegendLayout legendLayout;

  @override
  bool operator ==(Object other) =>
      other is TabularLegendContentBuilder &&
      legendEntryLayout == other.legendEntryLayout &&
      legendLayout == other.legendLayout;

  @override
  int get hashCode => Object.hash(legendEntryLayout, legendLayout);
}
