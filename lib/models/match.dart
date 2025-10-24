import 'player.dart';

/// Game score for a single badminton game (set)
class GameScore {
  final int team1Score;
  final int team2Score;

  const GameScore({
    required this.team1Score,
    required this.team2Score,
  });

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      team1Score: json['team1Score'] as int,
      team2Score: json['team2Score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team1Score': team1Score,
      'team2Score': team2Score,
    };
  }
}

/// Match model representing a game between teams
class Match {
  final String id;
  final List<Player> team1;
  final List<Player> team2;
  final String? winnerId; // null if not played yet
  final List<GameScore> gameScores;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    this.winnerId,
    List<GameScore>? gameScores,
    DateTime? createdAt,
  })  : gameScores = gameScores ?? const [],
        createdAt = createdAt ?? DateTime.now();

  /// Create a Match from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      team1: (json['team1'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      team2: (json['team2'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      winnerId: json['winnerId'] as String?,
      gameScores: (json['gameScores'] as List?)
              ?.map(
                (game) => GameScore.fromJson(game as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Match to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1': team1.map((p) => p.toJson()).toList(),
      'team2': team2.map((p) => p.toJson()).toList(),
      'winnerId': winnerId,
      'gameScores': gameScores.map((game) => game.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if match has been played
  bool get isCompleted => winnerId != null;

  /// Get team 1 player IDs
  List<String> get team1Ids => team1.map((p) => p.id).toList();

  /// Get team 2 player IDs
  List<String> get team2Ids => team2.map((p) => p.id).toList();

  /// Get all player IDs in this match
  List<String> get allPlayerIds => [...team1Ids, ...team2Ids];

  /// Check if team 1 won
  bool get team1Won => winnerId == 'team1';

  /// Check if team 2 won
  bool get team2Won => winnerId == 'team2';

  /// Total games won by team 1
  int get team1GamesWon =>
      gameScores.where((score) => score.team1Score > score.team2Score).length;

  /// Total games won by team 2
  int get team2GamesWon =>
      gameScores.where((score) => score.team2Score > score.team1Score).length;

  /// Total rallies (points) won by team 1 across all games
  int get team1PointsFor =>
      gameScores.fold<int>(0, (sum, score) => sum + score.team1Score);

  /// Total rallies (points) won by team 2 across all games
  int get team2PointsFor =>
      gameScores.fold<int>(0, (sum, score) => sum + score.team2Score);

  /// Get formatted team name
  String getTeamName(List<Player> team) {
    return team.map((p) => p.name).join(' / ');
  }

  /// Create a copy with modified fields
  Match copyWith({
    String? id,
    List<Player>? team1,
    List<Player>? team2,
    String? winnerId,
    List<GameScore>? gameScores,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      winnerId: winnerId ?? this.winnerId,
      gameScores: gameScores ?? this.gameScores,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Match{id: $id, team1: ${getTeamName(team1)}, team2: ${getTeamName(team2)}, winner: $winnerId}';
  }
}
