/// Player model representing a tournament participant
class Player {
  final String id;
  final String name;
  final int wins;
  final int losses;
  final int points;
  final int gamesWon;
  final int gamesLost;
  final int pointsFor;
  final int pointsAgainst;
  final bool isEnabled;

  Player({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.pointsFor = 0,
    this.pointsAgainst = 0,
    this.isEnabled = true,
  });

  /// Create a Player from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      gamesLost: json['gamesLost'] as int? ?? 0,
      pointsFor: json['pointsFor'] as int? ?? 0,
      pointsAgainst: json['pointsAgainst'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  /// Convert Player to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wins': wins,
      'losses': losses,
      'points': points,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'pointsFor': pointsFor,
      'pointsAgainst': pointsAgainst,
      'isEnabled': isEnabled,
    };
  }

  /// Calculate total matches played
  int get totalMatches => wins + losses;

  /// Calculate win rate (0.0 to 1.0)
  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;

  /// Total games played across matches
  int get totalGames => gamesWon + gamesLost;

  /// Average points scored per match
  double get averagePointsFor =>
      totalMatches > 0 ? pointsFor / totalMatches : 0.0;

  /// Average points conceded per match
  double get averagePointsAgainst =>
      totalMatches > 0 ? pointsAgainst / totalMatches : 0.0;

  /// Points differential across all matches
  int get pointDifferential => pointsFor - pointsAgainst;

  /// Create a copy with modified fields
  Player copyWith({
    String? id,
    String? name,
    int? wins,
    int? losses,
    int? points,
    int? gamesWon,
    int? gamesLost,
    int? pointsFor,
    int? pointsAgainst,
    bool? isEnabled,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      points: points ?? this.points,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      pointsFor: pointsFor ?? this.pointsFor,
      pointsAgainst: pointsAgainst ?? this.pointsAgainst,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player{id: $id, name: $name, wins: $wins, losses: $losses, points: $points, gamesWon: $gamesWon, gamesLost: $gamesLost, pointsFor: $pointsFor, pointsAgainst: $pointsAgainst, isEnabled: $isEnabled}';
  }
}
