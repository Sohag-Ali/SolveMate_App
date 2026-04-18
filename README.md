# Solve Mate

Solve Mate is a Flutter app for connecting students and teachers around posted problems and requests.

## How to Set Up and Run (Any PC)

### 1. Prerequisites

Install these tools first:

- Flutter SDK: https://docs.flutter.dev/get-started/install
- Android Studio (with Android SDK) or VS Code + Flutter and Dart extensions
- A running Android emulator, or a physical Android device with USB debugging enabled

Optional for iOS/macOS development:

- Xcode (macOS only)

### 2. Verify Flutter Installation

Run:

```bash
flutter doctor
```

Resolve any issues shown before moving ahead.

### 3. Get the Project on Your PC

If you are using Git:

```bash
git clone <repository_url>
cd solve_mate
```

If you downloaded a ZIP:

1. Extract the ZIP file.
2. Open the extracted solve_mate folder in VS Code or Android Studio.
3. Open a terminal in that folder.

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App (Debug)

Check connected devices:

```bash
flutter devices
```

Run on the default available device:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device_id>
```

### 6. Build Release APK (Android)

```bash
flutter build apk --release
```

APK output path:

build/app/outputs/flutter-apk/app-release.apk

### 7. Run Tests

```bash
flutter test
```

## Useful Commands

- flutter clean
- flutter pub get
- flutter analyze

## Notes

- This project currently uses in-memory demo data, so data resets when the app restarts.
