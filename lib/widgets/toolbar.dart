import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../models/editor_state.dart';
import '../views/editor/editor_dimensions.dart';
import '../utils/google_auth_manager.dart';

import 'main_menu.dart';

class Toolbar extends StatelessWidget {
  Toolbar({
    this.onNewDocument,
    this.onNewDocumentFromTemplate,
    this.onOpenDocument,
    this.onOpenDocumentHandle,
    this.onSaveDocument,
    this.onSaveDocumentAs,
    this.onExportAst,
  });
  final Function onNewDocument;
  final Function onNewDocumentFromTemplate;
  final Function onOpenDocument;
  final Function onOpenDocumentHandle;
  final Function onSaveDocument;
  final Function onSaveDocumentAs;
  final Function onExportAst;

  @override
  Widget build(BuildContext context) {
    return Consumer2<Document, EditorState>(builder: (context, document, editorState, child) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            width: double.infinity,
            height: EditorDimensions.toolbarHeight,
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: EditorDimensions.mainMenuWidth),
              /*
              _iconButton(
                icon: Icon(Icons.note_add),
                onPressed: () => onNewDocument(),
              ),
              _iconButton(
                icon: Icon(Icons.file_upload),
                onPressed: () => onOpenDocument(),
              ),
              _iconButton(
                icon: Icon(Icons.save),
                onPressed: () => onSaveDocument(),
              ),
              _iconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => onExportAst(),
              ),
              */
              _separator(),
              _iconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: editorState.zoomOutAction,
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${(editorState.zoomScale * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
              _iconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: editorState.zoomInAction,
              ),
              _separator(),
              _iconButton(
                icon: Icon(Icons.filter_center_focus),
                onPressed: () => editorState.resetCanvasOffset(),
              ),
              _iconButton(
                icon: Icon(Icons.developer_board),
                onPressed: () => _jumpToRoot(document, editorState),
              ),
              if (kIsWeb)
                _iconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () async {
                    await GoogleAuthManager.signIn();
                  },
                ),
            ],
          ),
          MainMenu(
            onNewDocument: onNewDocument,
            onNewDocumentFromTemplate: onNewDocumentFromTemplate,
            onOpenDocument: onOpenDocument,
            onOpenDocumentHandle: onOpenDocumentHandle,
            onSaveDocument: onSaveDocument,
            onSaveDocumentAs: onSaveDocumentAs,
            onExportAst: onExportAst,
            onLocateRootNode: () => _jumpToRoot(document, editorState),
          ),
        ],
      );
    });
  }

  void _jumpToRoot(Document document, EditorState editorState) {
    final root = document.root;
    editorState.resetCanvasOffset();
    final pos = root.position + Offset(-80, -250);
    editorState.moveCanvas(-pos);
  }

  Widget _iconButton({Widget icon, Function onPressed}) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }

  Widget _separator() {
    return SizedBox(
      width: 20,
      height: 40,
      child: VerticalDivider(
        indent: 8,
        endIndent: 8,
      ),
    );
  }
}
