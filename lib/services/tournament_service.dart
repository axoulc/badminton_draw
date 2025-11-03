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

  /// Toggle player enabled status
  Tournament togglePlayerEnabled(Tournament tournament, String playerId) {
    final updatedPlayers = tournament.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(isEnabled: !p.isEnabled);
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

    // Filter to only include enabled players
    final enabledPlayers = tournament.players.where((p) => p.isEnabled).toList();

    // Generate the round
    final round = _pairingService.generateRound(
      tournament: tournament,
      players: enabledPlayers,
    );

    // Add to tournament
    final updatedRounds = List<Round>.from(tournament.rounds)..add(round);

    return tournament.copyWith(
      rounds: updatedRounds,
      updatedAt: DateTime.now(),
    );
  }

  /// Record match result using badminton game scores
  Tournament recordMatchResult(
    Tournament tournament,
    String roundId,
    String matchId,
    List<GameScore> gameScores,
  ) {
    if (gameScores.isEmpty) {
      throw TournamentException('At least two game scores are required');
    }

    final normalizedScores = List<GameScore>.from(gameScores);
    _validateGameScores(normalizedScores);

    // Locate round and match
    final roundIndex = tournament.rounds.indexWhere((round) => round.id == roundId);
    if (roundIndex == -1) {
      throw TournamentException('Round not found');
    }

    final round = tournament.rounds[roundIndex];
    final matchIndex = round.matches.indexWhere((match) => match.id == matchId);
    if (matchIndex == -1) {
      throw TournamentException('Match not found');
    }

    final originalMatch = round.matches[matchIndex];
    final wasCompleted = originalMatch.isCompleted;
    final oldWinnerId = originalMatch.winnerId;

    final winnerId = _determineWinnerFromScores(normalizedScores);

    final updatedMatch = originalMatch.copyWith(
      winnerId: winnerId,
      gameScores: normalizedScores,
    );

    // Update the round with the modified match
    final updatedMatches = List<Match>.from(round.matches);
    updatedMatches[matchIndex] = updatedMatch;
    final updatedRound = round.copyWith(matches: updatedMatches);

    final updatedRounds = List<Round>.from(tournament.rounds);
    updatedRounds[roundIndex] = updatedRound;

    // Update player statistics
    var updatedPlayers = tournament.players;

    if (wasCompleted && oldWinnerId != null) {
      updatedPlayers = _removeMatchStats(
        updatedPlayers,
        originalMatch,
        oldWinnerId,
        tournament,
      );
    }

    updatedPlayers = _addMatchStats(
      updatedPlayers,
      updatedMatch,
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
    final team1GamesWon = match.team1GamesWon;
    final team2GamesWon = match.team2GamesWon;
    final team1PointsFor = match.team1PointsFor;
    final team2PointsFor = match.team2PointsFor;

    return players.map((player) {
      // Check if player was in winning team
      if (winningTeam.any((p) => p.id == player.id)) {
        final gamesWonDelta =
            winnerId == 'team1' ? team1GamesWon : team2GamesWon;
        final gamesLostDelta =
            winnerId == 'team1' ? team2GamesWon : team1GamesWon;
        final pointsForDelta =
            winnerId == 'team1' ? team1PointsFor : team2PointsFor;
        final pointsAgainstDelta =
            winnerId == 'team1' ? team2PointsFor : team1PointsFor;

        return player.copyWith(
          wins: player.wins - 1,
          points: player.points - tournament.winnerPoints,
          gamesWon: player.gamesWon - gamesWonDelta,
          gamesLost: player.gamesLost - gamesLostDelta,
          pointsFor: player.pointsFor - pointsForDelta,
          pointsAgainst: player.pointsAgainst - pointsAgainstDelta,
        );
      }

      // Check if player was in losing team
      if (losingTeam.any((p) => p.id == player.id)) {
        final gamesWonDelta =
            winnerId == 'team1' ? team2GamesWon : team1GamesWon;
        final gamesLostDelta =
            winnerId == 'team1' ? team1GamesWon : team2GamesWon;
        final pointsForDelta =
            winnerId == 'team1' ? team2PointsFor : team1PointsFor;
        final pointsAgainstDelta =
            winnerId == 'team1' ? team1PointsFor : team2PointsFor;

        return player.copyWith(
          losses: player.losses - 1,
          points: player.points - tournament.loserPoints,
          gamesWon: player.gamesWon - gamesWonDelta,
          gamesLost: player.gamesLost - gamesLostDelta,
          pointsFor: player.pointsFor - pointsForDelta,
          pointsAgainst: player.pointsAgainst - pointsAgainstDelta,
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
    final team1GamesWon = match.team1GamesWon;
    final team2GamesWon = match.team2GamesWon;
    final team1PointsFor = match.team1PointsFor;
    final team2PointsFor = match.team2PointsFor;

    return players.map((player) {
      // Check if player is in winning team
      if (winningTeam.any((p) => p.id == player.id)) {
        final gamesWonDelta =
            winnerId == 'team1' ? team1GamesWon : team2GamesWon;
        final gamesLostDelta =
            winnerId == 'team1' ? team2GamesWon : team1GamesWon;
        final pointsForDelta =
            winnerId == 'team1' ? team1PointsFor : team2PointsFor;
        final pointsAgainstDelta =
            winnerId == 'team1' ? team2PointsFor : team1PointsFor;

        return player.copyWith(
          wins: player.wins + 1,
          points: player.points + tournament.winnerPoints,
          gamesWon: player.gamesWon + gamesWonDelta,
          gamesLost: player.gamesLost + gamesLostDelta,
          pointsFor: player.pointsFor + pointsForDelta,
          pointsAgainst: player.pointsAgainst + pointsAgainstDelta,
        );
      }

      // Check if player is in losing team
      if (losingTeam.any((p) => p.id == player.id)) {
        final gamesWonDelta =
            winnerId == 'team1' ? team2GamesWon : team1GamesWon;
        final gamesLostDelta =
            winnerId == 'team1' ? team1GamesWon : team2GamesWon;
        final pointsForDelta =
            winnerId == 'team1' ? team2PointsFor : team1PointsFor;
        final pointsAgainstDelta =
            winnerId == 'team1' ? team1PointsFor : team2PointsFor;

        return player.copyWith(
          losses: player.losses + 1,
          points: player.points + tournament.loserPoints,
          gamesWon: player.gamesWon + gamesWonDelta,
          gamesLost: player.gamesLost + gamesLostDelta,
          pointsFor: player.pointsFor + pointsForDelta,
          pointsAgainst: player.pointsAgainst + pointsAgainstDelta,
        );
      }

      return player;
    }).toList();
  }

  void _validateGameScores(List<GameScore> scores) {
    if (scores.length < 2 || scores.length > 3) {
      throw TournamentException(
        'Badminton matches must be played as best of three games',
      );
    }

    int team1Wins = 0;
    int team2Wins = 0;

    for (int i = 0; i < scores.length; i++) {
      final score = scores[i];
      final team1 = score.team1Score;
      final team2 = score.team2Score;

      if (team1 < 0 || team2 < 0) {
        throw TournamentException('Scores cannot be negative');
      }

      if (team1 == team2) {
        throw TournamentException('A game cannot end in a tie');
      }

      final winnerScore = team1 > team2 ? team1 : team2;
      final loserScore = team1 > team2 ? team2 : team1;

      if (winnerScore > 30) {
        throw TournamentException('Scores cannot exceed 30 points in badminton');
      }

      if (winnerScore < 21) {
        throw TournamentException('Winner must reach at least 21 points');
      }

      if (winnerScore == 30) {
        if (loserScore != 29) {
          throw TournamentException(
            'Reaching 30 points is only possible at 29-29 (final score 30-29)',
          );
        }
      } else if (winnerScore - loserScore < 2) {
        throw TournamentException(
          'Games must be won by at least two points (unless 30-29)',
        );
      }

      if (team1 > team2) {
        team1Wins++;
      } else {
        team2Wins++;
      }

      final isLastGame = i == scores.length - 1;
      if (!isLastGame && (team1Wins == 2 || team2Wins == 2)) {
        throw TournamentException(
          'No additional games allowed after a team wins two games',
        );
      }
    }

    if (team1Wins == team2Wins) {
      throw TournamentException('Match must have a decisive winner');
    }

    if (team1Wins > 2 || team2Wins > 2) {
      throw TournamentException('A team cannot win more than two games');
    }

    if (team1Wins < 2 && team2Wins < 2) {
      throw TournamentException('Winner must win two games in badminton');
    }
  }

  String _determineWinnerFromScores(List<GameScore> scores) {
    final team1Wins = scores
        .where((score) => score.team1Score > score.team2Score)
        .length;
    final team2Wins = scores.length - team1Wins;
    return team1Wins > team2Wins ? 'team1' : 'team2';
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
          (p) => p.copyWith(
            wins: 0,
            losses: 0,
            points: 0,
            gamesWon: 0,
            gamesLost: 0,
            pointsFor: 0,
            pointsAgainst: 0,
          ),
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

      // Tie-breaker: better point differential (average margin)
      final differentialCompare =
          b.pointDifferential.compareTo(a.pointDifferential);
      if (differentialCompare != 0) return differentialCompare;

      // Next: more points scored on average per match
      final averagePointsCompare =
          b.averagePointsFor.compareTo(a.averagePointsFor);
      if (averagePointsCompare != 0) return averagePointsCompare;

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

  /// Swap two players between teams in a match
  /// This allows manual rebalancing of teams before the match is played
  Tournament swapMatchPlayers({
    required Tournament tournament,
    required String roundId,
    required String matchId,
    required String player1Id,
    required String player2Id,
  }) {
    // Find the round
    final roundIndex = tournament.rounds.indexWhere((r) => r.id == roundId);
    if (roundIndex == -1) {
      throw TournamentException('Round not found');
    }

    final round = tournament.rounds[roundIndex];

    // Find the match
    final matchIndex = round.matches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) {
      throw TournamentException('Match not found');
    }

    final match = round.matches[matchIndex];

    // Check if match is already completed
    if (match.isCompleted) {
      throw TournamentException(
        'Cannot rearrange players in a completed match',
      );
    }

    // Find which teams the players are on
    final player1InTeam1 = match.team1.any((p) => p.id == player1Id);
    final player1InTeam2 = match.team2.any((p) => p.id == player1Id);
    final player2InTeam1 = match.team1.any((p) => p.id == player2Id);
    final player2InTeam2 = match.team2.any((p) => p.id == player2Id);

    // Validate players exist in the match
    if (!player1InTeam1 && !player1InTeam2) {
      throw TournamentException('Player 1 not found in this match');
    }
    if (!player2InTeam1 && !player2InTeam2) {
      throw TournamentException('Player 2 not found in this match');
    }

    // Players must be on different teams
    if ((player1InTeam1 && player2InTeam1) ||
        (player1InTeam2 && player2InTeam2)) {
      throw TournamentException('Players must be on different teams to swap');
    }

    // Get the actual player objects
    final player1 = tournament.players.firstWhere((p) => p.id == player1Id);
    final player2 = tournament.players.firstWhere((p) => p.id == player2Id);

    // Create new teams with swapped players
    List<Player> newTeam1 = List.from(match.team1);
    List<Player> newTeam2 = List.from(match.team2);

    if (player1InTeam1) {
      // Player 1 is in team1, player 2 is in team2
      final index1 = newTeam1.indexWhere((p) => p.id == player1Id);
      final index2 = newTeam2.indexWhere((p) => p.id == player2Id);
      newTeam1[index1] = player2;
      newTeam2[index2] = player1;
    } else {
      // Player 1 is in team2, player 2 is in team1
      final index1 = newTeam2.indexWhere((p) => p.id == player1Id);
      final index2 = newTeam1.indexWhere((p) => p.id == player2Id);
      newTeam2[index1] = player2;
      newTeam1[index2] = player1;
    }

    // Create updated match
    final updatedMatch = match.copyWith(team1: newTeam1, team2: newTeam2);

    // Update matches list
    final updatedMatches = List<Match>.from(round.matches);
    updatedMatches[matchIndex] = updatedMatch;

    // Update round
    final updatedRound = round.copyWith(matches: updatedMatches);

    // Update rounds list
    final updatedRounds = List<Round>.from(tournament.rounds);
    updatedRounds[roundIndex] = updatedRound;

    return tournament.copyWith(rounds: updatedRounds);
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
