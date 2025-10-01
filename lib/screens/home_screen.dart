import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.file_upload),
                      title: Text('Export'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'backup',
                    child: ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Create Backup'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Reset'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Players',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_tennis_outlined),
                selectedIcon: Icon(Icons.sports_tennis),
                label: 'Rounds',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Rankings',
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
      case 'export':
        _showExportDialog(context, provider);
        break;
      case 'backup':
        await _createBackup(context, provider);
        break;
      case 'reset':
        await _showResetConfirmation(context, provider);
        break;
      case 'delete':
        await _showDeleteConfirmation(context, provider);
        break;
    }
  }

  void _showExportDialog(BuildContext context, TournamentProvider provider) {
    final json = provider.exportTournament();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Tournament'),
        content: SingleChildScrollView(child: SelectableText(json)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    try {
      final backupKey = await provider.createBackup();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup created: $backupKey')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating backup: $e')));
      }
    }
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Tournament'),
        content: const Text(
          'This will reset all rounds and scores. Players will be kept. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.resetTournament();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament reset successfully')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    TournamentProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: const Text(
          'This will permanently delete the tournament and all data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteTournament();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tournament deleted')));
      }
    }
  }
}
