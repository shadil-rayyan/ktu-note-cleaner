# Architecture

KTU Notes PDF Cleaner is a small, feature‑oriented Flutter app designed around a simple vertical slice: select PDFs → remove link annotations → write cleaned files.

## Goals

- Keep UI simple and responsive across desktop and mobile.
- Keep file processing local (no network).
- Handle platform quirks (e.g., Android scoped storage) gracefully.

## Modules and Layout

- `lib/core/result.dart`
  - Minimal result helpers for readable flows and tests.
- `lib/features/pdf_cleaner/`
  - `presentation/pages/pdf_cleaner_page.dart`
    - UI: user selects files or a folder, toggles overwrite vs save‑as, views status.
  - `domain/usecases/clean_pdfs_usecase.dart`
    - Orchestrates cleaning: validates input, calls repository.
  - `data/pdf_cleaner_repository_impl.dart`
    - Removes `PdfLinkAnnotation` from documents using `syncfusion_flutter_pdf`.
    - Writes output based on overwrite flag; Android fallback for scoped storage.

## Data Flow

1. `PdfCleanerPage` collects file paths with `file_picker` and toggles flags.
2. `CleanPdfsUseCase` accepts `CleanPdfsParams` and calls the repository.
3. `PdfCleanerRepositoryImpl.cleanPdfs()` reads bytes, calls `_removeLinks()`, and writes the result.
4. On Android, if overwrite fails (scoped storage), it saves a `_cleaned` copy to an app‑writable directory via `path_provider`.

## Key Decisions

- Syncfusion PDF library (`syncfusion_flutter_pdf`) for robust annotation handling.
- Cross‑platform file picking with `file_picker`.
- Android permissions via `permission_handler`.
- Write strategy
  - Overwrite when allowed.
  - Else write `<name>_cleaned.pdf` next to original or in app directory (Android fallback).

## Platform Notes

- Desktop (Linux/Windows/macOS): no special permissions; large folder scans supported.
- Android: direct overwrite can fail; fallback to app directory using `getExternalStorageDirectory()` then `getApplicationDocumentsDirectory()` as a backup.
- iOS: not explicitly targeted in workflow; core logic is platform‑agnostic.

## Extensibility

- Additional cleaners (e.g., stripping metadata or embedded files) can be added as new use cases within `domain/usecases/` and implemented in the repository.
- UI actions remain simple; consider background isolates for very large batches.
