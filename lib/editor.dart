import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_chooser/file_chooser.dart';

import 'models/document.dart';
import 'models/selection.dart';
import 'models/editor_state.dart';

import 'io/doc_reader.dart';
import 'io/doc_writer.dart';
import 'io/ast_writer.dart';

import 'toolbar.dart';
import 'object_library.dart';
import 'property_inspector.dart';
import 'ruler.dart';

import 'views/editor/editor_dimensions.dart';
import 'views/editor/canvas_layer.dart';
import 'views/editor/edges_layer.dart';
import 'views/editor/nodes_layer.dart';
import 'views/editor/pointer_layer.dart';

class Editor extends StatefulWidget {
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Document _doc;
  String _docPath;
  Selection _selection;
  EditorState _editorState;

  void _newDocument() {
    // TODO: prompt to save current doc if it's modified but not saved
    setState(() {
      _doc = Document.template();
      _docPath = '';
      _selection = Selection();
      _editorState = EditorState();
    });
  }

  void _openDocument() async {
    // TODO: prompt to save current doc if it's modified but not saved
    String path;
    if (kIsWeb) {
      // TODO: handle web export
      path = 'todo.json';
    } else {
      final result = await showOpenPanel(
        allowedFileTypes: [
          FileTypeFilterGroup(fileExtensions: ['json'], label: 'JSON')
        ],
        allowsMultipleSelection: false,
        canSelectDirectories: false,
      );
      if (!result.canceled) {
        path = result.paths.first;
      }
    }

    final doc = await DocReader(path).read();
    if (doc != null) {
      setState(() {
        _doc = doc;
        _doc.rebuild();
        _docPath = path;
        _selection = Selection();
        _editorState = EditorState();
      });
    }
  }

  void _saveDocument() async {
    if (_docPath.isEmpty) {
      if (kIsWeb) {
        // TODO: handle web export
        _docPath = _doc.fileName;
      } else {
        final result = await showSavePanel(
          suggestedFileName: _doc.fileName,
        );
        if (!result.canceled) {
          _docPath = result.paths.first;
        }
      }
    }
    if (_docPath != null) {
      await DocWriter(_doc, _docPath).write();
      _doc.markNotDirty();
    }
  }

  void _exportAst() async {
    String path;
    if (kIsWeb) {
      // TODO: handle web export
      path = 'ast.bin';
    } else {
      final result = await showSavePanel(
        suggestedFileName: 'ast.bin',
      );
      if (!result.canceled) {
        path = result.paths.first;
      }
    }

    if (path != null) {
      await AstWriter(_doc, path).write();
    }
  }

  @override
  void initState() {
    _doc = Document.template();
    _docPath = '';
    _selection = Selection();
    _editorState = EditorState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Document>.value(value: _doc),
        ChangeNotifierProvider<Selection>.value(value: _selection),
        ChangeNotifierProvider<EditorState>.value(value: _editorState),
      ],
      child: Stack(
        children: [
          Positioned(
            top: EditorDimensions.toolbarHeight + EditorDimensions.rulerWidth,
            left: EditorDimensions.objectLibraryPanelWidth + EditorDimensions.rulerWidth,
            right: EditorDimensions.propertyInspectorPanelWidth,
            bottom: 0,
            child: DesignEditor(),
          ),
          Positioned(
            top: EditorDimensions.toolbarHeight + EditorDimensions.rulerWidth - 1,
            left: EditorDimensions.objectLibraryPanelWidth,
            bottom: 0,
            width: EditorDimensions.rulerWidth,
            child: Ruler(RulerDirection.vertical),
          ),
          Positioned(
            top: EditorDimensions.toolbarHeight,
            left: EditorDimensions.objectLibraryPanelWidth + EditorDimensions.rulerWidth - 1,
            right: EditorDimensions.propertyInspectorPanelWidth,
            height: EditorDimensions.rulerWidth,
            child: Ruler(RulerDirection.horizontal),
          ),
          Positioned(
            top: EditorDimensions.toolbarHeight,
            left: 0,
            bottom: 0,
            width: EditorDimensions.objectLibraryPanelWidth,
            child: ObjectLibrary(),
          ),
          Positioned(
            top: EditorDimensions.toolbarHeight,
            bottom: 0,
            right: 0,
            width: EditorDimensions.propertyInspectorPanelWidth,
            child: PropertyInspector(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: EditorDimensions.toolbarHeight,
            child: Toolbar(
              onNewDocument: _newDocument,
              onOpenDocument: _openDocument,
              onSaveDocument: _saveDocument,
              onExportAst: _exportAst,
            ),
          ),
        ],
      ),
    );
  }
}

/// Graph design core editor.
class DesignEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);

    return Stack(
      children: [
        CanvasLayer(), // endless scrolling
        Transform.scale(
          scale: editorState.zoomScale,
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              EdgesLayer(),
              NodesLayer(),
            ],
          ),
        ),

        /// Pointer layer doesn't scale with edges/nodes to make sure even when
        /// drawing area is smaller than canvas background events outside that
        /// area are still handled.
        PointerLayer(),
      ],
    );
  }
}
