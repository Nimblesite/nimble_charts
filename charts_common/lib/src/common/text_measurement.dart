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

/// A measurement result for rendering text.
class TextMeasurement {
  TextMeasurement({
    required this.horizontalSliceWidth,
    required this.verticalSliceWidth,
    this.baseline,
  });

  /// Rendered width of the text.
  final double horizontalSliceWidth;

  /// Vertical slice is likely based off the rendered text.
  ///
  /// This means that 'mo' and 'My' will have different heights so do not use
  /// this for centering vertical text.
  final double verticalSliceWidth;

  /// Baseline of the text for text vertical alignment.
  final double? baseline;
}
