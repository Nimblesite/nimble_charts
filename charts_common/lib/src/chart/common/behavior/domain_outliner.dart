// Copyright 2019 the Charts project authors. Please see the AUTHORS file
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

/// Chart behavior that monitors the specified [SelectionModel] and outlines the
/// selected data.
///
/// This is typically used for treemap charts to highlight nodes.
/// For bars and pies, prefers to use [DomainHighlighter] for UX consistency.
class DomainOutliner<D, TRendererElement extends BaseRendererElement<D>>
    implements ChartBehavior<D, TRendererElement> {
  DomainOutliner({
    this.selectionType = SelectionModelType.info,
    double? defaultStrokePx,
    double? strokePaddingPx,
  })  : defaultStrokePx = defaultStrokePx ?? 2.0,
        strokePaddingPx = strokePaddingPx ?? 1.0 {
    _lifecycleListener = LifecycleListener<D>(onPostprocess: _outline);
  }
  final SelectionModelType selectionType;

  /// Default stroke width of the outline if the series has no stroke width
  /// function.
  ///
  /// When no stroke width function is provided, this value will be used as
  /// is. [strokePaddingPx] will not be added to [defaultStrokePx].
  final double defaultStrokePx;

  /// Additional stroke width added to the outline of the selected data.
  ///
  /// This value is only used when the series has a stroke width function
  /// defined.
  final double strokePaddingPx;

  late BaseChart<D, TRendererElement> _chart;

  late LifecycleListener<D> _lifecycleListener;

  void _selectionChange(SelectionModel<D> selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _outline(List<MutableSeries<D>> seriesList) {
    final selectionModel = _chart.getSelectionModel(selectionType);

    for (final series in seriesList) {
      final strokeWidthPxFn = series.strokeWidthPxFn;
      final colorFn = series.colorFn;

      if (colorFn != null) {
        series.colorFn = (index) {
          final color = colorFn(index);
          return selectionModel.isDatumSelected(series, index)
              ? color.darker
              : color;
        };
      }

      if (strokeWidthPxFn != null) {
        series.strokeWidthPxFn = (index) {
          final strokeWidthPx = strokeWidthPxFn(index);
          if (!selectionModel.isDatumSelected(series, index)) {
            return strokeWidthPx;
          }
          return strokeWidthPx == null
              ? defaultStrokePx
              : strokeWidthPx + strokePaddingPx;
        };
      }
    }
  }

  @override
  void attachTo(BaseChart<D, TRendererElement> chart) {
    _chart = chart;
    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionType)
        .addSelectionChangedListener(_selectionChange);
  }

  @override
  void removeFrom(BaseChart<D, TRendererElement> chart) {
    chart
        .getSelectionModel(selectionType)
        .removeSelectionChangedListener(_selectionChange);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  @override
  String get role => 'domainOutliner-$selectionType';
}
