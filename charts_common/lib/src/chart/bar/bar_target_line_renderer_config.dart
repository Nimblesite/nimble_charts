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

import 'package:nimble_charts_common/src/chart/bar/bar_target_line_renderer.dart'
    show BarTargetLineRenderer;
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer_config.dart'
    show BaseBarRendererConfig;
import 'package:nimble_charts_common/src/chart/layout/layout_view.dart'
    show LayoutViewPaintOrder;
import 'package:nimble_charts_common/src/common/symbol_renderer.dart'
    show LineSymbolRenderer, SymbolRenderer;

/// Configuration for a bar target line renderer.
class BarTargetLineRendererConfig<D> extends BaseBarRendererConfig<D> {
  BarTargetLineRendererConfig({
    super.barGroupInnerPaddingPx,
    super.customRendererId,
    super.dashPattern,
    super.groupingType,
    int super.layoutPaintOrder = LayoutViewPaintOrder.barTargetLine,
    super.minBarLengthPx,
    this.overDrawOuterPx,
    this.overDrawPx = 0,
    this.roundEndCaps = true,
    super.strokeWidthPx = 3.0,
    SymbolRenderer? symbolRenderer,
    super.weightPattern,
  }) : super(
          symbolRenderer: symbolRenderer ?? LineSymbolRenderer(),
        );

  /// The number of pixels that the line will extend beyond the bandwidth at the
  /// edges of the bar group.
  ///
  /// If set, this overrides overDrawPx for the beginning side of the first bar
  /// target line in the group, and the ending side of the last bar target line.
  /// overDrawPx will be used for overdrawing the target lines for interior
  /// sides of the bars.
  final int? overDrawOuterPx;

  /// The number of pixels that the line will extend beyond the bandwidth for
  /// every bar in a group.
  final int overDrawPx;

  /// Whether target lines should have round end caps, or square if false.
  final bool roundEndCaps;

  @override
  BarTargetLineRenderer<D> build() =>
      BarTargetLineRenderer<D>(config: this, rendererId: customRendererId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BarTargetLineRendererConfig &&
        other.overDrawOuterPx == overDrawOuterPx &&
        other.overDrawPx == overDrawPx &&
        other.roundEndCaps == roundEndCaps &&
        super == other;
  }

  @override
  int get hashCode {
    var hash = 1;
    hash = hash * 31 + overDrawOuterPx.hashCode;
    hash = hash * 31 + overDrawPx.hashCode;
    hash = hash * 31 + roundEndCaps.hashCode;
    return hash;
  }
}
