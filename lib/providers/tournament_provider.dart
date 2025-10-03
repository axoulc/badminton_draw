import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../models/player.dart';
import '../services/tournament_service.dart';

/// App state provider managing the tournament
class TournamentProvider extends ChangeNotifier {
  final TournamentService _tournamentService;

  Tournament? _tournament;
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr');

  TournamentProvider({TournamentService? tournamentService})
    : _tournamentService = tournamentService ?? TournamentService() {
    _loadTournament();
    _loadPreferences();
  }

  // Getters
  Tournament? get tournament => _tournament;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTournament => _tournament != null;
  bool get canGenerateRound =>
      _tournament != null && _tournament!.status == TournamentStatus.active;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// Load user preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString('theme_mode');
      final languageCode = prefs.getString('language_code');

      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      if (languageCode != null) {
        _locale = Locale(languageCode);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Update locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Load tournament from storage
  Future<void> _loadTournament() async {
    _setLoading(true);
    try {
      _tournament = await _tournamentService.loadTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to load tournament: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new tournament
  Future<void> createTournament({
    required String name,
    required TournamentMode mode,
  }) async {
    _setLoading(true);
    try {
      _tournament = _tournamentService.createTournament(name: name, mode: mode);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to create tournament: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a player
  Future<void> addPlayer(String name) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.addPlayer(_tournament!, name);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to add player: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a player
  Future<void> removePlayer(String playerId) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.removePlayer(_tournament!, playerId);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to remove player: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a player
  Future<void> updatePlayer(String playerId, String newName) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.updatePlayer(
        _tournament!,
        playerId,
        newName,
      );
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to update player: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Import multiple players from list
  Future<void> importPlayers(List<String> playerNames) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.importPlayers(_tournament!, playerNames);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to import players: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update scoring settings
  Future<void> updateScoringSettings(int winnerPoints, int loserPoints) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.updateScoringSettings(
        _tournament!,
        winnerPoints,
        loserPoints,
      );
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to update scoring settings: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Start the tournament
  Future<void> startTournament() async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.startTournament(_tournament!);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to start tournament: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate a new round
  Future<void> generateRound() async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.generateRound(_tournament!);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to generate round: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Regenerate an existing non-finished round with new random pairings
  Future<void> regenerateRound(String roundId) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      // Find the round
      final roundIndex = _tournament!.rounds.indexWhere((r) => r.id == roundId);
      if (roundIndex == -1) {
        throw Exception('Round not found');
      }

      final round = _tournament!.rounds[roundIndex];

      // Check if round is already finished
      if (round.isCompleted) {
        throw Exception('Cannot regenerate a finished round');
      }

      // Remove the old round
      final updatedRounds = List.of(_tournament!.rounds);
      updatedRounds.removeAt(roundIndex);

      _tournament = _tournament!.copyWith(rounds: updatedRounds);

      // Generate a new round with the same round number
      _tournament = _tournamentService.generateRound(_tournament!);

      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to regenerate round: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Record a match result
  Future<void> recordMatchResult({
    required String roundId,
    required String matchId,
    required String winnerId,
  }) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.recordMatchResult(
        _tournament!,
        roundId,
        matchId,
        winnerId,
      );
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to record match result: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Swap two players between teams in a match
  Future<void> swapMatchPlayers({
    required String roundId,
    required String matchId,
    required String player1Id,
    required String player2Id,
  }) async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.swapMatchPlayers(
        tournament: _tournament!,
        roundId: roundId,
        matchId: matchId,
        player1Id: player1Id,
        player2Id: player2Id,
      );
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to swap players: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete the tournament
  Future<void> completeTournament() async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.completeTournament(_tournament!);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to complete tournament: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset the tournament
  Future<void> resetTournament() async {
    if (_tournament == null) return;

    _setLoading(true);
    try {
      _tournament = _tournamentService.resetTournament(_tournament!);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to reset tournament: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete the tournament
  Future<void> deleteTournament() async {
    _setLoading(true);
    try {
      _tournament = null;
      await _tournamentService.saveTournament(_tournament!);
      _clearError();
    } catch (e) {
      _setError('Failed to delete tournament: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get rankings
  List<Player> getRankings() {
    if (_tournament == null) return [];
    return _tournamentService.getRankings(_tournament!);
  }

  /// Get statistics
  dynamic getStatistics() {
    if (_tournament == null) return null;
    return _tournamentService.getStatistics(_tournament!);
  }

  /// Export tournament
  String exportTournament() {
    if (_tournament == null) return '';
    return _tournamentService.exportTournament(_tournament!);
  }

  /// Import tournament
  Future<void> importTournament(String json) async {
    _setLoading(true);
    try {
      _tournament = _tournamentService.importTournament(json);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to import tournament: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Create backup
  Future<String> createBackup() async {
    if (_tournament == null) throw Exception('No tournament to backup');
    return await _tournamentService.createBackup(_tournament!);
  }

  /// Export tournament as JSON string (for file download)
  String exportBackupJson() {
    if (_tournament == null) throw Exception('No tournament to export');
    return exportTournamentToJson(_tournament!);
  }

  /// Import tournament from JSON string (restore from file)
  Future<void> importBackupJson(String jsonString) async {
    _setLoading(true);
    try {
      _tournament = importTournamentFromJson(jsonString);
      await _saveTournament();
      _clearError();
    } catch (e) {
      _setError('Failed to import backup: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Save tournament to storage
  Future<void> _saveTournament() async {
    if (_tournament != null) {
      await _tournamentService.saveTournament(_tournament!);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
