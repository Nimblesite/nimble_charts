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

import 'package:nimble_charts_common/src/chart/bar/bar_label_decorator.dart'
    show BarLabelDecorator;
import 'package:nimble_charts_common/src/chart/bar/bar_lane_renderer.dart'
    show BarLaneRenderer;
import 'package:nimble_charts_common/src/chart/bar/bar_renderer_config.dart'
    show BarRendererConfig;
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer_config.dart'
    show BarGroupingType;
import 'package:nimble_charts_common/src/common/color.dart' show Color;
import 'package:nimble_charts_common/src/common/style/style_factory.dart'
    show StyleFactory;

/// Configuration for a bar lane renderer.
class BarLaneRendererConfig extends BarRendererConfig<String> {
  BarLaneRendererConfig({
    super.customRendererId,
    super.cornerStrategy,
    this.emptyLaneLabel = 'No data',
    super.fillPattern,
    BarGroupingType? groupingType,
    super.layoutPaintOrder,
    this.mergeEmptyLanes = false,
    super.minBarLengthPx,
    this.renderNegativeLanes = false,
    super.stackedBarPaddingPx,
    super.strokeWidthPx,
    super.barRendererDecorator,
    super.symbolRenderer,
    Color? backgroundBarColor,
    super.weightPattern,
  })  : backgroundBarColor =
            backgroundBarColor ?? StyleFactory.style.noDataColor,
        super(
          groupingType: groupingType ?? BarGroupingType.grouped,
        );

  /// The color of background bars.
  final Color backgroundBarColor;

  /// Label text to draw on a merged empty lane.
  ///
  /// This will only be drawn if all of the measures for a domain are null, and
  /// [mergeEmptyLanes] is enabled.
  ///
  /// The renderer must be configured with a [BarLabelDecorator] for this label
  /// to be drawn.
  final String emptyLaneLabel;

  /// Whether or not all lanes for a given domain value should be merged into
  /// one wide lane if all measure values for said domain are null.
  final bool mergeEmptyLanes;

  /// Whether or not to render negative bar lanes on bars with negative values
  final bool renderNegativeLanes;

  @override
  BarLaneRenderer<String> build() =>
      BarLaneRenderer<String>(config: this, rendererId: customRendererId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BarLaneRendererConfig &&
        other.backgroundBarColor == backgroundBarColor &&
        other.emptyLaneLabel == emptyLaneLabel &&
        other.mergeEmptyLanes == mergeEmptyLanes &&
        other.renderNegativeLanes == renderNegativeLanes &&
        super == other;
  }

  @override
  int get hashCode {
    var hash = super.hashCode;
    hash = hash * 31 + backgroundBarColor.hashCode;
    hash = hash * 31 + emptyLaneLabel.hashCode;
    hash = hash * 31 + mergeEmptyLanes.hashCode;
    hash = hash * 31 + renderNegativeLanes.hashCode;
    return hash;
  }
}
