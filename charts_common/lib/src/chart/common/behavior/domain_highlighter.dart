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

import 'package:nimble_charts_common/src/chart/common/base_chart.dart'
    show BaseChart, LifecycleListener;
import 'package:nimble_charts_common/src/chart/common/behavior/chart_behavior.dart'
    show ChartBehavior;
import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show MutableSeries;
import 'package:nimble_charts_common/src/chart/common/selection_model/selection_model.dart'
    show SelectionModel, SelectionModelType;
import 'package:nimble_charts_common/src/chart/pie/arc_renderer_element.dart';

/// Chart behavior that monitors the specified [SelectionModel] and darkens the
/// color for selected data.
///
/// This is typically used for bars and pies to highlight segments.
///
/// It is used in combination with SelectNearest to update the selection model
/// and expand selection out to the domain value.
class DomainHighlighter<D, TArcRenderElement extends ArcRendererElement<D>>
    implements ChartBehavior<D, TArcRenderElement> {
  DomainHighlighter([this.selectionModelType = SelectionModelType.info]) {
    _lifecycleListener =
        LifecycleListener<D>(onPostprocess: _updateColorFunctions);
  }
  final SelectionModelType selectionModelType;

  late BaseChart<D, TArcRenderElement> _chart;

  late LifecycleListener<D> _lifecycleListener;

  void _selectionChanged(SelectionModel<D> selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _updateColorFunctions(List<MutableSeries<D>> seriesList) {
    final SelectionModel<D> selectionModel =
        _chart.getSelectionModel(selectionModelType);
    for (final series in seriesList) {
      final origColorFn = series.colorFn;

      if (origColorFn != null) {
        series.colorFn = (index) {
          final origColor = origColorFn(index);
          if (selectionModel.isDatumSelected(series, index)) {
            return origColor.darker;
          } else {
            return origColor;
          }
        };
      }
    }
  }

  @override
  void attachTo(BaseChart<D, TArcRenderElement> chart) {
    _chart = chart;
    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionModelType)
        .addSelectionChangedListener(_selectionChanged);
  }

  @override
  void removeFrom(BaseChart<D, TArcRenderElement> chart) {
    chart
        .getSelectionModel(selectionModelType)
        .removeSelectionChangedListener(_selectionChanged);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  @override
  String get role => 'domainHighlight-$selectionModelType';
}
