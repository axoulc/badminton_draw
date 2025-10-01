import 'dart:math';
import '../models/player.dart';
import '../models/match.dart';
import '../models/round.dart';
import '../models/tournament.dart';

/// Pairing service for generating matches
class PairingService {
  final Random _random = Random();

  /// Generate a new round of matches
  Round generateRound({
    required Tournament tournament,
    required List<Player> players,
  }) {
    if (players.isEmpty) {
      throw PairingException('No players available for pairing');
    }

    final minPlayers = tournament.mode.playersPerTeam * 2;
    if (players.length < minPlayers) {
      throw PairingException(
        'Not enough players. Need at least $minPlayers for ${tournament.mode.displayName}',
      );
    }

    List<Match> matches;

    if (tournament.mode == TournamentMode.singles) {
      matches = _generateSinglesMatches(players, tournament);
    } else {
      matches = _generateDoublesMatches(players, tournament);
    }

    final roundNumber = tournament.rounds.length + 1;
    return Round(
      id: 'round_${DateTime.now().millisecondsSinceEpoch}',
      number: roundNumber,
      matches: matches,
    );
  }

  /// Generate singles matches (1v1)
  List<Match> _generateSinglesMatches(
    List<Player> players,
    Tournament tournament,
  ) {
    // Shuffle players using Fisher-Yates algorithm
    final shuffled = List<Player>.from(players);
    _fisherYatesShuffle(shuffled);

    final matches = <Match>[];

    // Pair consecutive players
    for (int i = 0; i < shuffled.length - 1; i += 2) {
      final match = Match(
        id: 'match_${DateTime.now().millisecondsSinceEpoch}_$i',
        team1: [shuffled[i]],
        team2: [shuffled[i + 1]],
      );
      matches.add(match);
    }

    return matches;
  }

  /// Generate doubles matches (2v2)
  List<Match> _generateDoublesMatches(
    List<Player> players,
    Tournament tournament,
  ) {
    // Shuffle players
    final shuffled = List<Player>.from(players);
    _fisherYatesShuffle(shuffled);

    final matches = <Match>[];

    // Create teams of 2 and pair them
    for (int i = 0; i < shuffled.length - 3; i += 4) {
      final match = Match(
        id: 'match_${DateTime.now().millisecondsSinceEpoch}_$i',
        team1: [shuffled[i], shuffled[i + 1]],
        team2: [shuffled[i + 2], shuffled[i + 3]],
      );
      matches.add(match);
    }

    return matches;
  }

  /// Fisher-Yates shuffle algorithm
  void _fisherYatesShuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Check if a player can be paired in this round
  bool canPairPlayer(Player player, Round round, List<Round> previousRounds) {
    // Check if player is already in this round
    for (final match in round.matches) {
      if (match.allPlayerIds.contains(player.id)) {
        return false;
      }
    }

    // Additional constraints could be added here:
    // - Avoid recent opponents
    // - Balance number of games played
    // - etc.

    return true;
  }

  /// Get players who haven't played in the current round
  List<Player> getAvailablePlayers(
    List<Player> allPlayers,
    Round currentRound,
  ) {
    final playingIds = currentRound.matches
        .expand((m) => m.allPlayerIds)
        .toSet();

    return allPlayers.where((p) => !playingIds.contains(p.id)).toList();
  }

  /// Calculate optimal number of matches for a round
  int calculateOptimalMatches(int playerCount, TournamentMode mode) {
    final playersPerMatch = mode.playersPerTeam * 2;
    return playerCount ~/ playersPerMatch;
  }

  /// Validate pairing configuration
  bool validatePairing(Match match, TournamentMode mode) {
    // Check team sizes
    if (match.team1.length != mode.playersPerTeam ||
        match.team2.length != mode.playersPerTeam) {
      return false;
    }

    // Check for duplicate players
    final allIds = match.allPlayerIds;
    if (allIds.length != allIds.toSet().length) {
      return false;
    }

    return true;
  }

  /// Get pairing statistics
  PairingStats getPairingStats(Tournament tournament) {
    final totalMatches = tournament.rounds.expand((r) => r.matches).length;

    final completedMatches = tournament.rounds
        .expand((r) => r.matches)
        .where((m) => m.isCompleted)
        .length;

    final playersParticipating = tournament.players
        .where((p) => p.totalMatches > 0)
        .length;

    return PairingStats(
      totalMatches: totalMatches,
      completedMatches: completedMatches,
      pendingMatches: totalMatches - completedMatches,
      activePlayers: playersParticipating,
      totalPlayers: tournament.players.length,
    );
  }
}

/// Pairing statistics
class PairingStats {
  final int totalMatches;
  final int completedMatches;
  final int pendingMatches;
  final int activePlayers;
  final int totalPlayers;

  PairingStats({
    required this.totalMatches,
    required this.completedMatches,
    required this.pendingMatches,
    required this.activePlayers,
    required this.totalPlayers,
  });

  double get completionRate =>
      totalMatches > 0 ? completedMatches / totalMatches : 0.0;

  double get playerParticipationRate =>
      totalPlayers > 0 ? activePlayers / totalPlayers : 0.0;
}

/// Pairing exception
class PairingException implements Exception {
  final String message;
  PairingException(this.message);

  @override
  String toString() => 'PairingException: $message';
}
