import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'models/node.dart';

class ObjectLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(
          right: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 8,
        children: _templates,
      ),
    );
  }

  List<Widget> get _templates {
    return _Template.all.map((t) {
      return _template(
        t.title,
        _icon(t.icon),
        t.nodeKind,
        t.defaultValueType,
      );
    }).toList();
  }

  Draggable<NodeMeta> _template(
    String title,
    Widget icon,
    AstNodeKind astKind,
    Value_Type valueType,
  ) {
    final child = _NodeTemplate(title, icon);
    return Draggable<NodeMeta>(
      child: child,
      feedback: _DragFeedbackObject(child),
      data: NodeMeta(astKind, valueType),
      ignoringFeedbackSemantics: true,
    );
  }

  Widget _icon(IconData icon) => FaIcon(icon, size: 20);
}

class _NodeTemplate extends StatelessWidget {
  _NodeTemplate(this.title, this.icon);

  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.transparent, // To make the full area draggable
      width: 140,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(width: 22, child: icon),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DragFeedbackObject extends StatelessWidget {
  _DragFeedbackObject(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[600], width: 1),
        ),
        child: child,
      ),
    );
  }
}

class _Template {
  _Template(this.title, this.icon, this.kind, this.defaultValueType, this.nodeKind);
  _Template._(TemplateKind kind, Value_Type defaultValueType, AstNodeKind nodeKind)
      : this(kind.title, kind.icon, kind, defaultValueType, nodeKind);

  final TemplateKind kind;
  final String title;
  final IconData icon;
  final Value_Type defaultValueType;
  final AstNodeKind nodeKind;

  static List<_Template> get all {
    return [
      _Template._(TemplateKind.binaryOperator, Value_Type.ADD, AstNodeKind.op),
      _Template._(TemplateKind.not, Value_Type.NOT, AstNodeKind.op),
      _Template._(TemplateKind.cellOperator, Value_Type.GET_CAPACITY, AstNodeKind.cellGetOp),
      _Template._(TemplateKind.scriptOperator, Value_Type.GET_CODE_HASH, AstNodeKind.scriptGetOp),
      _Template._(TemplateKind.txOperator, Value_Type.GET_INPUTS, AstNodeKind.txGetOp),
      _Template._(TemplateKind.headerOperator, Value_Type.GET_NUMBER, AstNodeKind.headerGetOp),
    ];
  }
}

extension on TemplateKind {
  String get title {
    final separated = describeEnum(this).split(RegExp(r'(?=[A-Z])')).join(' ');
    return separated[0].toUpperCase() + separated.substring(1);
  }

  IconData get icon {
    switch (this) {
      case TemplateKind.binaryOperator:
        return FontAwesomeIcons.plus;
      case TemplateKind.not:
        return FontAwesomeIcons.notEqual;
      case TemplateKind.cellOperator:
        return FontAwesomeIcons.database;
      case TemplateKind.scriptOperator:
        return FontAwesomeIcons.code;
      case TemplateKind.txOperator:
        return FontAwesomeIcons.codeBranch;
      case TemplateKind.headerOperator:
        return FontAwesomeIcons.heading;
    }
    return FontAwesomeIcons.plus;
  }
}
