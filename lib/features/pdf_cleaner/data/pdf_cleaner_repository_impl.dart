import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../domain/repositories/pdf_cleaner_repository.dart';

class PdfCleanerRepositoryImpl implements PdfCleanerRepository {
  const PdfCleanerRepositoryImpl();

  @override
  Future<int> cleanPdfs(
    List<File> files, {
    Directory? outputDirectory,
    bool overwriteOriginals = true,
  }) async {
    int success = 0;
    for (final file in files) {
      try {
        final cleanedBytes = await _removeLinks(await file.readAsBytes());
        if (overwriteOriginals) {
          try {
            await file.writeAsBytes(cleanedBytes);
          } catch (_) {
            // On Android, overwriting arbitrary files can fail due to scoped storage.
            // Fallback: save to an app-specific directory with _cleaned suffix.
            if (Platform.isAndroid) {
              final safeDir = await _appWritableDir();
              final base = _fileName(file.path);
              final safePath = _withSuffix(p.join(safeDir.path, base), suffix: '_cleaned');
              final outPath = File(safePath);
              await outPath.parent.create(recursive: true);
              await outPath.writeAsBytes(cleanedBytes);
            } else {
              rethrow;
            }
          }
        } else if (outputDirectory != null) {
          final outDir = outputDirectory;
          final outPath = File('${outDir.path}/${_fileName(file.path)}');
          await outPath.parent.create(recursive: true);
          await outPath.writeAsBytes(cleanedBytes);
        } else {
          // Save next to the original as '<name>_cleaned.pdf'
          final cleanedPath = _withSuffix(file.path, suffix: '_cleaned');
          final outPath = File(cleanedPath);
          await outPath.parent.create(recursive: true);
          await outPath.writeAsBytes(cleanedBytes);
        }
        success++;
      } catch (_) {
        // ignore and continue
      }
    }
    return success;
  }

  Future<List<int>> _removeLinks(List<int> bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    for (int i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final annotations = page.annotations;
      final toRemove = <PdfAnnotation>[];
      for (int j = 0; j < annotations.count; j++) {
        final annotation = annotations[j];
        if (annotation is PdfLinkAnnotation) {
          toRemove.add(annotation);
        }
      }
      for (final ann in toRemove) {
        annotations.remove(ann);
      }
    }
    final output = await document.save();
    document.dispose();
    return output;
  }

  String _fileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  Future<Directory> _appWritableDir() async {
    // Prefer external storage on Android for user visibility; otherwise use app docs.
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  String _withSuffix(String path, {required String suffix}) {
    final dir = path.substring(0, path.lastIndexOf(Platform.pathSeparator) + 1);
    final name = _fileName(path);
    final dot = name.lastIndexOf('.');
    if (dot <= 0) {
      return '$dir$name$suffix';
    }
    final base = name.substring(0, dot);
    final ext = name.substring(dot);
    return '$dir$base$suffix$ext';
  }
}
