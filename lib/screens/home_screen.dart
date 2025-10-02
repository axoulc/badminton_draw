import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/tournament_provider.dart';
import '../models/tournament.dart';
import 'setup_screen.dart';
import 'players_screen.dart';
import 'rounds_screen.dart';
import 'rankings_screen.dart';
import 'settings_screen.dart';

/// Main home screen with navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        // Show setup screen if no tournament exists or tournament is in setup
        if (!provider.hasTournament ||
            provider.tournament!.status == TournamentStatus.setup) {
          return SetupScreen();
        }

        // Show tournament tabs for active/completed tournaments
        final screens = [
          const PlayersScreen(),
          const RoundsScreen(),
          const RankingsScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.tournament!.name),
            actions: [
              // Tournament mode chip
              Chip(
                avatar: Icon(
                  provider.tournament!.mode == TournamentMode.singles
                      ? Icons.person
                      : Icons.people,
                  size: 18,
                ),
                label: Text(provider.tournament!.mode.displayName),
              ),
              const SizedBox(width: 8),

              // Status chip
              Chip(
                label: Text(provider.tournament!.status.displayName),
                backgroundColor: _getStatusColor(provider.tournament!.status),
              ),
              const SizedBox(width: 8),

              // Menu
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(l10n.settings),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export_backup',
                    child: ListTile(
                      leading: const Icon(Icons.download),
                      title: Text(l10n.exportBackup),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import_backup',
                    child: ListTile(
                      leading: const Icon(Icons.upload),
                      title: Text(l10n.importBackup),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(l10n.reset),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.people_outline),
                selectedIcon: const Icon(Icons.people),
                label: l10n.players,
              ),
              NavigationDestination(
                icon: const Icon(Icons.sports_tennis_outlined),
                selectedIcon: const Icon(Icons.sports_tennis),
                label: l10n.rounds,
              ),
              NavigationDestination(
                icon: const Icon(Icons.emoji_events_outlined),
                selectedIcon: const Icon(Icons.emoji_events),
                label: l10n.rankings,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.setup:
        return Colors.grey;
      case TournamentStatus.active:
        return Colors.green;
      case TournamentStatus.completed:
        return Colors.blue;
    }
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    final provider = Provider.of<TournamentProvider>(context, listen: false);

    switch (action) {
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'export_backup':
        _exportBackupFile(context, provider);
        break;
      case 'import_backup':
        _importBackupFile(context, provider);
        break;
      case 'reset':
        await _showResetConfirmation(context, provider);
        break;
      case 'delete':
        await _showDeleteConfirmation(context, provider);
        break;
    }
  }

  void _exportBackupFile(BuildContext context, TournamentProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    try {
      final jsonString = provider.exportBackupJson();
      final tournament = provider.tournament!;
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = '${tournament.name}_backup_$timestamp.json';

      // Create a blob and download it
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.backupExported}: $filename')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorExportingBackup}: $e')),
        );
      }
    }
  }

  void _importBackupFile(BuildContext context, TournamentProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final uploadInput = html.FileUploadInputElement()..accept = '.json';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsText(file);

        reader.onLoadEnd.listen((event) async {
          try {
            final jsonString = reader.result as String;
            await provider.importBackupJson(jsonString);

            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.importBackupSuccess)));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.errorImportingBackup}: $e')),
              );
            }
          }
        });
      }
    });
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetTournament),
        content: Text(l10n.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.resetTournament();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tournamentResetSuccess)));
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTournament),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteTournament();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tournamentDeletedSuccess)));
      }
    }
  }
}
