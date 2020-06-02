import 'dart:collection';
import 'dart:math';
import 'dart:ui' show Offset, Size;
import 'package:flutter/foundation.dart';

import 'node.dart';
import 'link.dart';

class Document extends ChangeNotifier {
  static const Size _minimalCanvasSize = Size(1440, 900);

  final List<Node> _topLevelNodes = []; // Reference to top level nodes only
  final List<Node> _allNodes = [];
  final List<Link> _links = [];
  Size _canvasSize = _minimalCanvasSize;

  UnmodifiableListView<Node> get nodes => UnmodifiableListView(_allNodes);
  UnmodifiableListView<Link> get links => UnmodifiableListView(_links);
  Size get canvasSize => _canvasSize;

  Document() {
    final root = RootNode();
    final slot = root.addCallSlot();
    addNode(root);
    final callResult = NodeCreator.create(
      NodeTemplate(Value_Type.UINT64),
      root.position + Offset(root.size.width + 100, -50),
    );
    addNode(callResult);
    callResult.setName('Call Result');
    connectNode(parent: root, child: callResult, slotId: slot.id);
  }

  void resizeCanvas(Size size) {
    if (size == _canvasSize) {
      return;
    }

    _canvasSize = Size(
      max(size.width, _minimalCanvasSize.width),
      max(size.height, _minimalCanvasSize.height),
    );
    notifyListeners();
  }

  void addNode(Node node, {Node parent}) {
    if (parent != null) {
      assert(_allNodes.contains(parent));
      parent.addChild(node);
    } else {
      _topLevelNodes.add(node);
    }

    _rebuildNodes();
    _rebuildLinks();
    notifyListeners();
  }

  bool canConnect({@required Node parent, @required Node child}) {
    if (parent == null || child == null) {
      return false;
    }
    if (parent == child) {
      return false;
    }
    if (child.nodes.contains(parent)) {
      return false;
    }
    if (child is RootNode) {
      return false;
    }
    return _allNodes.contains(parent); // && _topLevelNodes.contains(child);
  }

  List<Node> parentsOf(Node node) {
    return _allNodes.where((n) => n.children.contains(node)).toList();
  }

  void connectNode({@required Node parent, @required Node child, String slotId}) {
    assert(canConnect(parent: parent, child: child));

    _topLevelNodes.remove(child);
    parent.addChild(child, slotId);

    _rebuildNodes();
    _rebuildLinks();
    notifyListeners();
  }

  void disconnectNode({@required Node parent, @required String childId}) {
    final child = _allNodes.firstWhere((n) => n.id == childId, orElse: () => null);
    if (parentsOf(child).length == 1) {
      _topLevelNodes.add(child);
    }
    parent?.removeChild(childId);

    _rebuildNodes();
    _rebuildLinks();
    notifyListeners();
  }

  void disconnectNodeFromParent(Node node) {
    for (final parent in parentsOf(node)) {
      disconnectNode(parent: parent, childId: node.id);
    }
  }

  void disconnectAllChildren(Node node) {
    final childIds = node.children.map((c) => c.id).toList();
    for (final childId in childIds) {
      disconnectNode(parent: node, childId: childId);
    }
  }

  void deleteNode(Node node) {
    disconnectNodeFromParent(node);
    disconnectAllChildren(node);

    _topLevelNodes.removeWhere((n) => n == node);

    _rebuildNodes();
    _rebuildLinks();
    notifyListeners();
  }

  void deleteNodeAndDescendants(Node node) {
    disconnectNodeFromParent(node);
    for (final n in node.nodes) {
      _topLevelNodes.removeWhere((e) => e == n);
    }

    _rebuildNodes();
    _rebuildLinks();
    notifyListeners();
  }

  /// Move a node by offset.
  void moveNodePosition(Node node, Offset offset) {
    assert(nodes.contains(node));
    node.moveTo(node.position + offset);
    notifyListeners();
  }

  void _rebuildNodes() {
    _allNodes.clear();
    for (final root in _topLevelNodes) {
      _allNodes.addAll(root.nodes);
    }
  }

  void _rebuildLinks() {
    _links.clear();
    for (final root in _topLevelNodes) {
      _links.addAll(Link.linksOf(root));
    }
  }
}
