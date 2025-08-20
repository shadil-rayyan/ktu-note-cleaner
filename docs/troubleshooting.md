# Troubleshooting

## Android cannot overwrite file

- Due to scoped storage, writes to arbitrary paths may fail.
- The app automatically saves a `<name>_cleaned.pdf` into an app‑writable directory (external storage dir if available; otherwise app documents).

## Linux library/runtime issues

- Prefer the AppImage artifact which bundles dependencies.
- Make it executable:
  ```bash
  chmod +x ktunotecleaner-*-linux-x64.AppImage
  ./ktunotecleaner-*-linux-x64.AppImage
  ```

## macOS "App is damaged or can’t be opened"

- Unsigned builds: right‑click → Open the first time.
- Signed/notarized builds (if enabled in CI) avoid this prompt.

## Windows SmartScreen

- Unsigned builds may show a warning; code signing (optional in CI) reduces it.

## UI layout overflows (RenderFlex)

- When a `Row` overflows, wrap large children with `Expanded`/`Flexible`, switch to `Wrap`, or place the row inside a horizontal `SingleChildScrollView`.

## Permission problems (mobile)

- Ensure storage permission is granted on Android. The app requests it on startup when needed.
