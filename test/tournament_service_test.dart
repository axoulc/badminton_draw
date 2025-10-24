import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_tournament/models/match.dart';
import 'package:badminton_tournament/models/player.dart';
import 'package:badminton_tournament/models/round.dart';
import 'package:badminton_tournament/models/tournament.dart';
import 'package:badminton_tournament/services/tournament_service.dart';

void main() {
  group('TournamentService.recordMatchResult', () {
    late TournamentService service;
    late Player player1;
    late Player player2;
    late Match match;
    late Round round;
    late Tournament tournament;

    setUp(() {
      service = TournamentService();
      player1 = Player(id: 'p1', name: 'Player 1');
      player2 = Player(id: 'p2', name: 'Player 2');

      match = Match(
        id: 'm1',
        team1: [player1],
        team2: [player2],
      );

      round = Round(
        id: 'r1',
        number: 1,
        matches: [match],
      );

      tournament = Tournament(
        id: 't1',
        name: 'Test Tournament',
        mode: TournamentMode.singles,
        status: TournamentStatus.active,
        players: [player1, player2],
        rounds: [round],
        winnerPoints: 2,
        loserPoints: 1,
      );
    });

    test('records best-of-three score and updates player statistics', () {
      final updatedTournament = service.recordMatchResult(
        tournament,
        round.id,
        match.id,
        const [
          GameScore(team1Score: 21, team2Score: 15),
          GameScore(team1Score: 21, team2Score: 19),
        ],
      );

      final updatedMatch = updatedTournament.rounds.first.matches.first;
      expect(updatedMatch.winnerId, equals('team1'));
      expect(updatedMatch.gameScores.length, 2);

      final updatedPlayer1 =
          updatedTournament.players.firstWhere((p) => p.id == player1.id);
      final updatedPlayer2 =
          updatedTournament.players.firstWhere((p) => p.id == player2.id);

      expect(updatedPlayer1.wins, 1);
      expect(updatedPlayer1.gamesWon, 2);
      expect(updatedPlayer1.gamesLost, 0);
      expect(updatedPlayer1.pointsFor, 42);
      expect(updatedPlayer1.pointsAgainst, 34);

      expect(updatedPlayer2.losses, 1);
      expect(updatedPlayer2.gamesWon, 0);
      expect(updatedPlayer2.gamesLost, 2);
      expect(updatedPlayer2.pointsFor, 34);
      expect(updatedPlayer2.pointsAgainst, 42);
    });

    test('replaces previous score when match is edited', () {
      final firstResult = service.recordMatchResult(
        tournament,
        round.id,
        match.id,
        const [
          GameScore(team1Score: 21, team2Score: 14),
          GameScore(team1Score: 21, team2Score: 12),
        ],
      );

      final updatedTournament = service.recordMatchResult(
        firstResult,
        round.id,
        match.id,
        const [
          GameScore(team1Score: 18, team2Score: 21),
          GameScore(team1Score: 17, team2Score: 21),
        ],
      );

      final updatedMatch = updatedTournament.rounds.first.matches.first;
      expect(updatedMatch.winnerId, equals('team2'));
      expect(updatedMatch.team2GamesWon, 2);

      final updatedPlayer1 =
          updatedTournament.players.firstWhere((p) => p.id == player1.id);
      final updatedPlayer2 =
          updatedTournament.players.firstWhere((p) => p.id == player2.id);

      expect(updatedPlayer1.wins, 0);
      expect(updatedPlayer1.losses, 1);
      expect(updatedPlayer1.gamesWon, 0);
      expect(updatedPlayer1.gamesLost, 2);
      expect(updatedPlayer1.pointsFor, 35);
      expect(updatedPlayer1.pointsAgainst, 42);

      expect(updatedPlayer2.wins, 1);
      expect(updatedPlayer2.losses, 0);
      expect(updatedPlayer2.gamesWon, 2);
      expect(updatedPlayer2.gamesLost, 0);
      expect(updatedPlayer2.pointsFor, 42);
      expect(updatedPlayer2.pointsAgainst, 35);
    });

    test('throws when scores violate badminton rules', () {
      expect(
        () => service.recordMatchResult(
          tournament,
          round.id,
          match.id,
          const [
            GameScore(team1Score: 21, team2Score: 20), // not a 2-point lead
            GameScore(team1Score: 21, team2Score: 10),
          ],
        ),
        throwsA(isA<TournamentException>()),
      );
    });
  });
}
