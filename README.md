# 🏸 Badminton Tournament Manager

A modern, cross-platform tournament management system for badminton competitions. Built with Flutter for web, Android, and more.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📋 Table of Contents

- [Features](#-features)
- [Technical Specifications](#-technical-specifications)
- [Getting Started](#-getting-started)
- [Compilation](#-compilation)
- [Deployment](#-deployment)
  - [Android (Mobile)](#-android-deployment)
  - [Docker Compose (Self-Hosted)](#-docker-compose-deployment)
  - [GitHub Pages (Free Hosting)](#-github-pages-deployment)
- [Documentation](#-documentation)
- [Usage Guide](#-usage-guide)

## ✨ Features

### Core Functionality

- **🎯 Tournament Modes**
  - Singles (1v1) matches
  - Doubles (2v2) matches
  
- **👥 Player Management**
  - Add/remove players individually
  - Bulk import via JSON
  - Duplicate detection
  - Player statistics tracking

- **🔄 Smart Pairing Algorithm**
  - Swiss-system inspired pairing
  - Minimizes repeated matchups
  - Balanced match distribution
  - Automatic round generation

- **📊 Rankings & Statistics**
  - Real-time leaderboard
  - Win/loss records
  - Points calculation
  - Participation tracking

- **⚙️ Customization**
  - Configurable scoring system (winner/loser points)
  - Tournament status management
  - Match result editing
  - Round reset capability

### Advanced Features

- **💾 Backup & Restore**
  - Export complete tournament as JSON
  - Import from backup file
  - Cross-device compatibility
  - Tournament sharing

- **📱 Responsive Design**
  - Material Design 3
  - Light/Dark theme support
  - Mobile-friendly interface
  - Progressive Web App ready

- **🔒 Data Persistence**
  - Local storage (browser-based)
  - Automatic save on changes
  - No server required

## 🔧 Technical Specifications

### Technology Stack

- **Framework**: Flutter 3.9.2+
- **Language**: Dart 3.9.2+
- **State Management**: Provider pattern
- **Storage**: SharedPreferences (browser localStorage)
- **UI**: Material Design 3

### Project Structure

```
lib/
├── main.dart                    # Application entry point
├── models/                      # Data models
│   ├── player.dart             # Player model
│   ├── match.dart              # Match model
│   ├── round.dart              # Round model
│   └── tournament.dart         # Tournament model
├── providers/                   # State management
│   └── tournament_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart        # Main navigation
│   ├── setup_screen.dart       # Tournament creation
│   ├── players_screen.dart     # Player management
│   ├── rounds_screen.dart      # Match scoring
│   ├── rankings_screen.dart    # Leaderboard
│   └── settings_screen.dart    # Configuration
└── services/                    # Business logic
    ├── tournament_service.dart # Tournament operations
    ├── pairing_service.dart    # Match pairing algorithm
    └── storage_service.dart    # Data persistence
```

### Key Dependencies

```yaml
dependencies:
  provider: ^6.1.2           # State management
  shared_preferences: ^2.2.3 # Local storage
  uuid: ^4.4.0               # Unique ID generation
```

### Pairing Algorithm

The tournament uses a sophisticated Swiss-system inspired algorithm:

1. Sorts players by points (descending)
2. Finds valid pairings based on match history
3. Minimizes repeated matchups
4. Handles odd player counts (bye system)
5. Supports both singles and doubles formats

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.9.2 or higher
- Chrome, Edge, or Firefox browser (for web)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/axoulc/badminton_draw.git
   cd badminton_draw
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web (Chrome)
   flutter run -d chrome --web-port 8080
   
   # For specific browser
   flutter run -d edge
   flutter run -d firefox
   ```

4. **Access the application**
   ```
   http://localhost:8080
   ```

## 🔨 Compilation

### Development Build

```bash
# Web development build with hot reload
flutter run -d chrome

# With custom port
flutter run -d chrome --web-port 8080
```

### Production Build

```bash
# Build optimized web application
flutter build web --release

# Output directory: build/web/
# Files are ready to deploy to any static hosting
```

### Build Options

```bash
# HTML renderer (better compatibility, smaller size)
flutter build web --release
```

### Code Quality

```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
```

## 🚀 Deployment

This project supports three primary deployment methods: **Android APK/Bundle** for mobile devices, **Docker Compose** for self-hosted servers, and **GitHub Pages** for free cloud hosting with automated CI/CD.

---

## 📱 Android Deployment

Deploy the tournament manager as a native Android application.

### Prerequisites

- Android SDK installed (via Android Studio)
- Android device or emulator
- USB debugging enabled (for physical devices)

### Development Build

1. **Connect your Android device or start emulator**
   ```bash
   # Check connected devices
   flutter devices
   ```

2. **Run on device**
   ```bash
   cd /home/axel-fpoc/badminton_draw
   flutter run
   ```

### Production APK Build

Build an APK for distribution:

```bash
# Build release APK
flutter build apk --release

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

### Split APK by ABI (Recommended)

Build separate APKs for different CPU architectures (smaller file sizes):

```bash
# Build split APKs
flutter build apk --split-per-abi --release

# Generates:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (64-bit Intel)
```

### Android App Bundle (Google Play)

For publishing to Google Play Store:

```bash
# Build app bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### App Configuration

The app includes:

- ✅ **App Name**: "Badminton Tournament"
- ✅ **Icon**: Custom badminton icon (🏸) with blue background
- ✅ **Permissions**: Internet access, Network state
- ✅ **Orientation**: Supports portrait and landscape
- ✅ **Min SDK**: Android 21 (Lollipop 5.0)

### Permissions Included

The app requests minimal permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Installing APK

**Via USB (ADB):**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Direct Install:**
- Transfer APK to device
- Enable "Install from Unknown Sources"
- Tap APK file to install

### Signing APK for Distribution

For production release, you need to sign the APK:

1. **Create a keystore:**
   ```bash
   keytool -genkey -v -keystore ~/badminton-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias badminton
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=badminton
   storeFile=<path-to-keystore>/badminton-key.jks
   ```

3. **Update `android/app/build.gradle.kts`:**
   Add before `android` block:
   ```kotlin
   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }
   ```

   In `android { ... }` block:
   ```kotlin
   signingConfigs {
       create("release") {
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

4. **Build signed APK:**
   ```bash
   flutter build apk --release
   ```

### Troubleshooting Android

```bash
# Clear build cache
flutter clean
flutter pub get

# Check for issues
flutter doctor

# View device logs
flutter logs

# Build with verbose output
flutter build apk --release --verbose
```

---

## 🐳 Docker Compose Deployment

Deploy the tournament manager on your own server using Docker Compose for full control and customization.

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Port 8080 available (or modify in `docker-compose.yml`)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/axoulc/badminton_draw.git
   cd badminton_draw
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   ```
   http://localhost:8080
   ```

### Docker Compose Configuration

The `docker-compose.yml` file includes:

```yaml
version: '3.8'

services:
  badminton-tournament:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: badminton-tournament
    ports:
      - "8080:80"
    restart: unless-stopped
    environment:
      - TZ=Europe/Paris
```

### Management Commands

```bash
# Start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# Check status
docker-compose ps
```

### Custom Configuration

**Change the port:**
Edit `docker-compose.yml`:
```yaml
ports:
  - "3000:80"  # Access on port 3000
```

**Set timezone:**
```yaml
environment:
  - TZ=America/New_York
```

**Add reverse proxy (Nginx/Traefik):**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.badminton.rule=Host(`badminton.yourdomain.com`)"
  - "traefik.http.services.badminton.loadbalancer.server.port=80"
```

### Production Deployment

For production servers, consider:

1. **Use HTTPS with reverse proxy:**
   ```bash
   # Example with Nginx
   sudo apt install nginx certbot python3-certbot-nginx
   sudo certbot --nginx -d badminton.yourdomain.com
   ```

2. **Configure Nginx as reverse proxy:**
   ```nginx
   server {
       listen 80;
       server_name badminton.yourdomain.com;
       
       location / {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. **Enable automatic restarts:**
   ```yaml
   restart: unless-stopped  # Already configured
   ```

4. **Set up logging:**
   ```yaml
   logging:
     driver: "json-file"
     options:
       max-size: "10m"
       max-file: "3"
   ```

### Troubleshooting Docker Deployment

```bash
# Check container logs
docker-compose logs badminton-tournament

# Access container shell
docker-compose exec badminton-tournament sh

# Check port conflicts
sudo netstat -tulpn | grep 8080

# Remove all containers and volumes
docker-compose down -v
```

---

## 📄 GitHub Pages Deployment

Deploy for free with automated CI/CD using GitHub Actions. Every push to the main branch automatically builds and deploys your application.

### Prerequisites

- GitHub account
- Repository forked or cloned from `axoulc/badminton_draw`

### One-Time Setup

1. **Enable GitHub Pages**
   - Go to your repository on GitHub
   - Navigate to **Settings** → **Pages**
   - Under "Build and deployment":
     - **Source**: Select "GitHub Actions"

2. **Configure Repository Secrets (Optional)**
   - For advanced configurations, go to **Settings** → **Secrets and variables** → **Actions**
   - No secrets required for basic deployment

### Automatic Deployment

The repository includes a complete CI/CD workflow (`.github/workflows/deploy.yml`) that automatically:

1. ✅ **Builds** the Flutter web application
2. ✅ **Runs** static analysis (`flutter analyze`)
3. ✅ **Tests** the application (`flutter test`)
4. ✅ **Deploys** to GitHub Pages

**Trigger deployment:**
```bash
# Simply push to main branch
git add .
git commit -m "Update application"
git push origin main
```

**Deployment URL:**
```
https://<your-username>.github.io/<repository-name>/
```

Example: `https://axoulc.github.io/badminton_draw/`

### CI/CD Workflow Details

The workflow (`.github/workflows/deploy.yml`) includes:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:  # Manual trigger

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Setup Flutter 3.9.2
      - Get dependencies
      - Analyze code
      - Run tests
      - Build web application
      - Upload artifact

  deploy:
    needs: build
    environment: github-pages
    steps:
      - Deploy to GitHub Pages
```

### Manual Deployment Trigger

You can also trigger deployment manually:

1. Go to **Actions** tab in your repository
2. Select "Deploy to GitHub Pages" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

### Custom Domain (Optional)

1. **Add CNAME file:**
   ```bash
   echo "badminton.yourdomain.com" > web/CNAME
   git add web/CNAME
   git commit -m "Add custom domain"
   git push
   ```

2. **Configure DNS:**
   - Add CNAME record pointing to `<username>.github.io`

3. **Enable in GitHub:**
   - Go to **Settings** → **Pages**
   - Enter your custom domain
   - Enable "Enforce HTTPS"

### Monitoring Deployments

- **View deployment status:** Check the **Actions** tab
- **Deployment history:** **Settings** → **Pages** → **Visit site**
- **Build logs:** Click on any workflow run in Actions tab

### Troubleshooting GitHub Pages

**Deployment failed:**
```bash
# Check workflow logs in Actions tab
# Common issues:
# - Pages not enabled in repository settings
# - Incorrect base-href in flutter build command
```

**404 errors after deployment:**
```bash
# Verify base-href matches repository name
flutter build web --release --base-href "/<repo-name>/"
```

**Changes not reflecting:**
```bash
# Clear browser cache or use incognito mode
# GitHub Pages CDN may take 1-2 minutes to update
```

---

## 📚 Documentation

- **[NEW_FEATURES.md](NEW_FEATURES.md)** - Recently added features and detailed usage
- **[BACKUP_RESTORE.md](BACKUP_RESTORE.md)** - Complete backup/restore guide
- **[DOCKER.md](DOCKER.md)** - Docker deployment instructions
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

## 🎮 Usage Guide

### Creating a Tournament

1. Open the application in your browser
2. Enter tournament details:
   - **Name**: e.g., "Summer Championship 2025"
   - **Mode**: Choose Singles (1v1) or Doubles (2v2)
3. Add players:
   - **Manually**: Click "Add Player" and enter names
   - **Bulk Import**: Click "Import Players (JSON)" and paste:
     ```json
     ["Élise", "Mathieu", "Camille", "Julien", "Sophie", "Clément", "Aurélie", "Bastien", "Manon", "Thibault", "Amélie", "Guillaume", "Océane", "Nicolas", "Chloé", "Romain", "Anaïs", "Hugo", "Charlotte", "Adrien"]
     ```
4. Click **"Start Tournament"** when you have minimum players:
   - Singles: 4 players minimum
   - Doubles: 8 players minimum (4 teams)

### Running Rounds

1. **Generate Round**: Click "Generate Round" button
2. **Record Results**: Tap on the winning team for each match
3. **Edit Results**: Click edit icon (✏️) to change winner if needed
4. **View Rankings**: Check the Rankings tab for real-time standings
5. **Continue**: Generate next round when all matches are complete

### Managing Your Tournament

**Settings:**
- Adjust winner points (default: 2)
- Adjust loser points (default: 1)
- Changes apply to future matches only

**Backup & Restore:**
- **Export**: Menu → "Export Backup" (saves JSON file)
- **Import**: Menu → "Import Backup" (restores tournament)

**Tournament Actions:**
- **Reset**: Clear all rounds but keep players
- **Delete**: Remove entire tournament

### Scoring System

Default scoring:
- **Winner**: 2 points
- **Loser**: 1 point

Configurable in Settings menu.

## 🛠️ Development

### Project Setup

```bash
# Get dependencies
flutter pub get

# Run analyzer
flutter analyze

# Format code
flutter format lib/

# Clean build artifacts
flutter clean
```

### Architecture Patterns

- **State Management**: Provider pattern with ChangeNotifier
- **Service Layer**: Business logic separated from UI
- **Repository Pattern**: Storage abstraction layer
- **Immutability**: Models use `copyWith` for safe updates

### Code Quality Standards

- ✅ No compilation errors
- ✅ Static analysis passing
- ✅ Proper error handling
- ✅ User feedback for actions
- ✅ Responsive design

## �� Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**axoulc**
- GitHub: [@axoulc](https://github.com/axoulc)
- Repository: [badminton_draw](https://github.com/axoulc/badminton_draw)

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Material Design team for the design system
- Swiss-system tournament format for pairing inspiration
- Cirrus Labs for the Flutter Docker image
- GitHub Actions for seamless CI/CD automation

## 📞 Support

For issues, questions, or feature requests:

- **Issues**: [GitHub Issues](https://github.com/axoulc/badminton_draw/issues)
- **Documentation**: See [Documentation](#-documentation) section
- **Troubleshooting**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Built with ❤️ using Flutter**

*No backend required • Works offline • Privacy-focused*
