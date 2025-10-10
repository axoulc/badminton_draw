import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import '../services/file_service.dart';

/// Setup screen for creating and configuring tournaments
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _playerController = TextEditingController();
  TournamentMode _selectedMode = TournamentMode.doubles;

  @override
  void dispose() {
    _nameController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final hasTournament = provider.hasTournament;
        final tournament = provider.tournament;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.tournamentSetup)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasTournament) ...[
                    // Tournament creation section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.createNewTournament,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: l10n.tournamentName,
                                hintText: l10n.tournamentNameHint,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.sports_tennis),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.enterTournamentName;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SegmentedButton<TournamentMode>(
                              segments: [
                                ButtonSegment(
                                  value: TournamentMode.singles,
                                  label: Text(l10n.singles),
                                  icon: const Icon(Icons.person),
                                ),
                                ButtonSegment(
                                  value: TournamentMode.doubles,
                                  label: Text(l10n.doubles),
                                  icon: const Icon(Icons.people),
                                ),
                              ],
                              selected: {_selectedMode},
                              onSelectionChanged:
                                  (Set<TournamentMode> newSelection) {
                                    setState(() {
                                      _selectedMode = newSelection.first;
                                    });
                                  },
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _createTournament,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.createTournament),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Or restore from backup:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _importBackupFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(l10n.importBackup),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Tournament info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tournament.mode.displayName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Minimum ${tournament.minPlayers} players required',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Players section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Players (${tournament.players.length})',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Chip(
                                  label: Text(
                                    tournament.canStart ? 'Ready' : 'Add More',
                                  ),
                                  backgroundColor: tournament.canStart
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Add player form
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _playerController,
                                    decoration: InputDecoration(
                                      labelText: l10n.playerName,
                                      hintText: l10n.playerNameHint,
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.person_add),
                                    ),
                                    onFieldSubmitted: (_) => _addPlayer(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: _addPlayer,
                                  icon: const Icon(Icons.add),
                                  label: Text(l10n.add),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Import players button
                            OutlinedButton.icon(
                              onPressed: () => _showImportDialog(context),
                              icon: const Icon(Icons.file_upload),
                              label: Text(l10n.importPlayersJson),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Players list
                            if (tournament.players.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_add_disabled,
                                        size: 48,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No players yet',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tournament.players.length,
                                itemBuilder: (context, index) {
                                  final player = tournament.players[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(player.name),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _removePlayer(player.id),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Start tournament button
                    FilledButton.icon(
                      onPressed: tournament.canStart ? _startTournament : null,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.startTournament),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.createTournament(
        name: _nameController.text.trim(),
        mode: _selectedMode,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tournamentCreated)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  Future<void> _addPlayer() async {
    final name = _playerController.text.trim();
    if (name.isEmpty) return;

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.addPlayer(name);
      _playerController.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.playerAdded}: "$name"')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  Future<void> _removePlayer(String playerId) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.removePlayer(playerId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.playerRemoved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  Future<void> _startTournament() async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.startTournament();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tournamentStarted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Players'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste a JSON array of player names:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Example:\n["Alice", "Bob", "Charlie", "David"]',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: '["Player 1", "Player 2", ...]',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _importPlayers(textController.text);
            },
            icon: const Icon(Icons.upload),
            label: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importPlayers(String jsonText) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);

    try {
      // Parse JSON
      final dynamic decoded = jsonDecode(jsonText);

      if (decoded is! List) {
        throw Exception('Expected a JSON array');
      }

      final playerNames = decoded.map((e) => e.toString()).toList();

      if (playerNames.isEmpty) {
        throw Exception('No players found in the JSON');
      }

      // Import players
      await provider.importPlayers(playerNames);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported ${playerNames.length} players',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importBackupFile() async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      final jsonString = await FileService.pickJsonFile();

      if (jsonString != null) {
        await provider.importBackupJson(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.importBackupSuccess)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorImportingBackup}: $e')),
        );
      }
    }
  }
}
