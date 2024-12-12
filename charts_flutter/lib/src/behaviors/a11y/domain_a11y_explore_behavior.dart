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

import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show ChartBehavior, GestureType;
import 'package:nimble_charts_common/common.dart' as common
    show
        ChartBehavior,
        DomainA11yExploreBehavior,
        ExploreModeTrigger,
        VocalizationCallback;

/// Behavior that generates semantic nodes for each domain.
class DomainA11yExploreBehavior<D> extends ChartBehavior<D> {
  factory DomainA11yExploreBehavior({
    common.VocalizationCallback? vocalizationCallback,
    common.ExploreModeTrigger? exploreModeTrigger,
    double? minimumWidth,
    String? exploreModeEnabledAnnouncement,
    String? exploreModeDisabledAnnouncement,
  }) {
    final desiredGestures = <GestureType>{};
    exploreModeTrigger ??= common.ExploreModeTrigger.pressHold;

    switch (exploreModeTrigger) {
      case common.ExploreModeTrigger.pressHold:
        desiredGestures.add(GestureType.onLongPress);
      case common.ExploreModeTrigger.tap:
        desiredGestures.add(GestureType.onTap);
    }

    return DomainA11yExploreBehavior._internal(
      vocalizationCallback: vocalizationCallback,
      desiredGestures: desiredGestures,
      exploreModeTrigger: exploreModeTrigger,
      minimumWidth: minimumWidth,
      exploreModeEnabledAnnouncement: exploreModeEnabledAnnouncement,
      exploreModeDisabledAnnouncement: exploreModeDisabledAnnouncement,
    );
  }

  DomainA11yExploreBehavior._internal({
    required this.desiredGestures,
    this.vocalizationCallback,
    this.exploreModeTrigger,
    this.minimumWidth,
    this.exploreModeEnabledAnnouncement,
    this.exploreModeDisabledAnnouncement,
  });

  /// Returns a string for a11y vocalization from a list of series datum.
  final common.VocalizationCallback? vocalizationCallback;

  @override
  final Set<GestureType> desiredGestures;

  /// The gesture that activates explore mode. Defaults to long press.
  ///
  /// Turning on explore mode asks this [A11yBehavior] to generate nodes within
  /// this chart.
  final common.ExploreModeTrigger? exploreModeTrigger;

  /// Minimum width of the bounding box for the a11y focus.
  ///
  /// Must be 1 or higher because invisible semantic nodes should not be added.
  final double? minimumWidth;

  /// Optionally notify the OS when explore mode is enabled.
  final String? exploreModeEnabledAnnouncement;

  /// Optionally notify the OS when explore mode is disabled.
  final String? exploreModeDisabledAnnouncement;

  @override
  common.DomainA11yExploreBehavior<D> createCommonBehavior() =>
      common.DomainA11yExploreBehavior<D>(
        vocalizationCallback: vocalizationCallback,
        exploreModeTrigger: exploreModeTrigger,
        minimumWidth: minimumWidth,
        exploreModeEnabledAnnouncement: exploreModeEnabledAnnouncement,
        exploreModeDisabledAnnouncement: exploreModeDisabledAnnouncement,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {}

  @override
  String get role => 'DomainA11yExplore-$exploreModeTrigger';

  @override
  bool operator ==(Object other) =>
      other is DomainA11yExploreBehavior &&
      vocalizationCallback == other.vocalizationCallback &&
      exploreModeTrigger == other.exploreModeTrigger &&
      minimumWidth == other.minimumWidth &&
      exploreModeEnabledAnnouncement == other.exploreModeEnabledAnnouncement &&
      exploreModeDisabledAnnouncement == other.exploreModeDisabledAnnouncement;

  @override
  int get hashCode => Object.hash(
        minimumWidth,
        vocalizationCallback,
        exploreModeTrigger,
        exploreModeEnabledAnnouncement,
        exploreModeDisabledAnnouncement,
      );
}
