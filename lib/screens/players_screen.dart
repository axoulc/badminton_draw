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
            final averagePoints = player.averagePointsFor.toStringAsFixed(1);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${index + 1}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: player.isEnabled
                                  ? null
                                  : TextDecoration.lineThrough,
                              color: player.isEnabled
                                  ? null
                                  : Theme.of(context).disabledColor,
                            ),
                          ),
                          if (!player.isEnabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                'Disabled',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(
                                '${l10n.matches}: ${player.totalMatches}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${l10n.wins}: ${player.wins}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${l10n.losses}: ${player.losses}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(
                                '${l10n.games}: ${player.gamesWon}-${player.gamesLost}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${l10n.pointsDiff}: $diffText',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${l10n.avgPoints}: $averagePoints',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${player.points}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          player.isEnabled ? Icons.check_circle : Icons.cancel,
                          color: player.isEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                        ),
                        onPressed: () async {
                          try {
                            await provider.togglePlayerEnabled(player.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        tooltip: player.isEnabled
                            ? 'Disable player'
                            : 'Enable player',
                      ),
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
