import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
  String _status = 'Click "Browse" to select PDFs or folders';

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
      // Try to pick directories first (desktop platforms)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder containing PDFs',
        );
        
        if (selectedDirectory != null) {
          selectedPaths = [selectedDirectory];
        } else {
          // If no directory selected, try file picking
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            dialogTitle: 'Select PDF files',
          );
          
          if (result != null) {
            selectedPaths = result.paths.whereType<String>().toList();
          }
        }
      } else {
        // On mobile: only files picking
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          dialogTitle: 'Select PDF files',
        );

        if (result != null) {
          selectedPaths = result.paths.whereType<String>().toList();
        }
      }
      
      if (selectedPaths.isEmpty) {
        _setStatus('No files or folders selected.');
        return;
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
      
      // Create a list of annotations to remove
      final annotationsToRemove = <PdfAnnotation>[];
      for (int j = 0; j < annotations.count; j++) {
        final annotation = annotations[j];
        if (annotation is PdfLinkAnnotation) {
          annotationsToRemove.add(annotation);
        }
      }
      
      // Remove the annotations
      for (final annotation in annotationsToRemove) {
        annotations.remove(annotation);
      }
    }

    final outputBytes = await document.save();
    document.dispose();

    // Overwrite original file
    await pdfFile.writeAsBytes(outputBytes);
  }

  void _setStatus(String message) {
    setState(() {
      _status = message;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTU Notes PDF Cleaner'),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.white,
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
    );
  }
}
