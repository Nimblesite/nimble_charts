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

import 'package:collection/collection.dart' show ListEquality;
import 'package:flutter/widgets.dart'
    show BuildContext, EdgeInsets, Widget, hashValues;
import 'package:meta/meta.dart' show immutable;
import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show BuildableBehavior, ChartBehavior, GestureType;
import 'package:nimble_charts/src/behaviors/legend/legend.dart'
    show TappableLegend;
import 'package:nimble_charts/src/behaviors/legend/legend_content_builder.dart'
    show LegendContentBuilder, TabularLegendContentBuilder;
import 'package:nimble_charts/src/behaviors/legend/legend_layout.dart'
    show TabularLegendLayout;
import 'package:nimble_charts/src/chart_container.dart'
    show ChartContainerRenderObject;
import 'package:nimble_charts_common/common.dart' as common
    show
        BehaviorPosition,
        ChartBehavior,
        InsideJustification,
        LegendDefaultMeasure,
        LegendEntry,
        LegendTapHandling,
        MeasureFormatter,
        OutsideJustification,
        SelectionModelType,
        SeriesLegend,
        TextStyleSpec;

/// Series legend behavior for charts.
@immutable
class SeriesLegend<D> extends ChartBehavior<D> {
  /// Create a new tabular layout legend.
  ///
  /// By default, the legend is place above the chart and horizontally aligned
  /// to the start of the draw area.
  ///
  /// [position] the legend will be positioned relative to the chart. Default
  /// position is top.
  ///
  /// [outsideJustification] justification of the legend relative to the chart
  /// if the position is top, bottom, left, right. Default to start of the draw
  /// area.
  ///
  /// [insideJustification] justification of the legend relative to the chart if
  /// the position is inside. Default to top of the chart, start of draw area.
  /// Start of draw area means left for LTR directionality, and right for RTL.
  ///
  /// [horizontalFirst] if true, legend entries will grow horizontally first
  /// instead of vertically first. If the position is top, bottom, or inside,
  /// this defaults to true. Otherwise false.
  ///
  /// [desiredMaxRows] the max rows to use before layout out items in a new
  /// column. By default there is no limit. The max columns created is the
  /// smaller of desiredMaxRows and number of legend entries.
  ///
  /// [desiredMaxColumns] the max columns to use before laying out items in a
  /// new row. By default there is no limit. The max columns created is the
  /// smaller of desiredMaxColumns and number of legend entries.
  ///
  /// [defaultHiddenSeries] lists the IDs of series that should be hidden on
  /// first chart draw.
  ///
  /// [showMeasures] show measure values for each series.
  ///
  /// [legendDefaultMeasure] if measure should show when there is no selection.
  /// This is set to none by default (only shows measure for selected data).
  ///
  /// [measureFormatter] formats measure value if measures are shown.
  ///
  /// [secondaryMeasureFormatter] formats measures if measures are shown for the
  /// series that uses secondary measure axis.
  factory SeriesLegend({
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    bool? horizontalFirst,
    int? desiredMaxRows,
    int? desiredMaxColumns,
    EdgeInsets? cellPadding,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    common.LegendDefaultMeasure? legendDefaultMeasure,
    common.MeasureFormatter? measureFormatter,
    common.MeasureFormatter? secondaryMeasureFormatter,
    common.TextStyleSpec? entryTextStyle,
  }) {
    // Set defaults if empty.
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;
    cellPadding ??= defaultCellPadding;

    // Set the tabular layout settings to match the position if it is not
    // specified.
    horizontalFirst ??= position == common.BehaviorPosition.top ||
        position == common.BehaviorPosition.bottom ||
        position == common.BehaviorPosition.inside;
    final layoutBuilder = horizontalFirst
        ? TabularLegendLayout.horizontalFirst(
            desiredMaxColumns: desiredMaxColumns,
            cellPadding: cellPadding,
          )
        : TabularLegendLayout.verticalFirst(
            desiredMaxRows: desiredMaxRows,
            cellPadding: cellPadding,
          );

    return SeriesLegend._internal(
      contentBuilder: TabularLegendContentBuilder(legendLayout: layoutBuilder),
      selectionModelType: common.SelectionModelType.info,
      position: position,
      outsideJustification: outsideJustification,
      insideJustification: insideJustification,
      defaultHiddenSeries: defaultHiddenSeries,
      showMeasures: showMeasures ?? false,
      legendDefaultMeasure:
          legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
      measureFormatter: measureFormatter,
      secondaryMeasureFormatter: secondaryMeasureFormatter,
      entryTextStyle: entryTextStyle,
    );
  }

  /// Create a legend with custom layout.
  ///
  /// By default, the legend is place above the chart and horizontally aligned
  /// to the start of the draw area.
  ///
  /// [contentBuilder] builder for the custom layout.
  ///
  /// [position] the legend will be positioned relative to the chart. Default
  /// position is top.
  ///
  /// [outsideJustification] justification of the legend relative to the chart
  /// if the position is top, bottom, left, right. Default to start of the draw
  /// area.
  ///
  /// [insideJustification] justification of the legend relative to the chart if
  /// the position is inside. Default to top of the chart, start of draw area.
  /// Start of draw area means left for LTR directionality, and right for RTL.
  ///
  /// [defaultHiddenSeries] lists the IDs of series that should be hidden on
  /// first chart draw.
  ///
  /// [showMeasures] show measure values for each series.
  ///
  /// [legendDefaultMeasure] if measure should show when there is no selection.
  /// This is set to none by default (only shows measure for selected data).
  ///
  /// [measureFormatter] formats measure value if measures are shown.
  ///
  /// [secondaryMeasureFormatter] formats measures if measures are shown for the
  /// series that uses secondary measure axis.
  factory SeriesLegend.customLayout(
    LegendContentBuilder contentBuilder, {
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    common.LegendDefaultMeasure? legendDefaultMeasure,
    common.MeasureFormatter? measureFormatter,
    common.MeasureFormatter? secondaryMeasureFormatter,
    common.TextStyleSpec? entryTextStyle,
  }) {
    // Set defaults if empty.
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;

    return SeriesLegend._internal(
      contentBuilder: contentBuilder,
      selectionModelType: common.SelectionModelType.info,
      position: position,
      outsideJustification: outsideJustification,
      insideJustification: insideJustification,
      defaultHiddenSeries: defaultHiddenSeries,
      showMeasures: showMeasures ?? false,
      legendDefaultMeasure:
          legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
      measureFormatter: measureFormatter,
      secondaryMeasureFormatter: secondaryMeasureFormatter,
      entryTextStyle: entryTextStyle,
    );
  }

  SeriesLegend._internal({
    required this.contentBuilder,
    required this.position,
    required this.outsideJustification,
    required this.insideJustification,
    required this.showMeasures,
    this.selectionModelType,
    this.defaultHiddenSeries,
    this.legendDefaultMeasure,
    this.measureFormatter,
    this.secondaryMeasureFormatter,
    this.entryTextStyle,
  });
  static const defaultBehaviorPosition = common.BehaviorPosition.top;
  static const defaultOutsideJustification =
      common.OutsideJustification.startDrawArea;
  static const defaultInsideJustification = common.InsideJustification.topStart;

  @override
  final desiredGestures = <GestureType>{};

  /// The type of selection model to monitor for legend updates.
  final common.SelectionModelType? selectionModelType;

  /// Builder for creating custom legend content.
  final LegendContentBuilder contentBuilder;

  /// Position of the legend relative to the chart.
  final common.BehaviorPosition position;

  /// Justification of the legend relative to the chart
  final common.OutsideJustification outsideJustification;

  /// Justification of the legend relative to the chart if position is inside.
  final common.InsideJustification insideJustification;

  /// Whether or not the legend should show measures.
  ///
  /// By default this is false, measures are not shown. When set to true, the
  /// default behavior is to show measure only if there is selected data.
  /// Please set [legendDefaultMeasure] to something other than none to enable
  /// showing measures when there is no selection.
  ///
  /// This flag is used by the [contentBuilder], so a custom content builder
  /// has to choose if it wants to use this flag.
  final bool showMeasures;

  /// Option to show measures when selection is null.
  ///
  /// By default this is set to none, so no measures are shown when there is
  /// no selection.
  final common.LegendDefaultMeasure? legendDefaultMeasure;

  /// Formatter for measure value(s) if the measures are shown on the legend.
  final common.MeasureFormatter? measureFormatter;

  /// Formatter for secondary measure value(s) if the measures are shown on the
  /// legend and the series uses the secondary axis.
  final common.MeasureFormatter? secondaryMeasureFormatter;

  /// Styles for legend entry label text.
  final common.TextStyleSpec? entryTextStyle;

  /// List of series IDs that should be hidden on first chart draw.
  final List<String>? defaultHiddenSeries;

  /// Default padding around each legend cell.
  static const defaultCellPadding = EdgeInsets.all(8);

  @override
  common.SeriesLegend<D> createCommonBehavior() =>
      _FlutterSeriesLegend<D>(this);

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {
    (commonBehavior as _FlutterSeriesLegend).config = this;
  }

  /// All Legend behaviors get the same role ID, because you should only have
  /// one legend on a chart.
  @override
  String get role => 'legend';

  @override
  bool operator ==(Object other) =>
      other is SeriesLegend &&
      selectionModelType == other.selectionModelType &&
      contentBuilder == other.contentBuilder &&
      position == other.position &&
      outsideJustification == other.outsideJustification &&
      insideJustification == other.insideJustification &&
      const ListEquality()
          .equals(defaultHiddenSeries, other.defaultHiddenSeries) &&
      showMeasures == other.showMeasures &&
      legendDefaultMeasure == other.legendDefaultMeasure &&
      measureFormatter == other.measureFormatter &&
      secondaryMeasureFormatter == other.secondaryMeasureFormatter &&
      entryTextStyle == other.entryTextStyle;

  @override
  int get hashCode => Object.hash(
        selectionModelType,
        contentBuilder,
        position,
        outsideJustification,
        insideJustification,
        defaultHiddenSeries,
        showMeasures,
        legendDefaultMeasure,
        measureFormatter,
        secondaryMeasureFormatter,
        entryTextStyle,
      );
}

/// Flutter specific wrapper on the common Legend for building content.
class _FlutterSeriesLegend<D> extends common.SeriesLegend<D>
    implements BuildableBehavior, TappableLegend {
  _FlutterSeriesLegend(this.config)
      : super(
          selectionModelType: config.selectionModelType,
          measureFormatter: config.measureFormatter,
          secondaryMeasureFormatter: config.secondaryMeasureFormatter,
          legendDefaultMeasure: config.legendDefaultMeasure,
        ) {
    super.defaultHiddenSeries = config.defaultHiddenSeries;
    super.entryTextStyle = config.entryTextStyle;
  }
  SeriesLegend config;

  @override
  void updateLegend() {
    (chartContext as ChartContainerRenderObject).requestRebuild();
  }

  @override
  common.BehaviorPosition get position => config.position;

  @override
  common.OutsideJustification get outsideJustification =>
      config.outsideJustification;

  @override
  common.InsideJustification get insideJustification =>
      config.insideJustification;

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        legendState.legendEntries.any((entry) => entry.isSelected);

    // Show measures if [showMeasures] is true and there is a selection or if
    // showing measures when there is no selection.
    final showMeasures = config.showMeasures &&
        (hasSelection ||
            legendDefaultMeasure != common.LegendDefaultMeasure.none);

    return config.contentBuilder
        .build(context, legendState, this, showMeasures: showMeasures);
  }

  @override
  void onLegendEntryTapUp(common.LegendEntry detail) {
    switch (legendTapHandling) {
      case common.LegendTapHandling.hide:
        _hideSeries(detail);

      case common.LegendTapHandling.none:
        break;
    }
  }

  /// Handles tap events by hiding or un-hiding entries tapped in the legend.
  ///
  /// Tapping on a visible series in the legend will hide it. Tapping on a
  /// hidden series will make it visible again.
  void _hideSeries(common.LegendEntry detail) {
    final seriesId = detail.series.id;

    // Handle the event by toggling the hidden state of the target.
    if (isSeriesHidden(seriesId)) {
      showSeries(seriesId);
    } else {
      hideSeries(seriesId);
    }

    // Redraw the chart to actually hide hidden series.
    chart.redraw(skipLayout: true);
  }
}
