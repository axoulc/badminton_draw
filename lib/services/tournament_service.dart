import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/tournament.dart';
import 'pairing_service.dart';
import 'storage_service.dart';

/// Tournament service for managing tournament logic
class TournamentService {
  final PairingService _pairingService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  TournamentService({
    PairingService? pairingService,
    StorageService? storageService,
  }) : _pairingService = pairingService ?? PairingService(),
       _storageService = storageService ?? StorageService();

  /// Create a new tournament
  Tournament createTournament({
    required String name,
    required TournamentMode mode,
  }) {
    return Tournament(
      id: _uuid.v4(),
      name: name,
      mode: mode,
      status: TournamentStatus.setup,
      players: [],
      rounds: [],
    );
  }

  /// Add a player to the tournament
  Tournament addPlayer(Tournament tournament, String playerName) {
    // Validate player name
    final trimmedName = playerName.trim();
    if (trimmedName.isEmpty) {
      throw TournamentException('Player name cannot be empty');
    }

    // Check for duplicate names
    if (tournament.players.any(
      (p) => p.name.toLowerCase() == trimmedName.toLowerCase(),
    )) {
      throw TournamentException('Player "$trimmedName" already exists');
    }

    // Create new player
    final player = Player(id: _uuid.v4(), name: trimmedName);

    // Add to tournament
    final updatedPlayers = List<Player>.from(tournament.players)..add(player);

    return tournament.copyWith(
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a player from the tournament
  Tournament removePlayer(Tournament tournament, String playerId) {
    // Can only remove players during setup
    if (tournament.status != TournamentStatus.setup) {
      throw TournamentException(
        'Cannot remove players after tournament starts',
      );
    }

    final updatedPlayers = tournament.players
        .where((p) => p.id != playerId)
        .toList();

    return tournament.copyWith(
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
  }

  /// Update player information
  Tournament updatePlayer(
    Tournament tournament,
    String playerId,
    String newName,
  ) {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw TournamentException('Player name cannot be empty');
    }

    // Check for duplicate names (excluding current player)
    if (tournament.players.any(
      (p) =>
          p.id != playerId && p.name.toLowerCase() == trimmedName.toLowerCase(),
    )) {
      throw TournamentException('Player "$trimmedName" already exists');
    }

    final updatedPlayers = tournament.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(name: trimmedName);
      }
      return p;
    }).toList();

    return tournament.copyWith(
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
  }

  /// Import multiple players from JSON list
  Tournament importPlayers(Tournament tournament, List<String> playerNames) {
    if (tournament.status != TournamentStatus.setup) {
      throw TournamentException(
        'Cannot import players after tournament starts',
      );
    }

    final existingNames = tournament.players
        .map((p) => p.name.toLowerCase())
        .toSet();
    final newPlayers = <Player>[];
    final duplicates = <String>[];

    for (final name in playerNames) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) continue;

      final lowerName = trimmedName.toLowerCase();
      if (existingNames.contains(lowerName)) {
        duplicates.add(trimmedName);
        continue;
      }

      existingNames.add(lowerName);
      newPlayers.add(Player(id: _uuid.v4(), name: trimmedName));
    }

    if (duplicates.isNotEmpty && newPlayers.isEmpty) {
      throw TournamentException(
        'All players already exist: ${duplicates.join(", ")}',
      );
    }

    final updatedPlayers = List<Player>.from(tournament.players)
      ..addAll(newPlayers);

    return tournament.copyWith(
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
  }

  /// Update tournament scoring settings
  Tournament updateScoringSettings(
    Tournament tournament,
    int winnerPoints,
    int loserPoints,
  ) {
    if (winnerPoints < 0 || loserPoints < 0) {
      throw TournamentException('Points cannot be negative');
    }

    return tournament.copyWith(
      winnerPoints: winnerPoints,
      loserPoints: loserPoints,
      updatedAt: DateTime.now(),
    );
  }

  /// Start the tournament
  Tournament startTournament(Tournament tournament) {
    if (!tournament.canStart) {
      throw TournamentException(
        'Cannot start tournament. Need at least ${tournament.minPlayers} players.',
      );
    }

    return tournament.copyWith(
      status: TournamentStatus.active,
      updatedAt: DateTime.now(),
    );
  }

  /// Generate a new round
  Tournament generateRound(Tournament tournament) {
    if (tournament.status != TournamentStatus.active) {
      throw TournamentException('Tournament must be active to generate rounds');
    }

    // Generate the round
    final round = _pairingService.generateRound(
      tournament: tournament,
      players: tournament.players,
    );

    // Add to tournament
    final updatedRounds = List<Round>.from(tournament.rounds)..add(round);

    return tournament.copyWith(
      rounds: updatedRounds,
      updatedAt: DateTime.now(),
    );
  }

  /// Record match result
  Tournament recordMatchResult(
    Tournament tournament,
    String roundId,
    String matchId,
    String winnerId, // 'team1' or 'team2'
  ) {
    if (winnerId != 'team1' && winnerId != 'team2') {
      throw TournamentException('Winner must be either "team1" or "team2"');
    }

    // Find the original match before updating
    final originalMatch = tournament.rounds
        .firstWhere((r) => r.id == roundId)
        .matches
        .firstWhere((m) => m.id == matchId);

    // Check if match was already completed
    final wasCompleted = originalMatch.isCompleted;
    final oldWinnerId = originalMatch.winnerId;

    // Find the round and match
    final updatedRounds = tournament.rounds.map((round) {
      if (round.id == roundId) {
        final updatedMatches = round.matches.map((match) {
          if (match.id == matchId) {
            return match.copyWith(winnerId: winnerId);
          }
          return match;
        }).toList();
        return round.copyWith(matches: updatedMatches);
      }
      return round;
    }).toList();

    // Update player statistics
    var updatedPlayers = tournament.players;

    // If match was already completed, first remove old scores
    if (wasCompleted && oldWinnerId != null) {
      updatedPlayers = _removeMatchStats(
        updatedPlayers,
        originalMatch,
        oldWinnerId,
        tournament,
      );
    }

    // Add new scores
    updatedPlayers = _addMatchStats(
      updatedPlayers,
      originalMatch,
      winnerId,
      tournament,
    );

    return tournament.copyWith(
      players: updatedPlayers,
      rounds: updatedRounds,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove player statistics from a match (for editing results)
  List<Player> _removeMatchStats(
    List<Player> players,
    Match match,
    String winnerId,
    Tournament tournament,
  ) {
    final winningTeam = winnerId == 'team1' ? match.team1 : match.team2;
    final losingTeam = winnerId == 'team1' ? match.team2 : match.team1;

    return players.map((player) {
      // Check if player was in winning team
      if (winningTeam.any((p) => p.id == player.id)) {
        return player.copyWith(
          wins: player.wins - 1,
          points: player.points - tournament.winnerPoints,
        );
      }

      // Check if player was in losing team
      if (losingTeam.any((p) => p.id == player.id)) {
        return player.copyWith(
          losses: player.losses - 1,
          points: player.points - tournament.loserPoints,
        );
      }

      return player;
    }).toList();
  }

  /// Add player statistics after a match
  List<Player> _addMatchStats(
    List<Player> players,
    Match match,
    String winnerId,
    Tournament tournament,
  ) {
    final winningTeam = winnerId == 'team1' ? match.team1 : match.team2;
    final losingTeam = winnerId == 'team1' ? match.team2 : match.team1;

    return players.map((player) {
      // Check if player is in winning team
      if (winningTeam.any((p) => p.id == player.id)) {
        return player.copyWith(
          wins: player.wins + 1,
          points: player.points + tournament.winnerPoints,
        );
      }

      // Check if player is in losing team
      if (losingTeam.any((p) => p.id == player.id)) {
        return player.copyWith(
          losses: player.losses + 1,
          points: player.points + tournament.loserPoints,
        );
      }

      return player;
    }).toList();
  }

  /// Complete the tournament
  Tournament completeTournament(Tournament tournament) {
    return tournament.copyWith(
      status: TournamentStatus.completed,
      updatedAt: DateTime.now(),
    );
  }

  /// Reset tournament to setup
  Tournament resetTournament(Tournament tournament) {
    // Reset all player stats
    final resetPlayers = tournament.players
        .map(
          (p) => Player(id: p.id, name: p.name, wins: 0, losses: 0, points: 0),
        )
        .toList();

    return tournament.copyWith(
      status: TournamentStatus.setup,
      players: resetPlayers,
      rounds: [],
      updatedAt: DateTime.now(),
    );
  }

  /// Get rankings (sorted by points, then win rate)
  List<Player> getRankings(Tournament tournament) {
    final players = List<Player>.from(tournament.players);

    players.sort((a, b) {
      // First sort by points (descending)
      final pointsCompare = b.points.compareTo(a.points);
      if (pointsCompare != 0) return pointsCompare;

      // Then by win rate (descending)
      final winRateCompare = b.winRate.compareTo(a.winRate);
      if (winRateCompare != 0) return winRateCompare;

      // Then by total wins (descending)
      final winsCompare = b.wins.compareTo(a.wins);
      if (winsCompare != 0) return winsCompare;

      // Finally by name (ascending)
      return a.name.compareTo(b.name);
    });

    return players;
  }

  /// Get tournament statistics
  TournamentStats getStatistics(Tournament tournament) {
    final totalMatches = tournament.rounds.expand((r) => r.matches).length;

    final completedMatches = tournament.rounds
        .expand((r) => r.matches)
        .where((m) => m.isCompleted)
        .length;

    final activePlayers = tournament.players
        .where((p) => p.totalMatches > 0)
        .length;

    final totalPoints = tournament.players.fold<int>(
      0,
      (sum, p) => sum + p.points,
    );

    final averagePointsPerPlayer = tournament.players.isNotEmpty
        ? totalPoints / tournament.players.length
        : 0.0;

    return TournamentStats(
      totalRounds: tournament.rounds.length,
      totalMatches: totalMatches,
      completedMatches: completedMatches,
      pendingMatches: totalMatches - completedMatches,
      totalPlayers: tournament.players.length,
      activePlayers: activePlayers,
      totalPoints: totalPoints,
      averagePoints: averagePointsPerPlayer,
    );
  }

  /// Save tournament to storage
  Future<void> saveTournament(Tournament tournament) async {
    await _storageService.saveTournament(tournament);
  }

  /// Load tournament from storage
  Future<Tournament?> loadTournament() async {
    return await _storageService.loadTournament();
  }

  /// Create backup
  Future<String> createBackup(Tournament tournament) async {
    return await _storageService.createBackup(tournament);
  }

  /// Export tournament as JSON
  String exportTournament(Tournament tournament) {
    return _storageService.exportTournament(tournament);
  }

  /// Import tournament from JSON
  Tournament importTournament(String json) {
    return _storageService.importTournament(json);
  }
}

/// Tournament statistics
class TournamentStats {
  final int totalRounds;
  final int totalMatches;
  final int completedMatches;
  final int pendingMatches;
  final int totalPlayers;
  final int activePlayers;
  final int totalPoints;
  final double averagePoints;

  TournamentStats({
    required this.totalRounds,
    required this.totalMatches,
    required this.completedMatches,
    required this.pendingMatches,
    required this.totalPlayers,
    required this.activePlayers,
    required this.totalPoints,
    required this.averagePoints,
  });

  double get completionRate =>
      totalMatches > 0 ? completedMatches / totalMatches : 0.0;

  double get playerParticipationRate =>
      totalPlayers > 0 ? activePlayers / totalPlayers : 0.0;
}

/// Export tournament to JSON string (for backup)
String exportTournamentToJson(Tournament tournament) {
  final jsonData = tournament.toJson();
  return const JsonEncoder.withIndent('  ').convert(jsonData);
}

/// Import tournament from JSON string (restore from backup)
Tournament importTournamentFromJson(String jsonString) {
  try {
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return Tournament.fromJson(jsonData);
  } catch (e) {
    throw TournamentException('Invalid backup file format: $e');
  }
}

/// Tournament exception
class TournamentException implements Exception {
  final String message;
  TournamentException(this.message);

  @override
  String toString() => 'TournamentException: $message';
}
