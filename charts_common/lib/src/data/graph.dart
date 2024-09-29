// Copyright 2021 the Charts project authors. Please see the AUTHORS file
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

import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart';
import 'package:nimble_charts_common/src/common/color.dart';
import 'package:nimble_charts_common/src/common/typed_registry.dart';
import 'package:nimble_charts_common/src/data/graph_utils.dart';
import 'package:nimble_charts_common/src/data/series.dart'
    show AttributeKey, Series, TypedAccessorFn;

// Used for readability to indicate where any indexed value can be returned
// by a [TypedAccessorFn].
const int indexNotRelevant = 0;

class Graph<N, L, D> {
  factory Graph({
    required String id,
    required List<N> nodes,
    required List<L> links,
    required TypedAccessorFn<N, D> nodeDomainFn,
    required TypedAccessorFn<L, D> linkDomainFn,
    required TypedAccessorFn<L, N> sourceFn,
    required TypedAccessorFn<L, N> targetFn,
    required TypedAccessorFn<N, num?> nodeMeasureFn,
    required TypedAccessorFn<L, num?> linkMeasureFn,
    TypedAccessorFn<N, Color>? nodeColorFn,
    TypedAccessorFn<N, Color>? nodeFillColorFn,
    TypedAccessorFn<N, FillPatternType>? nodeFillPatternFn,
    TypedAccessorFn<N, num>? nodeStrokeWidthPxFn,
    TypedAccessorFn<L, Color>? linkFillColorFn,
  }) =>
      Graph.base(
        id: id,
        nodes: convertGraphNodes<N, L, D>(
          nodes,
          links,
          sourceFn,
          targetFn,
          nodeDomainFn,
        ),
        links: convertGraphLinks<N, L>(links, sourceFn, targetFn),
        nodeDomainFn: actOnNodeData<N, L, D>(nodeDomainFn)!,
        linkDomainFn: actOnLinkData<N, L, D>(linkDomainFn)!,
        nodeMeasureFn: actOnNodeData<N, L, num?>(nodeMeasureFn)!,
        linkMeasureFn: actOnLinkData<N, L, num?>(linkMeasureFn)!,
        nodeColorFn: actOnNodeData<N, L, Color>(nodeColorFn),
        nodeFillColorFn: actOnNodeData<N, L, Color>(nodeFillColorFn),
        nodeFillPatternFn:
            actOnNodeData<N, L, FillPatternType>(nodeFillPatternFn),
        nodeStrokeWidthPxFn: actOnNodeData<N, L, num>(nodeStrokeWidthPxFn),
        linkFillColorFn: actOnLinkData<N, L, Color>(linkFillColorFn),
      );

  Graph.base({
    required this.id,
    required this.nodes,
    required this.links,
    required this.nodeDomainFn,
    required this.linkDomainFn,
    required this.nodeMeasureFn,
    required this.linkMeasureFn,
    required this.nodeColorFn,
    required this.nodeFillColorFn,
    required this.nodeFillPatternFn,
    required this.nodeStrokeWidthPxFn,
    required this.linkFillColorFn,
  });

  /// Unique identifier for this graph
  final String id;

  /// All nodes in the graph.
  final List<Node<N, L>> nodes;

  /// All links in the graph.
  final List<Link<N, L>> links;

  /// Accessor function that returns the domain for a node.
  ///
  /// The domain should be a unique identifier for the node
  final TypedAccessorFn<Node<N, L>, D> nodeDomainFn;

  /// Accessor function that returns the domain for a link.
  ///
  /// The domain should be a unique identifier for the link
  final TypedAccessorFn<Link<N, L>, D> linkDomainFn;

  /// Accessor function that returns the measure for a node.
  ///
  /// The measure should be the numeric value at the node.
  final TypedAccessorFn<Node<N, L>, num?> nodeMeasureFn;

  /// Accessor function that returns the measure for a link.
  ///
  /// The measure should be the numeric value through the link.
  final TypedAccessorFn<Link<N, L>, num?> linkMeasureFn;

  /// Accessor function that returns the stroke color of a node
  final TypedAccessorFn<Node<N, L>, Color>? nodeColorFn;

  /// Accessor function that returns the fill color of a node
  final TypedAccessorFn<Node<N, L>, Color>? nodeFillColorFn;

  /// Accessor function that returns the fill pattern of a node
  final TypedAccessorFn<Node<N, L>, FillPatternType>? nodeFillPatternFn;

  /// Accessor function that returns the stroke width of a node
  final TypedAccessorFn<Node<N, L>, num>? nodeStrokeWidthPxFn;

  /// Accessor function that returns the fill color of a node
  final TypedAccessorFn<Link<N, L>, Color>? linkFillColorFn;

  /// Store additional key-value pairs for node attributes
  final NodeAttributes nodeAttributes = NodeAttributes();

  /// Store additional key-value pairs for link attributes
  final LinkAttributes linkAttributes = LinkAttributes();

  //TODO: looks like there is something off about the graph types
  //because dynamic is necessary

  /// Transform graph data given by links and nodes into a [Series] list.
  ///
  /// Output should contain two [Series] with the format:
  /// `[Series<Node<N,L>> nodeSeries, Series<Link<N,L>> linkSeries]`
  List<Series<GraphElement<dynamic>, D>> toSeriesList() {
    final nodeSeries = Series<Node<N, L>, D>(
      id: '${id}_nodes',
      data: nodes,
      domainFn: nodeDomainFn,
      measureFn: nodeMeasureFn,
      colorFn: nodeColorFn,
      fillColorFn: nodeFillColorFn,
      fillPatternFn: nodeFillPatternFn,
      strokeWidthPxFn: nodeStrokeWidthPxFn,
    )..attributes.mergeFrom(nodeAttributes);

    final linkSeries = Series<Link<N, L>, D>(
      id: '${id}_links',
      data: links,
      domainFn: linkDomainFn,
      measureFn: linkMeasureFn,
      fillColorFn: linkFillColorFn,
    )..attributes.mergeFrom(linkAttributes);
    return [nodeSeries, linkSeries];
  }

  /// Set attribute of given generic type R for a node series
  void setNodeAttribute<R>(AttributeKey<R> key, R value) {
    nodeAttributes.setAttr(key, value);
  }

  /// Get attribute of given generic type R for a node series
  R? getNodeAttribute<R>(AttributeKey<R> key) => nodeAttributes.getAttr<R>(key);

  /// Set attribute of given generic type R for a link series
  void setLinkAttribute<R>(AttributeKey<R> key, R value) {
    linkAttributes.setAttr(key, value);
  }

  /// Get attribute of given generic type R for a link series
  R? getLinkAttribute<R>(AttributeKey<R> key) => linkAttributes.getAttr<R>(key);
}

/// Return a list of links from the generic link data type
List<Link<N, L>> convertGraphLinks<N, L>(
  List<L> links,
  TypedAccessorFn<L, N> sourceFn,
  TypedAccessorFn<L, N> targetFn,
) {
  final graphLinks = <Link<N, L>>[];
  for (var i = 0; i < links.length; i++) {
    final sourceNode = sourceFn(links[i], i);
    final targetNode = targetFn(links[i], i);
    graphLinks.add(Link(Node(sourceNode), Node(targetNode), links[i]));
  }
  return graphLinks;
}

/// Return a list of nodes from the generic node data type
List<Node<N, L>> convertGraphNodes<N, L, D>(
  List<N> nodes,
  List<L> links,
  TypedAccessorFn<L, N> sourceFn,
  TypedAccessorFn<L, N> targetFn,
  TypedAccessorFn<N, D> nodeDomainFn,
) {
  final graphNodes = <Node<N, L>>[];
  final graphLinks = convertGraphLinks(links, sourceFn, targetFn);
  final nodeClassDomainFn = actOnNodeData<N, L, D>(nodeDomainFn)!;
  final nodeMap = <D, Node<N, L>>{};

  // Populate nodeMap with user provided nodes
  for (final node in nodes) {
    nodeMap.putIfAbsent(nodeDomainFn(node, indexNotRelevant), () => Node(node));
  }

  // Add ingoing and outgoing links to the nodes in nodeMap
  for (final link in graphLinks) {
    nodeMap
      ..update(
        nodeClassDomainFn(link.target, indexNotRelevant),
        (node) => addLinkToNode(node, link, isIncomingLink: true),
        ifAbsent: () => addLinkToAbsentNode(link, isIncomingLink: true),
      )
      ..update(
        nodeClassDomainFn(link.source, indexNotRelevant),
        (node) => addLinkToNode(node, link, isIncomingLink: false),
        ifAbsent: () => addLinkToAbsentNode(link, isIncomingLink: false),
      );
  }

  nodeMap.forEach((domainId, node) => graphNodes.add(node));
  return graphNodes;
}

/// A registry that stores key-value pairs of attributes for nodes.
class NodeAttributes extends TypedRegistry {}

/// A registry that stores key-value pairs of attributes for links.
class LinkAttributes extends TypedRegistry {}

/// A node in a graph containing user defined data and connected links.
class Node<N, L> extends GraphElement<N> {
  Node(
    super.data, {
    List<Link<N, L>>? incomingLinks,
    List<Link<N, L>>? outgoingLinks,
  })  : incomingLinks = incomingLinks ?? [],
        outgoingLinks = outgoingLinks ?? [];

  /// Return.a new copy of a node with all associated links.
  Node.clone(Node<N, L> node)
      : this(
          node.data,
          incomingLinks: _cloneLinkList<N, L>(node.incomingLinks),
          outgoingLinks: _cloneLinkList<N, L>(node.outgoingLinks),
        );

  /// Return a new copy of a node with user defined data only, no links.
  Node.cloneData(Node<N, L> node) : this(node.data);

  /// All links that flow into this SankeyNode. Calculated from graph links.
  List<Link<N, L>> incomingLinks;

  /// All links that flow from this SankeyNode. Calculated from graph links.
  List<Link<N, L>> outgoingLinks;
}

/// A link in a graph connecting a source node and target node.
class Link<N, L> extends GraphElement<L> {
  Link(this.source, this.target, L data) : super(data);

  Link.clone(Link<N, L> link)
      : this(
          Node.cloneData(link.source),
          Node.cloneData(link.target),
          link.data,
        );

  /// The source Node for this Link.
  final Node<N, L> source;

  /// The target Node for this Link.
  final Node<N, L> target;
}

List<Link<N, L>> _cloneLinkList<N, L>(List<Link<N, L>> linkList) =>
    linkList.map(Link.clone).toList();

/// A [Link] or [Node] element in a graph containing user defined data.
abstract class GraphElement<G> {
  GraphElement(this.data);

  /// Data associated with this graph element
  final G data;
}
