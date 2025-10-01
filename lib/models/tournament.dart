import 'player.dart';
import 'round.dart';

/// Tournament mode enum
enum TournamentMode {
  singles, // 1v1 matches
  doubles; // 2v2 matches

  String get displayName {
    switch (this) {
      case TournamentMode.singles:
        return 'Singles (1v1)';
      case TournamentMode.doubles:
        return 'Doubles (2v2)';
    }
  }

  int get playersPerTeam {
    switch (this) {
      case TournamentMode.singles:
        return 1;
      case TournamentMode.doubles:
        return 2;
    }
  }
}

/// Tournament status enum
enum TournamentStatus {
  setup, // Adding players, not started
  active, // Tournament in progress
  completed; // All matches finished

  String get displayName {
    switch (this) {
      case TournamentStatus.setup:
        return 'Setup';
      case TournamentStatus.active:
        return 'Active';
      case TournamentStatus.completed:
        return 'Completed';
    }
  }
}

/// Tournament model representing the entire tournament
class Tournament {
  final String id;
  final String name;
  final TournamentMode mode;
  final TournamentStatus status;
  final List<Player> players;
  final List<Round> rounds;
  final int winnerPoints;
  final int loserPoints;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Tournament({
    required this.id,
    required this.name,
    required this.mode,
    this.status = TournamentStatus.setup,
    this.players = const [],
    this.rounds = const [],
    this.winnerPoints = 2,
    this.loserPoints = 1,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a Tournament from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: TournamentMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => TournamentMode.doubles,
      ),
      status: TournamentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TournamentStatus.setup,
      ),
      players:
          (json['players'] as List?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      rounds:
          (json['rounds'] as List?)
              ?.map((r) => Round.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Tournament to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.name,
      'status': status.name,
      'players': players.map((p) => p.toJson()).toList(),
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get minimum number of players required
  int get minPlayers {
    switch (mode) {
      case TournamentMode.singles:
        return 2; // At least 2 players for singles
      case TournamentMode.doubles:
        return 4; // At least 4 players for doubles
    }
  }

  /// Check if tournament can start
  bool get canStart =>
      players.length >= minPlayers && status == TournamentStatus.setup;

  /// Check if tournament is in progress
  bool get isActive => status == TournamentStatus.active;

  /// Check if tournament is completed
  bool get isCompleted => status == TournamentStatus.completed;

  /// Get current round number
  int get currentRound => rounds.length;

  /// Create a copy with modified fields
  Tournament copyWith({
    String? id,
    String? name,
    TournamentMode? mode,
    TournamentStatus? status,
    List<Player>? players,
    List<Round>? rounds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tournament && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Tournament{id: $id, name: $name, mode: ${mode.name}, status: ${status.name}, players: ${players.length}, rounds: ${rounds.length}}';
  }
}
