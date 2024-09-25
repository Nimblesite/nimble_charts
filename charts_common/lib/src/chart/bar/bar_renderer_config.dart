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

import 'package:nimble_charts_common/src/chart/bar/bar_renderer.dart'
    show BarRenderer;
import 'package:nimble_charts_common/src/chart/bar/bar_renderer_decorator.dart'
    show BarRendererDecorator;
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer_config.dart'
    show BarGroupingType, BaseBarRendererConfig;
import 'package:nimble_charts_common/src/chart/layout/layout_view.dart'
    show LayoutViewPaintOrder;

/// Configuration for a bar renderer.
class BarRendererConfig<D> extends BaseBarRendererConfig<D> {
  BarRendererConfig({
    super.barGroupInnerPaddingPx,
    super.customRendererId,
    CornerStrategy? cornerStrategy,
    super.fillPattern,
    BarGroupingType? groupingType,
    int super.layoutPaintOrder = LayoutViewPaintOrder.bar,
    super.minBarLengthPx,
    super.maxBarWidthPx,
    super.stackedBarPaddingPx,
    super.strokeWidthPx,
    this.barRendererDecorator,
    super.symbolRenderer,
    super.weightPattern,
  })  : cornerStrategy = cornerStrategy ?? const ConstCornerStrategy(2),
        super(
          groupingType: groupingType ?? BarGroupingType.grouped,
        );

  /// Strategy for determining the corner radius of a bar.
  final CornerStrategy cornerStrategy;

  /// Decorator for optionally decorating painted bars.
  final BarRendererDecorator<D>? barRendererDecorator;

  @override
  BarRenderer<D> build() =>
      BarRenderer<D>(config: this, rendererId: customRendererId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BarRendererConfig &&
        other.cornerStrategy == cornerStrategy &&
        super == other;
  }

  @override
  int get hashCode {
    final hash = super.hashCode;
    return hash * 31 + cornerStrategy.hashCode;
  }
}

abstract class CornerStrategy {
  /// Returns the radius of the rounded corners in pixels.
  int getRadius(int barWidth);
}

/// Strategy for constant corner radius.
class ConstCornerStrategy implements CornerStrategy {
  const ConstCornerStrategy(this.radius);
  final int radius;

  @override
  int getRadius(_) => radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ConstCornerStrategy && other.radius == radius;
  }

  @override
  int get hashCode => radius.hashCode;
}

/// Strategy for no corner radius.
class NoCornerStrategy extends ConstCornerStrategy {
  const NoCornerStrategy() : super(0);

  @override
  bool operator ==(Object other) => other is NoCornerStrategy;

  @override
  int get hashCode => 31;
}
