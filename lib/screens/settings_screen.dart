import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';

/// Settings screen for tournament configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _winnerPointsController;
  late TextEditingController _loserPointsController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final tournament = provider.tournament;

    _winnerPointsController = TextEditingController(
      text: tournament?.winnerPoints.toString() ?? '2',
    );
    _loserPointsController = TextEditingController(
      text: tournament?.loserPoints.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _winnerPointsController.dispose();
    _loserPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<TournamentProvider>(
        builder: (context, provider, child) {
          final tournament = provider.tournament;
          if (tournament == null) {
            return const Center(child: Text('No tournament available'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Scoring Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sports_score,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scoring System',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Configure how many points winners and losers receive',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Winner Points
                      TextField(
                        controller: _winnerPointsController,
                        decoration: const InputDecoration(
                          labelText: 'Winner Points',
                          helperText: 'Points awarded to the winning team',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.emoji_events),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Loser Points
                      TextField(
                        controller: _loserPointsController,
                        decoration: const InputDecoration(
                          labelText: 'Loser Points',
                          helperText:
                              'Points awarded to the losing team (participation)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.groups),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Current Settings Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Current: Winner ${tournament.winnerPoints} pts, Loser ${tournament.loserPoints} pts',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Save Button
                      FilledButton.icon(
                        onPressed: () => _saveSettings(context, provider),
                        icon: const Icon(Icons.save),
                        label: const Text('Save Settings'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tournament Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sports_tennis,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tournament Info',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Name', value: tournament.name),
                      _InfoRow(
                        label: 'Mode',
                        value: tournament.mode.displayName,
                      ),
                      _InfoRow(
                        label: 'Status',
                        value: tournament.status.displayName,
                      ),
                      _InfoRow(
                        label: 'Players',
                        value: '${tournament.players.length}',
                      ),
                      _InfoRow(
                        label: 'Rounds',
                        value: '${tournament.rounds.length}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveSettings(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final winnerPoints = int.tryParse(_winnerPointsController.text);
    final loserPoints = int.tryParse(_loserPointsController.text);

    if (winnerPoints == null || loserPoints == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    if (winnerPoints < 0 || loserPoints < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points cannot be negative')),
      );
      return;
    }

    try {
      await provider.updateScoringSettings(winnerPoints, loserPoints);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

/// Info row widget for displaying key-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
