import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const KtuPdfCleanerApp());
}

class KtuPdfCleanerApp extends StatelessWidget {
  const KtuPdfCleanerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTU Notes PDF Cleaner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Drag & drop PDFs/folders or click "Browse"';
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.storage.request();
    }
  }

  Future<void> _pickFilesOrFolders() async {
    _setStatus('Picking files or folders...');
    List<String> selectedPaths = [];

    try {
      // On desktop: allow folder picking + multiple files
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          allowCompression: false,
          dialogTitle: 'Select PDFs or folders',
          allowFolderPicker: true,
        );

        if (result == null) {
          _setStatus('No files or folders selected.');
          return;
        }

        selectedPaths = result.paths.whereType<String>().toList();
      } else {
        // On mobile: only files picking
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          dialogTitle: 'Select PDF files',
        );

        if (result == null) {
          _setStatus('No files selected.');
          return;
        }

        selectedPaths = result.paths.whereType<String>().toList();
      }
    } catch (e) {
      _setStatus('Error during picking: $e');
      return;
    }

    List<File> filesToClean = [];

    // Process paths: if folder, get all PDFs inside recursively; if file, add directly
    for (var path in selectedPaths) {
      if (path.isEmpty) continue;
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        filesToClean.addAll(_listPdfsInDir(dir));
      } else if (type == FileSystemEntityType.file &&
          path.toLowerCase().endsWith('.pdf')) {
        filesToClean.add(File(path));
      }
    }

    if (filesToClean.isEmpty) {
      _setStatus('No PDF files found in selection.');
      return;
    }

    _setStatus('Cleaning ${filesToClean.length} PDF(s)...');
    await _cleanMultiplePdfs(filesToClean);
  }

  List<File> _listPdfsInDir(Directory dir) {
    List<File> pdfFiles = [];
    try {
      for (var entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          pdfFiles.add(entity);
        }
      }
    } catch (e) {
      print('Error scanning directory: $e');
    }
    return pdfFiles;
  }

  Future<void> _cleanMultiplePdfs(List<File> files) async {
    int successCount = 0;

    for (var file in files) {
      try {
        await _cleanPdfLinks(file);
        successCount++;
      } catch (e) {
        print('Failed to clean ${file.path}: $e');
      }
    }

    _setStatus('Cleaning complete: $successCount/${files.length} PDFs cleaned.');
  }

  Future<void> _cleanPdfLinks(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    // Remove all hyperlink annotations on all pages
    for (int i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final annotations = page.annotations;
      annotations.removeWhere(
          (annotation) => annotation.annotationType == PdfAnnotationType.link);
    }

    final outputBytes = document.save();
    document.dispose();

    // Overwrite original file
    await pdfFile.writeAsBytes(outputBytes);
  }

  void _setStatus(String message) {
    setState(() {
      _status = message;
    });
  }

  Future<void> _handleDrop(List<Uri> uris) async {
    _setStatus('Processing dropped files/folders...');
    List<File> filesToClean = [];

    for (var uri in uris) {
      final path = uri.toFilePath();
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        filesToClean.addAll(_listPdfsInDir(Directory(path)));
      } else if (type == FileSystemEntityType.file &&
          path.toLowerCase().endsWith('.pdf')) {
        filesToClean.add(File(path));
      }
    }

    if (filesToClean.isEmpty) {
      _setStatus('No PDF files found in dropped items.');
      return;
    }

    _setStatus('Cleaning ${filesToClean.length} dropped PDF(s)...');
    await _cleanMultiplePdfs(filesToClean);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTU Notes PDF Cleaner'),
      ),
      body: DesktopDropTarget(
        onDragEntered: (details) => setState(() => _dragging = true),
        onDragExited: (details) => setState(() => _dragging = false),
        onDragDone: (details) {
          setState(() => _dragging = false);
          _handleDrop(details.urls);
        },
        child: Container(
          color: _dragging ? Colors.blue.shade100 : Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFilesOrFolders,
                    child: const Text('Browse PDFs or Folders'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
