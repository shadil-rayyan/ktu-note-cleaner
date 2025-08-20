import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ktunotecleaner/features/pdf_cleaner/domain/repositories/pdf_cleaner_repository.dart';
import 'package:ktunotecleaner/features/pdf_cleaner/domain/usecases/clean_pdfs_usecase.dart';

class _FakeRepo implements PdfCleanerRepository {
  List<File>? lastFiles;
  Directory? lastOutputDir;
  bool? lastOverwrite;
  int result;

  _FakeRepo({this.result = 0});

  @override
  Future<int> cleanPdfs(List<File> files, {Directory? outputDirectory, bool overwriteOriginals = true}) async {
    lastFiles = files;
    lastOutputDir = outputDirectory;
    lastOverwrite = overwriteOriginals;
    return result;
  }
}

void main() {
  test('CleanPdfsUseCase forwards params to repository and returns count', () async {
    final repo = _FakeRepo(result: 3);
    final useCase = CleanPdfsUseCase(repo);
    final files = [File('a.pdf'), File('b.pdf')];
    final outputDir = Directory('/tmp/out');

    final count = await useCase(CleanPdfsParams(
      files: files,
      outputDirectory: outputDir,
      overwriteOriginals: false,
    ));

    expect(count, 3);
    expect(repo.lastFiles, files);
    expect(repo.lastOutputDir, outputDir);
    expect(repo.lastOverwrite, false);
  });
}
