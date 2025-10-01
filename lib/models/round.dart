import 'match.dart';

/// Round model representing a set of matches
class Round {
  final String id;
  final int number;
  final List<Match> matches;
  final DateTime createdAt;

  Round({
    required this.id,
    required this.number,
    required this.matches,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a Round from JSON
  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'] as String,
      number: json['number'] as int,
      matches: (json['matches'] as List)
          .map((m) => Match.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Round to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'matches': matches.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if all matches in round are completed
  bool get isCompleted => matches.every((m) => m.isCompleted);

  /// Get number of completed matches
  int get completedCount => matches.where((m) => m.isCompleted).length;

  /// Get completion percentage (0.0 to 1.0)
  double get completionRate =>
      matches.isEmpty ? 0.0 : completedCount / matches.length;

  /// Create a copy with modified fields
  Round copyWith({
    String? id,
    int? number,
    List<Match>? matches,
    DateTime? createdAt,
  }) {
    return Round(
      id: id ?? this.id,
      number: number ?? this.number,
      matches: matches ?? this.matches,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Round && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Round{number: $number, matches: ${matches.length}, completed: $completedCount}';
  }
}
