import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/clean_pdfs_usecase.dart';
import '../../data/pdf_cleaner_repository_impl.dart';

class PdfCleanerPage extends StatefulWidget {
  const PdfCleanerPage({super.key});

  @override
  State<PdfCleanerPage> createState() => _PdfCleanerPageState();
}

class _PdfCleanerPageState extends State<PdfCleanerPage> {
  final _repo = const PdfCleanerRepositoryImpl();
  late final CleanPdfsUseCase _useCase;

  String _status = 'Click "Browse" to select PDFs or folders';
  bool _overwrite = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _useCase = CleanPdfsUseCase(_repo);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.storage.request();
    }
  }

  void _setStatus(String s) => setState(() => _status = s);

  Future<void> _pickFilesOrFolders() async {
    _setStatus('Picking files or folders...');
    List<String> selectedPaths = [];

    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final dir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder containing PDFs',
        );
        if (dir != null) {
          selectedPaths = [dir];
        } else {
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: const ['pdf'],
            dialogTitle: 'Select PDF files',
          );
          if (result != null) {
            selectedPaths = result.paths.whereType<String>().toList();
          }
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
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

    final filesToClean = await _collectPdfFiles(selectedPaths);
    if (filesToClean.isEmpty) {
      _setStatus('No PDF files found in selection.');
      return;
    }

    setState(() => _busy = true);
    try {
      _setStatus('Cleaning ${filesToClean.length} PDF(s)...');
      final count = await _useCase(
        CleanPdfsParams(
          files: filesToClean,
          outputDirectory: null,
          overwriteOriginals: _overwrite,
        ),
      );
      _setStatus('Cleaning complete: $count/${filesToClean.length} PDFs cleaned.');
    } catch (e) {
      _setStatus('Cleaning failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<List<File>> _collectPdfFiles(List<String> paths) async {
    final files = <File>[];
    for (final path in paths) {
      if (path.isEmpty) continue;
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        try {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
              files.add(entity);
            }
          }
        } catch (_) {}
      } else if (type == FileSystemEntityType.file && path.toLowerCase().endsWith('.pdf')) {
        files.add(File(path));
      }
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTU Notes PDF Cleaner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  value: !_overwrite,
                  onChanged: (v) => setState(() => _overwrite = !(v ?? false)),
                  title: const Text("Don't overwrite (save as _cleaned.pdf in same folder)"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Note: When overwriting is enabled, original PDFs will be replaced in-place. When disabled, cleaned files are saved next to the originals with _cleaned suffix.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _busy ? null : _pickFilesOrFolders,
                  child: const Text('Select PDFs or Folder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
