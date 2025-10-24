import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          SnackBar(
            content: Text('${l10n.round} ${l10n.success}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
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
    final scoreSummary = _formatScoreSummary(match, l10n);
    final scoreTooltip = isCompleted ? l10n.editScore : l10n.enterScore;

    return ListTile(
      onTap: () => _openScoreDialog(context),
      title: Row(
        children: [
          Expanded(
            child: _TeamSection(
              team: match.team1,
              isWinner: match.team1Won,
              isCompleted: isCompleted,
              onTap: () => _openScoreDialog(context),
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
              onTap: () => _openScoreDialog(context),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          scoreSummary ?? l10n.enterScorePrompt,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.sports_score),
            tooltip: scoreTooltip,
            onPressed: () => _openScoreDialog(context),
          ),
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.rearrangePlayers,
              onPressed: () => _showRearrangeDialog(context),
            ),
        ],
      ),
    );
  }

  Future<void> _openScoreDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => _ScoreEntryDialog(
        match: match,
        roundId: roundId,
      ),
    );

    if (success == true) {
      onResultRecorded();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scoreSaved)),
        );
      }
    }
  }

  String? _formatScoreSummary(Match match, AppLocalizations l10n) {
    if (match.gameScores.isEmpty) return null;
    final gamesSummary = '${match.team1GamesWon}-${match.team2GamesWon}';
    final gamesDetail = match.gameScores
        .map((score) => '${score.team1Score}-${score.team2Score}')
        .join(', ');
    return '${l10n.games}: $gamesSummary · $gamesDetail';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.playersRearranged),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _ScoreEntryDialog extends StatefulWidget {
  final Match match;
  final String roundId;

  const _ScoreEntryDialog({
    required this.match,
    required this.roundId,
  });

  @override
  State<_ScoreEntryDialog> createState() => _ScoreEntryDialogState();
}

class _ScoreEntryDialogState extends State<_ScoreEntryDialog> {
  final List<_GameRowData> _games = [];
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.match.gameScores.isNotEmpty) {
      for (final score in widget.match.gameScores) {
        _games.add(
          _GameRowData(
            team1Initial: score.team1Score,
            team2Initial: score.team2Score,
          ),
        );
      }
    } else {
      // Start with two empty games (minimum required)
      _games.add(_GameRowData());
      _games.add(_GameRowData());
    }
  }

  @override
  void dispose() {
    for (final game in _games) {
      game.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team1Label = widget.match.getTeamName(widget.match.team1);
    final team2Label = widget.match.getTeamName(widget.match.team2);

    return AlertDialog(
      title: Text(widget.match.isCompleted ? l10n.editScore : l10n.enterScore),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scoreEntryDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _games.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GameScoreRow(
                  index: index,
                  data: _games[index],
                  team1Label: team1Label,
                  team2Label: team2Label,
                  onRemove: _games.length > 2
                      ? () => setState(() {
                            _games.removeAt(index).dispose();
                          })
                      : null,
                ),
              ),
            ),
            if (_games.length < 3)
              TextButton.icon(
                onPressed: () => setState(() {
                  _games.add(_GameRowData());
                }),
                icon: const Icon(Icons.add),
                label: Text(l10n.addGame),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveScores,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _saveScores() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _error = null;
      _isSaving = true;
    });

    final scores = <GameScore>[];

    for (final game in _games) {
      final team1Text = game.team1Controller.text.trim();
      final team2Text = game.team2Controller.text.trim();

      final bothEmpty = team1Text.isEmpty && team2Text.isEmpty;
      if (bothEmpty) {
        continue;
      }

      if (team1Text.isEmpty || team2Text.isEmpty) {
        setState(() {
          _error = l10n.scoreValidationNumeric;
          _isSaving = false;
        });
        return;
      }

      final team1Score = int.tryParse(team1Text);
      final team2Score = int.tryParse(team2Text);

      if (team1Score == null || team2Score == null) {
        setState(() {
          _error = l10n.scoreValidationNumeric;
          _isSaving = false;
        });
        return;
      }

      scores.add(
        GameScore(team1Score: team1Score, team2Score: team2Score),
      );
    }

    if (scores.length < 2) {
      setState(() {
        _error = l10n.scoreValidationIncomplete;
        _isSaving = false;
      });
      return;
    }

    try {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      await provider.recordMatchResult(
        roundId: widget.roundId,
        matchId: widget.match.id,
        gameScores: scores,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        final message = e
            .toString()
            .replaceFirst('TournamentException: ', '')
            .trim();
        _error = message.isEmpty ? e.toString() : message;
        _isSaving = false;
      });
    }
  }
}

class _GameRowData {
  final TextEditingController team1Controller;
  final TextEditingController team2Controller;

  _GameRowData({
    int? team1Initial,
    int? team2Initial,
  })  : team1Controller = TextEditingController(
          text: team1Initial != null ? '$team1Initial' : '',
        ),
        team2Controller = TextEditingController(
          text: team2Initial != null ? '$team2Initial' : '',
        );

  void dispose() {
    team1Controller.dispose();
    team2Controller.dispose();
  }
}

class _GameScoreRow extends StatelessWidget {
  final int index;
  final _GameRowData data;
  final String team1Label;
  final String team2Label;
  final VoidCallback? onRemove;

  const _GameScoreRow({
    required this.index,
    required this.data,
    required this.team1Label,
    required this.team2Label,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            '${l10n.game} ${index + 1}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: TextField(
            controller: data.team1Controller,
            decoration: InputDecoration(
              labelText: team1Label,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: data.team2Controller,
            decoration: InputDecoration(
              labelText: team2Label,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: l10n.delete,
            onPressed: onRemove,
          ),
      ],
    );
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
