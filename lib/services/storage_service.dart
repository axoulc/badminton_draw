import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../models/player.dart';

/// Storage service for persisting tournament data
class StorageService {
  static const String _tournamentKey = 'current_tournament';
  static const String _backupPrefix = 'backup_';

  /// Save tournament to local storage
  Future<void> saveTournament(Tournament tournament) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(tournament.toJson());
      await prefs.setString(_tournamentKey, json);
    } catch (e) {
      throw StorageException('Failed to save tournament: $e');
    }
  }

  /// Load tournament from local storage
  Future<Tournament?> loadTournament() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_tournamentKey);

      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return Tournament.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to load tournament: $e');
    }
  }

  /// Clear current tournament
  Future<void> clearTournament() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tournamentKey);
    } catch (e) {
      throw StorageException('Failed to clear tournament: $e');
    }
  }

  /// Create a backup of current tournament
  Future<String> createBackup(Tournament tournament) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupKey = '$_backupPrefix$timestamp';
      final json = jsonEncode(tournament.toJson());

      await prefs.setString(backupKey, json);
      return backupKey;
    } catch (e) {
      throw StorageException('Failed to create backup: $e');
    }
  }

  /// List all backups
  Future<List<BackupInfo>> listBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final backupKeys = keys.where((k) => k.startsWith(_backupPrefix));

      final backups = <BackupInfo>[];
      for (final key in backupKeys) {
        final json = prefs.getString(key);
        if (json != null) {
          final data = jsonDecode(json) as Map<String, dynamic>;
          final tournament = Tournament.fromJson(data);
          final timestamp = int.parse(key.substring(_backupPrefix.length));

          backups.add(
            BackupInfo(
              key: key,
              tournament: tournament,
              createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
            ),
          );
        }
      }

      // Sort by creation time, newest first
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      throw StorageException('Failed to list backups: $e');
    }
  }

  /// Restore tournament from backup
  Future<Tournament> restoreBackup(String backupKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(backupKey);

      if (json == null) {
        throw StorageException('Backup not found: $backupKey');
      }

      final data = jsonDecode(json) as Map<String, dynamic>;
      final tournament = Tournament.fromJson(data);

      // Save as current tournament
      await saveTournament(tournament);

      return tournament;
    } catch (e) {
      throw StorageException('Failed to restore backup: $e');
    }
  }

  /// Delete a backup
  Future<void> deleteBackup(String backupKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(backupKey);
    } catch (e) {
      throw StorageException('Failed to delete backup: $e');
    }
  }

  /// Export tournament as JSON string
  String exportTournament(Tournament tournament) {
    try {
      return jsonEncode(tournament.toJson());
    } catch (e) {
      throw StorageException('Failed to export tournament: $e');
    }
  }

  /// Import tournament from JSON string
  Tournament importTournament(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return Tournament.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to import tournament: $e');
    }
  }

  /// Save player preferences (for future features)
  Future<void> savePlayerPreferences(List<Player> favoritePlayers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(favoritePlayers.map((p) => p.toJson()).toList());
      await prefs.setString('favorite_players', json);
    } catch (e) {
      throw StorageException('Failed to save player preferences: $e');
    }
  }

  /// Load player preferences
  Future<List<Player>> loadPlayerPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('favorite_players');

      if (json == null) return [];

      final data = jsonDecode(json) as List;
      return data
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load player preferences: $e');
    }
  }
}

/// Backup information
class BackupInfo {
  final String key;
  final Tournament tournament;
  final DateTime createdAt;

  BackupInfo({
    required this.key,
    required this.tournament,
    required this.createdAt,
  });
}

/// Storage exception
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
