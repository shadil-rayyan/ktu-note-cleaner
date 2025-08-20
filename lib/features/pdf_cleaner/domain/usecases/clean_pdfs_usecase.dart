import 'dart:io';

import '../repositories/pdf_cleaner_repository.dart';

class CleanPdfsParams {
  final List<File> files;
  final Directory? outputDirectory;
  final bool overwriteOriginals;

  const CleanPdfsParams({
    required this.files,
    this.outputDirectory,
    this.overwriteOriginals = true,
  });
}

class CleanPdfsUseCase {
  final PdfCleanerRepository repository;
  const CleanPdfsUseCase(this.repository);

  Future<int> call(CleanPdfsParams params) {
    return repository.cleanPdfs(
      params.files,
      outputDirectory: params.outputDirectory,
      overwriteOriginals: params.overwriteOriginals,
    );
  }
}
