import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';
import '../models/match.dart';

/// Rounds screen showing all matches organized by rounds
class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final tournament = provider.tournament;
        if (tournament == null) {
          return Center(child: Text(l10n.noTournament));
        }

        return Column(
          children: [
            // Generate round button
            if (provider.canGenerateRound)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => _generateRound(context, provider),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.generateRound),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

            // Rounds list
            Expanded(
              child: tournament.rounds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_tennis,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rounds yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generate a round to start',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tournament.rounds.length,
                      itemBuilder: (context, index) {
                        final round = tournament.rounds[index];
                        final isCompleted = round.isCompleted;

                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              child: Text('R${round.number}'),
                            ),
                            title: Text('${l10n.round} ${round.number}'),
                            subtitle: LinearProgressIndicator(
                              value: round.completionRate,
                              backgroundColor: Colors.grey.shade300,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCompleted)
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: l10n.regenerateRound,
                                    onPressed: () => _showRegenerateDialog(
                                      context,
                                      provider,
                                      round.id,
                                    ),
                                  ),
                                Text(
                                  '${round.completedCount}/${round.matches.length}',
                                ),
                              ],
                            ),
                            children: round.matches.map((match) {
                              return _MatchTile(
                                match: match,
                                roundId: round.id,
                                onResultRecorded: () {
                                  // Refresh handled by provider
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateRound(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await provider.generateRound();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.round} ${l10n.success}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  Future<void> _showRegenerateDialog(
    BuildContext context,
    TournamentProvider provider,
    String roundId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.regenerateRound),
        content: Text(l10n.regenerateRoundConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.regenerateRound(roundId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.roundRegenerated)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        }
      }
    }
  }
}

/// Match tile widget for displaying and scoring matches
class _MatchTile extends StatelessWidget {
  final Match match;
  final String roundId;
  final VoidCallback onResultRecorded;

  const _MatchTile({
    required this.match,
    required this.roundId,
    required this.onResultRecorded,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = match.isCompleted;

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: _TeamSection(
              team: match.team1,
              isWinner: match.team1Won,
              isCompleted: isCompleted,
              onTap: () => _recordResult(context, 'team1'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(l10n.vs, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: _TeamSection(
              team: match.team2,
              isWinner: match.team2Won,
              isCompleted: isCompleted,
              onTap: () => _recordResult(context, 'team2'),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.rearrangePlayers,
              onPressed: () => _showRearrangeDialog(context),
            ),
          if (isCompleted)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editResult,
              onPressed: () => _showEditResultDialog(context),
            ),
        ],
      ),
    );
  }

  Future<void> _recordResult(BuildContext context, String winnerId) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.recordMatchResult(
        roundId: roundId,
        matchId: match.id,
        winnerId: winnerId,
      );

      onResultRecorded();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.resultRecorded)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  void _showEditResultDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editMatchResult),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.selectWinner),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                match.team1Won ? Icons.check_circle : Icons.circle_outlined,
                color: match.team1Won ? Colors.green : null,
              ),
              title: Text(
                match.getTeamName(match.team1),
                style: TextStyle(
                  fontWeight: match.team1Won
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _recordResult(context, 'team1');
              },
            ),
            ListTile(
              leading: Icon(
                match.team2Won ? Icons.check_circle : Icons.circle_outlined,
                color: match.team2Won ? Colors.green : null,
              ),
              title: Text(
                match.getTeamName(match.team2),
                style: TextStyle(
                  fontWeight: match.team2Won
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _recordResult(context, 'team2');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showRearrangeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? selectedPlayer1;
    String? selectedPlayer2;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.rearrangePlayers),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.rearrangePlayersDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                // Team 1
                Text(
                  '${l10n.team} 1',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...match.team1.map((player) {
                  final isSelected =
                      selectedPlayer1 == player.id ||
                      selectedPlayer2 == player.id;
                  return ListTile(
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.blue : null,
                    ),
                    title: Text(player.name),
                    onTap: () {
                      setState(() {
                        if (selectedPlayer1 == null) {
                          selectedPlayer1 = player.id;
                        } else if (selectedPlayer1 == player.id) {
                          selectedPlayer1 = null;
                        } else if (selectedPlayer2 == null) {
                          selectedPlayer2 = player.id;
                        } else {
                          selectedPlayer2 = player.id;
                        }
                      });
                    },
                  );
                }),
                const Divider(),
                // Team 2
                Text(
                  '${l10n.team} 2',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...match.team2.map((player) {
                  final isSelected =
                      selectedPlayer1 == player.id ||
                      selectedPlayer2 == player.id;
                  return ListTile(
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.blue : null,
                    ),
                    title: Text(player.name),
                    onTap: () {
                      setState(() {
                        if (selectedPlayer1 == null) {
                          selectedPlayer1 = player.id;
                        } else if (selectedPlayer1 == player.id) {
                          selectedPlayer1 = null;
                        } else if (selectedPlayer2 == null) {
                          selectedPlayer2 = player.id;
                        } else {
                          selectedPlayer2 = player.id;
                        }
                      });
                    },
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: selectedPlayer1 != null && selectedPlayer2 != null
                    ? () async {
                        Navigator.pop(context);
                        await _swapPlayers(
                          dialogContext,
                          selectedPlayer1!,
                          selectedPlayer2!,
                        );
                      }
                    : null,
                child: Text(l10n.swapPlayers),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _swapPlayers(
    BuildContext context,
    String player1Id,
    String player2Id,
  ) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.swapMatchPlayers(
        roundId: roundId,
        matchId: match.id,
        player1Id: player1Id,
        player2Id: player2Id,
      );

      onResultRecorded(); // Refresh the UI

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.playersRearranged)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }
}

/// Team section widget
class _TeamSection extends StatelessWidget {
  final List team;
  final bool isWinner;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _TeamSection({
    required this.team,
    required this.isWinner,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCompleted && isWinner ? Colors.green.withOpacity(0.2) : null,
          border: Border.all(
            color: isCompleted && isWinner
                ? Colors.green
                : Colors.grey.shade300,
            width: isCompleted && isWinner ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: team.map((player) {
            return Text(
              player.name,
              style: TextStyle(
                fontWeight: isCompleted && isWinner
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            );
          }).toList(),
        ),
      ),
    );
  }
}
