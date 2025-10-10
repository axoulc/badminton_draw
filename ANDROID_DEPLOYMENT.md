# Android Deployment Configuration

## Changes Made

### 1. Platform Support Added
- Generated Android platform files using `flutter create --platforms=android .`
- Created complete Android project structure with Gradle configuration
- Added Kotlin MainActivity

### 2. App Icon Configuration
- Created custom badminton icon (1024x1024) with blue background (#255EA8) and white shuttlecock emoji
- Integrated `flutter_launcher_icons: ^0.14.1` package
- Generated launcher icons for:
  - Android (adaptive icons with blue background)
  - Web (PWA icons: 192x192, 512x512, maskable variants)
  - Favicon updated

### 3. Android Permissions
Updated `android/app/src/main/AndroidManifest.xml` with:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### 4. Cross-Platform File Handling
Created platform-agnostic file service to replace `dart:html` dependency:

**New Files:**
- `lib/services/file_service.dart` - Main file service API
- `lib/services/file_download_web.dart` - Web implementation (dart:html)
- `lib/services/file_download_io.dart` - Mobile implementation (dart:io)
- `lib/services/file_download_stub.dart` - Fallback stub

**Dependencies Added:**
- `file_picker: ^8.1.4` - Cross-platform file picking
- `path_provider: ^2.1.5` - File system access for mobile

**Updated Files:**
- `lib/screens/home_screen.dart` - Replaced dart:html with FileService
- `lib/screens/setup_screen.dart` - Replaced dart:html with FileService

### 5. Web Manifest and HTML Updates
- Updated app name: "Badminton Tournament Manager"
- Added proper meta tags for mobile web
- Enhanced PWA configuration
- Updated theme colors (#255EA8)

### 6. Documentation
Added comprehensive Android deployment section to README.md:
- Development build instructions
- Production APK build
- Split APK by ABI
- Android App Bundle for Google Play
- APK signing for distribution
- Troubleshooting guide

## Build Commands

### Development
```bash
flutter run
```

### Production APK
```bash
flutter build apk --release
```

### Split APKs (Recommended)
```bash
flutter build apk --split-per-abi --release
```

### App Bundle (Google Play)
```bash
flutter build appbundle --release
```

## App Details
- **Package Name:** com.example.badminton_tournament
- **App Name:** Badminton Tournament
- **Min SDK:** Android 21 (Lollipop 5.0)
- **Target SDK:** Latest
- **Icon:** Custom badminton shuttlecock on blue background

## File Locations
- APK Output: `build/app/outputs/flutter-apk/app-release.apk`
- Split APKs: `build/app/outputs/flutter-apk/app-*-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

## Testing
1. Connect Android device via USB
2. Enable USB debugging
3. Run: `flutter devices`
4. Run: `flutter run`

## Distribution
For production, sign the APK using a keystore before distribution to users or uploading to Google Play Store.
