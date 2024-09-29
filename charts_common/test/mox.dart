// ignore_for_file: strict_raw_type

import 'package:mockito/annotations.dart';
import 'package:nimble_charts_common/common.dart';

// dart run build_runner build --delete-conflicting-outputs

@GenerateNiceMocks([
  MockSpec<ChartContext>(),
  MockSpec<GraphicsFactory>(),
  MockSpec<TextElement>(),
  MockSpec<TickFormatter<num>>(as: #MockNumericTickFormatter),
  MockSpec<BaseTickDrawStrategy>(as: #MockDrawStrategy),
  MockSpec<TickDrawStrategy<num>>(as: #MockTickDrawStrategy),
  MockSpec<Axis>(),
  MockSpec<ChartCanvas>(as: #MockCanvas),
  MockSpec<ImmutableSeries>(),
  MockSpec<LineStyle>(as: #MockLinePaint),
  MockSpec<NumericScale>(as: #MockNumericScale),
  MockSpec<TextStyle>(as: #MockTextStyle),
  MockSpec<CartesianChart>(as: #MockChart),
])
void main() {}
