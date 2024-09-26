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

import 'dart:collection' show HashMap;

import 'package:nimble_charts_common/src/chart/cartesian/axis/ordinal_extents.dart'
    show OrdinalExtents;
import 'package:nimble_charts_common/src/chart/cartesian/axis/ordinal_scale.dart';

/// A domain processor for [OrdinalScale].
///
/// Unique domain values are kept, so duplicates will not increase the extent.
class OrdinalScaleDomainInfo {
  OrdinalScaleDomainInfo();
  int _index = 0;

  /// A map of domain value and the order it was added.
  final _domainsToOrder = HashMap<String, int>();

  /// A list of domain values kept to support [getDomainAtIndex].
  final _domainList = <String>[];

  OrdinalScaleDomainInfo copy() => OrdinalScaleDomainInfo()
    .._domainsToOrder.addAll(_domainsToOrder)
    .._index = _index
    .._domainList.addAll(_domainList);

  void add(String domain) {
    if (!_domainsToOrder.containsKey(domain)) {
      _domainsToOrder[domain] = _index;
      _index += 1;
      _domainList.add(domain);
    }
  }

  int? indexOf(String domain) => _domainsToOrder[domain];

  String getDomainAtIndex(int index) {
    assert(index >= 0, 'Index must be bigger or equal to zero');
    assert(index < _index, 'Index is out of range');
    return _domainList[index];
  }

  List<String> get domains => _domainList;

  String? get first => _domainList.isEmpty ? null : _domainList.first;

  String? get last => _domainList.isEmpty ? null : _domainList.last;

  bool get isEmpty => _index == 0;
  bool get isNotEmpty => !isEmpty;

  OrdinalExtents get extent => OrdinalExtents.all(_domainList);

  int get size => _index;

  /// Clears all domain values.
  void clear() {
    _domainsToOrder.clear();
    _domainList.clear();
    _index = 0;
  }
}
