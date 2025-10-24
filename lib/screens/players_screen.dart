import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';

/// Players screen showing all tournament participants
class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final tournament = provider.tournament;
        if (tournament == null) {
          return Center(child: Text(l10n.noTournament));
        }

        final players = tournament.players;

        if (players.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No players yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            final pointDiff = player.pointDifferential;
            final diffText = pointDiff > 0 ? '+$pointDiff' : '$pointDiff';
            final averagePoints =
                player.averagePointsFor.toStringAsFixed(1);

            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text('${l10n.matches}: ${player.totalMatches}'),
                        Text('${l10n.wins}: ${player.wins}'),
                        Text('${l10n.losses}: ${player.losses}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${l10n.games}: ${player.gamesWon}-${player.gamesLost}',
                        ),
                        Text('${l10n.pointsDiff}: $diffText'),
                        Text('${l10n.avgPoints}: $averagePoints'),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${player.points}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.points,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (player.totalMatches > 0)
                      Text(
                        '${l10n.winRate}: ${(player.winRate * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
