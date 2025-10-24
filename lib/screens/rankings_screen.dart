import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';

/// Rankings screen showing player leaderboard
class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final tournament = provider.tournament;
        if (tournament == null) {
          return Center(child: Text(l10n.noTournament));
        }

        final rankings = provider.getRankings();

        if (rankings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No rankings yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rankings.length,
          itemBuilder: (context, index) {
            final player = rankings[index];
            final rank = index + 1;
            final diff = player.pointDifferential;
            final diffText = diff > 0 ? '+$diff' : '$diff';
            final winRatePercent =
                '${(player.winRate * 100).toStringAsFixed(0)}%';
            final averagePoints =
                player.averagePointsFor.toStringAsFixed(1);

            // Medal colors for top 3
            Color? medalColor;
            IconData? medalIcon;
            if (rank == 1) {
              medalColor = Colors.amber;
              medalIcon = Icons.emoji_events;
            } else if (rank == 2) {
              medalColor = Colors.grey;
              medalIcon = Icons.emoji_events;
            } else if (rank == 3) {
              medalColor = Colors.brown;
              medalIcon = Icons.emoji_events;
            }

            return Card(
              elevation: rank <= 3 ? 4 : 1,
              child: ListTile(
                leading: medalIcon != null
                    ? Icon(medalIcon, color: medalColor, size: 32)
                    : CircleAvatar(child: Text('$rank')),
                title: Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        label: l10n.wins,
                        value: '${player.wins}',
                        color: Colors.green,
                      ),
                      _StatChip(
                        label: l10n.losses,
                        value: '${player.losses}',
                        color: Colors.red,
                      ),
                      _StatChip(
                        label: l10n.winRate,
                        value: winRatePercent,
                        color: Colors.blue,
                      ),
                      _StatChip(
                        label: l10n.games,
                        value: '${player.gamesWon}-${player.gamesLost}',
                        color: Colors.orange,
                      ),
                      _StatChip(
                        label: l10n.pointsDiff,
                        value: diffText,
                        color: Colors.purple,
                      ),
                      _StatChip(
                        label: l10n.avgPoints,
                        value: averagePoints,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${player.points}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      l10n.points,
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

/// Small stat chip widget
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
