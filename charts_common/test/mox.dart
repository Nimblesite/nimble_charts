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
  MockSpec<Axis<String>>(),
  MockSpec<ChartCanvas>(as: #MockCanvas),
  MockSpec<ImmutableSeries>(),
  MockSpec<LineStyle>(as: #MockLinePaint),
])
void main() {}
