import 'package:flutter/material.dart';
import 'features/pdf_cleaner/presentation/pages/pdf_cleaner_page.dart';

void main() {
  runApp(const KtuPdfCleanerApp());
}

class KtuPdfCleanerApp extends StatelessWidget {
  const KtuPdfCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTU Notes PDF Cleaner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PdfCleanerPage(),
    );
  }
}

