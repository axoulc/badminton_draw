import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Consumer<TournamentProvider>(
        builder: (context, provider, child) {
          final tournament = provider.tournament;
          if (tournament == null) {
            return Center(child: Text(l10n.noTournament));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // App Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.appSettings,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Theme Mode Selector
                      Text(
                        l10n.themeMode,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text(l10n.light),
                            icon: const Icon(Icons.light_mode),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text(l10n.dark),
                            icon: const Icon(Icons.dark_mode),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text(l10n.system),
                            icon: const Icon(Icons.brightness_auto),
                          ),
                        ],
                        selected: <ThemeMode>{provider.themeMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          provider.setThemeMode(newSelection.first);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Language Selector
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment<String>(
                            value: 'en',
                            label: Text(l10n.english),
                            icon: const Icon(Icons.language),
                          ),
                          ButtonSegment<String>(
                            value: 'fr',
                            label: Text(l10n.french),
                            icon: const Icon(Icons.language),
                          ),
                        ],
                        selected: <String>{provider.locale.languageCode},
                        onSelectionChanged: (Set<String> newSelection) {
                          provider.setLocale(Locale(newSelection.first));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                            l10n.scoringSettings,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.scoringSystemDescription,
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
                        decoration: InputDecoration(
                          labelText: l10n.winnerPoints,
                          helperText: l10n.winnerPointsHelp,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.emoji_events),
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
                        decoration: InputDecoration(
                          labelText: l10n.loserPoints,
                          helperText: l10n.loserPointsHelp,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.groups),
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
                              '${l10n.current}: ${l10n.winner} ${tournament.winnerPoints} ${l10n.points}, ${l10n.loser} ${tournament.loserPoints} ${l10n.points}',
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
