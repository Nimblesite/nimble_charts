import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show ImmutableSeries;
import 'package:nimble_charts_common/src/common/color.dart' show Color;

abstract class BaseRendererElement<D> {
  Color? color;
  int? index;
  num? key;
  D? domain;
  late ImmutableSeries<D> series;

  void updateAnimationPercent(
    BaseRendererElement<D> previous,
    BaseRendererElement<D> target,
    double animationPercent,
  );

  BaseRendererElement<D> clone();
}
