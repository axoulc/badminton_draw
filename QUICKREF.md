# Quick Reference - Badminton Tournament Manager

## 🎯 Most Important Commands

```bash
# Run the app (Web)
flutter run -d chrome --web-port 8080

# Run the app (Android)
flutter run -d android

# Hot reload (press in terminal)
r

# Open in browser
http://localhost:8080
```

## 📱 App Navigation

1. **Setup Screen** - Create tournament, add players
2. **Players Tab** - View all players with stats
3. **Rounds Tab** - Generate rounds, score matches
4. **Rankings Tab** - View leaderboard

## 🎮 How to Use

### Create Tournament
1. Enter tournament name
2. Select mode (Singles or Doubles)
3. Click "Create Tournament"

### Add Players
1. Type player name
2. Click "Add" or press Enter
3. Repeat for all players
4. Click "Start Tournament" when ready

### Play Tournament
1. Go to "Rounds" tab
2. Click "Generate Round"
3. Tap on teams to score matches
4. Winner highlighted in green
5. Check "Rankings" tab for standings

### Scoring System
- **Winner:** +2 points
- **Loser:** +1 point

### Tournament Modes
- **Singles:** 1v1, minimum 2 players
- **Doubles:** 2v2, minimum 4 players

## 🛠️ Development

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Clean build
flutter clean && flutter pub get

# Build for production
flutter build web --release
flutter build apk --release
```

## 📊 Project Files

```
lib/
├── main.dart              # Entry point
├── models/                # Data models
├── services/              # Business logic
├── providers/             # State management
└── screens/               # UI screens
```

## ⚡ Hot Keys (in terminal)

- `r` - Hot reload
- `R` - Hot restart
- `d` - Open DevTools
- `c` - Clear console
- `q` - Quit app

## 📖 Documentation

- `README.md` - Project overview
- `DEVELOPMENT.md` - Developer guide
- `FEATURE_CHECKLIST.md` - Testing guide
- `FLUTTER_MIGRATION.md` - Migration details
- `PROJECT_SUMMARY.md` - Complete summary

## 🔗 Useful Links

- Flutter Docs: https://docs.flutter.dev/
- Dart Docs: https://dart.dev/
- Material 3: https://m3.material.io/

## ✅ Quick Test

1. Open http://localhost:8080
2. Create tournament "Test"
3. Choose Doubles mode
4. Add 4 players
5. Start tournament
6. Generate round
7. Score matches
8. Check rankings

**Done! 🎉**
