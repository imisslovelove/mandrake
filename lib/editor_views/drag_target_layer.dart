import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../models/selection.dart';
import '../models/node.dart';

class DragTargetLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<Document, Selection>(
      builder: (_, document, selection, child) {
        return DragTarget<String>(
          onWillAccept: (data) {
            print('data = $data onWillAccept');
            return data != null;
          },
          onAcceptWithDetails: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final pos = renderBox.globalToLocal(details.offset);

            final node = Node(pos);
            document.addNode(node);
            selection.select(node);
          },
          builder: (context, candidateData, rejectedData) => Container(),
        );
      },
    );
  }
}
