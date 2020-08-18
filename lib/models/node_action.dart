import 'package:flutter/foundation.dart';

import 'document.dart';
import 'selection.dart';
import 'node.dart';
import 'undo_manager.dart';

enum NodeAction {
  disconnectFromParent,
  disconnectAllChildren,
  delete,
  deleteWithDescendants,
  flatten,
  autoLayout,
}

class NodeActionItem {
  NodeActionItem({@required this.value, @required this.label, this.danger = false});

  final NodeAction value;
  final String label;
  final bool danger;
}

class NodeActionBuilder {
  NodeActionBuilder(this.document, this.node);

  final Document document;
  final Node node;

  List<NodeActionItem> build() {
    if (node is AstNode) {
      return _buildAstNodeNode();
    }

    if (node is RootNode) {
      return _buildRootNode();
    }

    return [];
  }

  List<NodeActionItem> _buildAstNodeNode() {
    return [
      if (_canFlatten)
        NodeActionItem(
          value: NodeAction.flatten,
          label: 'Flatten',
        ),
      if (_canDisconnectParents)
        NodeActionItem(
          value: NodeAction.disconnectFromParent,
          label: 'Disconnect from parent(s)',
        ),
      if (_canDisconnectAllChildren)
        NodeActionItem(
          value: NodeAction.disconnectAllChildren,
          label: 'Disconnect all children',
        ),
      NodeActionItem(
        value: NodeAction.delete,
        label: 'Delete node',
        danger: true,
      ),
      if (_canDeleteWithDecendants)
        NodeActionItem(
          value: NodeAction.deleteWithDescendants,
          label: 'Delete node and descendants',
          danger: true,
        ),
      NodeActionItem(
        value: NodeAction.autoLayout,
        label: 'Auto layout',
      ),
    ];
  }

  List<NodeActionItem> _buildRootNode() {
    return [
      if (_canDisconnectAllChildren)
        NodeActionItem(
          value: NodeAction.disconnectAllChildren,
          label: 'Disconnect all children',
        ),
    ];
  }
}

extension on NodeActionBuilder {
  bool get _canFlatten => node is PrefabNode;

  bool get _canDisconnectParents => document.parentsOf(node).isNotEmpty;

  bool get _canDisconnectAllChildren => node.children.isNotEmpty;

  bool get _canDeleteWithDecendants => node.children.isNotEmpty;
}

class NodeActionExecutor {
  NodeActionExecutor(this.document, this.selection);

  final Document document;
  final Selection selection;
  Node get node => selection.selectedNode(document.nodes);

  void execute(NodeAction action) {
    switch (action) {
      case NodeAction.flatten:
        addCommandToUndoList(Command.flatten(document, selection, node));
        break;
      case NodeAction.disconnectFromParent:
        addCommandToUndoList(Command.disconnectParent(document, node));
        break;
      case NodeAction.disconnectAllChildren:
        addCommandToUndoList(Command.disconnectChildren(document, node));
        break;
      case NodeAction.delete:
        addCommandToUndoList(Command.deleteNode(document, selection, node));
        break;
      case NodeAction.deleteWithDescendants:
        addCommandToUndoList(Command.deleteNodeAndDescendants(document, selection, node));
        break;
      case NodeAction.autoLayout:
        addCommandToUndoList(Command.autoLayout(node));
        break;
    }
  }
}
