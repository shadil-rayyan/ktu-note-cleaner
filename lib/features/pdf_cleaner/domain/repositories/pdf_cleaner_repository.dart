import 'dart:io';

abstract class PdfCleanerRepository {
  /// Cleans hyperlinks from given PDF files.
  /// If [outputDirectory] is provided and [overwriteOriginals] is false,
  /// cleaned PDFs will be written there preserving relative file names.
  /// Returns the number of files successfully cleaned.
  Future<int> cleanPdfs(
    List<File> files, {
    Directory? outputDirectory,
    bool overwriteOriginals = true,
  });
}
