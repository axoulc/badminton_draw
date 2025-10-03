# 🏸 Badminton Tournament Manager

A modern, web-based tournament management system for badminton competitions. Built with Flutter for seamless cross-platform support.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📋 Table of Contents

- [Features](#-features)
- [Technical Specifications](#-technical-specifications)
- [Getting Started](#-getting-started)
- [Compilation](#-compilation)
- [Docker Deployment](#-docker-deployment)
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

## 🐳 Docker Deployment

The project includes a production-ready Dockerfile using the official Cirrus Labs Flutter image.

### Quick Start

**Build Docker image:**
```bash
docker build -t badminton-tournament .
```

**Run container:**
```bash
docker run -d -p 8080:80 --name badminton badminton-tournament
```

**Access application:**
```
http://localhost:8080
```

### Docker Configuration

- **Build Image**: `ghcr.io/cirruslabs/flutter:3.35.5`
- **Runtime Image**: `nginx:alpine`
- **Exposed Port**: 80
- **Final Image Size**: ~50MB

### Docker Compose (Optional)

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  badminton:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped
```

Run with:
```bash
docker-compose up -d
```

### Cloud Deployment with Docker

**Google Cloud Run:**
```bash
gcloud builds submit --tag gcr.io/PROJECT-ID/badminton
gcloud run deploy badminton --image gcr.io/PROJECT-ID/badminton --platform managed
```

**AWS ECS/Fargate:**
```bash
aws ecr create-repository --repository-name badminton
docker tag badminton-tournament:latest AWS_ACCOUNT.dkr.ecr.REGION.amazonaws.com/badminton:latest
docker push AWS_ACCOUNT.dkr.ecr.REGION.amazonaws.com/badminton:latest
```

**Azure Container Instances:**
```bash
az acr create --resource-group myResourceGroup --name myRegistry --sku Basic
az acr build --registry myRegistry --image badminton:latest .
az container create --resource-group myResourceGroup --name badminton --image myRegistry.azurecr.io/badminton:latest --dns-name-label badminton --ports 80
```

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

## 🌐 Static Hosting Deployment

The built application can be deployed to any static hosting service:

### Netlify

```bash
flutter build web --release
# Deploy build/web/ directory via Netlify dashboard or CLI
netlify deploy --prod --dir=build/web
```

### Vercel

```bash
flutter build web --release
# Deploy using Vercel CLI
vercel --prod build/web
```

### Firebase Hosting

```bash
flutter build web --release
firebase init hosting
firebase deploy
```

### GitHub Pages

```bash
flutter build web --release --base-href "/badminton_draw/"
# Push build/web/ to gh-pages branch
```

### AWS S3 + CloudFront

```bash
flutter build web --release
aws s3 sync build/web/ s3://your-bucket-name/
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

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

## 📞 Support

For issues, questions, or feature requests:

- **Issues**: [GitHub Issues](https://github.com/axoulc/badminton_draw/issues)
- **Documentation**: See [Documentation](#-documentation) section
- **Troubleshooting**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Built with ❤️ using Flutter**

*No backend required • Works offline • Privacy-focused*
