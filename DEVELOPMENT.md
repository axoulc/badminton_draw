# 🚀 Development Quick Start

## Current Status
✅ **App is running on Chrome at http://localhost:8080**

The Flutter badminton tournament manager is fully functional with:
- Tournament creation (Singles/Doubles)
- Player management
- Round generation with Fisher-Yates algorithm
- Match scoring
- Real-time rankings
- Data persistence

## Quick Commands

### Running the App
```bash
# Web (Chrome) - Currently Running
flutter run -d chrome --web-port 8080

# Web (Any browser)
flutter run -d web-server --web-port 8080

# Android
flutter run -d android

# List available devices
flutter devices
```

### Development Workflow
```bash
# Hot reload (after code changes)
# Press 'r' in the terminal where flutter run is active

# Hot restart (full restart)
# Press 'R' in the terminal

# Open DevTools
# Press 'd' or visit http://127.0.0.1:9101

# Clear console
# Press 'c'

# Quit app
# Press 'q'
```

### Building for Production
```bash
# Web
flutter build web --release
# Output: build/web/

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Run tests (when tests are added)
flutter test
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## Project Structure

```
lib/
├── main.dart                        # Entry point with Provider setup
├── models/                          # Data models
│   ├── player.dart                  # Player with stats (wins, losses, points)
│   ├── match.dart                   # Match between 2 teams
│   ├── round.dart                   # Collection of matches
│   └── tournament.dart              # Tournament with mode & status
├── services/                        # Business logic
│   ├── storage_service.dart         # SharedPreferences persistence
│   ├── pairing_service.dart         # Fisher-Yates pairing algorithm
│   └── tournament_service.dart      # Tournament CRUD operations
├── providers/                       # State management
│   └── tournament_provider.dart     # ChangeNotifier for app state
└── screens/                         # UI screens
    ├── home_screen.dart             # Main navigation (bottom tabs)
    ├── setup_screen.dart            # Create tournament & add players
    ├── players_screen.dart          # Player list with stats
    ├── rounds_screen.dart           # Rounds list & match scoring
    └── rankings_screen.dart         # Leaderboard with medals
```

## Key Features

### Tournament Modes
- **Singles (1v1):** 1 player per team, min 2 players
- **Doubles (2v2):** 2 players per team, min 4 players

### Scoring System
- **Winner:** +2 points
- **Loser:** +1 point (participation)
- **Rankings:** Sorted by points → win rate → total wins → name

### Data Models
```dart
Player {
  id: String
  name: String
  wins: int
  losses: int
  points: int
  // Computed: totalMatches, winRate
}

Match {
  id: String
  team1: List<Player>
  team2: List<Player>
  winnerId: String?  // null = not played
  // Computed: isCompleted, team1Won, team2Won
}

Round {
  id: String
  number: int
  matches: List<Match>
  // Computed: isCompleted, completedCount, completionRate
}

Tournament {
  id: String
  name: String
  mode: TournamentMode  // singles | doubles
  status: TournamentStatus  // setup | active | completed
  players: List<Player>
  rounds: List<Round>
}
```

## State Management (Provider)

```dart
// Access in widget
final provider = context.watch<TournamentProvider>();
final tournament = provider.tournament;

// Methods
await provider.createTournament(name: 'My Tournament', mode: TournamentMode.doubles);
await provider.addPlayer('John Doe');
await provider.startTournament();
await provider.generateRound();
await provider.recordMatchResult(roundId: '...', matchId: '...', winnerId: 'team1');
```

## Common Development Tasks

### Adding a New Feature
1. **Update Model** (if needed) in `lib/models/`
2. **Add Service Logic** in `lib/services/`
3. **Update Provider** in `lib/providers/tournament_provider.dart`
4. **Create/Update Screen** in `lib/screens/`
5. **Test manually** with hot reload

### Debugging
1. Use `print()` or `debugPrint()` for logging
2. Press 'd' in terminal to open DevTools
3. Use breakpoints in VS Code with F5 debug
4. Check Flutter Inspector for widget tree

### Adding Dependencies
1. Add to `pubspec.yaml` under `dependencies:`
2. Run `flutter pub get`
3. Import in Dart files: `import 'package:package_name/file.dart';`

## Testing Checklist

### Setup Phase
- [ ] Create tournament with singles mode
- [ ] Create tournament with doubles mode
- [ ] Add players (valid names)
- [ ] Try duplicate player names (should fail)
- [ ] Try empty player names (should fail)
- [ ] Remove players
- [ ] Start tournament with min players
- [ ] Try start with insufficient players (should fail)

### Active Phase
- [ ] Generate first round
- [ ] View matches in rounds tab
- [ ] Score matches (tap teams)
- [ ] View updated rankings
- [ ] Generate additional rounds
- [ ] Check player stats update correctly

### Rankings
- [ ] Verify top 3 have medals
- [ ] Check sorting (points → win rate → wins)
- [ ] Verify stats (wins, losses, win rate)

### Data Persistence
- [ ] Refresh browser (should reload tournament)
- [ ] Export tournament JSON
- [ ] Create backup
- [ ] Reset tournament
- [ ] Delete tournament

## Performance Tips
- Use `const` constructors where possible
- Avoid rebuilding entire widget tree (use `Consumer` wisely)
- Use `ListView.builder` for long lists (already done)
- Profile with DevTools if performance issues arise

## Next Development Steps

### High Priority
1. Add unit tests for services
2. Add widget tests for screens
3. Handle edge cases (odd number of players)
4. Add match history view

### Medium Priority
1. CSV export for rankings
2. Player statistics trends/graphs
3. Tournament templates
4. Custom scoring rules

### Low Priority
1. iOS platform support
2. Desktop platforms
3. Cloud sync
4. Multi-tournament management

## Troubleshooting

### "Waiting for connection from debug service"
- This is normal, wait 10-20 seconds for Chrome to start
- Check if Chrome is installed and in PATH

### "Target of URI doesn't exist" errors
- Run `flutter pub get` to install dependencies
- Check if file paths are correct

### Hot reload not working
- Try hot restart (press 'R')
- If still broken, stop and restart `flutter run`

### App not updating
- Check if you saved the file
- Press 'r' for hot reload
- Check terminal for compilation errors

### Build failures
- Run `flutter clean`
- Run `flutter pub get`
- Try again

## Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Material 3 Flutter](https://m3.material.io/)

## Getting Help
1. Check Flutter documentation
2. Search pub.dev for packages
3. Check GitHub issues
4. Stack Overflow with `[flutter]` tag

---

**Happy coding! 🚀**
