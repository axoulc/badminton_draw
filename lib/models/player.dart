/// Player model representing a tournament participant
class Player {
  final String id;
  final String name;
  final int wins;
  final int losses;
  final int points;

  Player({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
  });

  /// Create a Player from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
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
    };
  }

  /// Calculate total matches played
  int get totalMatches => wins + losses;

  /// Calculate win rate (0.0 to 1.0)
  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;

  /// Create a copy with modified fields
  Player copyWith({
    String? id,
    String? name,
    int? wins,
    int? losses,
    int? points,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      points: points ?? this.points,
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
    return 'Player{id: $id, name: $name, wins: $wins, losses: $losses, points: $points}';
  }
}
