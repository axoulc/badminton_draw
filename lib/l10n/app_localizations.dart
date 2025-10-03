import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('fr')];

  // Common
  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get reset => _localizedValues[locale.languageCode]!['reset']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;

  // Navigation
  String get players => _localizedValues[locale.languageCode]!['players']!;
  String get rounds => _localizedValues[locale.languageCode]!['rounds']!;
  String get rankings => _localizedValues[locale.languageCode]!['rankings']!;

  // Menu
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get exportBackup =>
      _localizedValues[locale.languageCode]!['export_backup']!;
  String get importBackup =>
      _localizedValues[locale.languageCode]!['import_backup']!;

  // Tournament
  String get tournamentSetup =>
      _localizedValues[locale.languageCode]!['tournament_setup']!;
  String get createNewTournament =>
      _localizedValues[locale.languageCode]!['create_new_tournament']!;
  String get tournamentName =>
      _localizedValues[locale.languageCode]!['tournament_name']!;
  String get tournamentMode =>
      _localizedValues[locale.languageCode]!['tournament_mode']!;
  String get singles => _localizedValues[locale.languageCode]!['singles']!;
  String get doubles => _localizedValues[locale.languageCode]!['doubles']!;
  String get createTournament =>
      _localizedValues[locale.languageCode]!['create_tournament']!;
  String get startTournament =>
      _localizedValues[locale.languageCode]!['start_tournament']!;
  String get noTournament =>
      _localizedValues[locale.languageCode]!['no_tournament']!;
  String get tournamentNameHint =>
      _localizedValues[locale.languageCode]!['tournament_name_hint']!;
  String get enterTournamentName =>
      _localizedValues[locale.languageCode]!['enter_tournament_name']!;
  String get tournamentCreated =>
      _localizedValues[locale.languageCode]!['tournament_created']!;
  String get tournamentStarted =>
      _localizedValues[locale.languageCode]!['tournament_started']!;

  // Players
  String get addPlayer => _localizedValues[locale.languageCode]!['add_player']!;
  String get playerName =>
      _localizedValues[locale.languageCode]!['player_name']!;
  String get importPlayers =>
      _localizedValues[locale.languageCode]!['import_players']!;
  String get importPlayersJson =>
      _localizedValues[locale.languageCode]!['import_players_json']!;
  String get noPlayers => _localizedValues[locale.languageCode]!['no_players']!;
  String get minimumPlayers =>
      _localizedValues[locale.languageCode]!['minimum_players']!;
  String get playerNameHint =>
      _localizedValues[locale.languageCode]!['player_name_hint']!;
  String get playerAdded =>
      _localizedValues[locale.languageCode]!['player_added']!;
  String get playerRemoved =>
      _localizedValues[locale.languageCode]!['player_removed']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;

  // Rounds
  String get generateRound =>
      _localizedValues[locale.languageCode]!['generate_round']!;
  String get round => _localizedValues[locale.languageCode]!['round']!;
  String get noRounds => _localizedValues[locale.languageCode]!['no_rounds']!;
  String get editResult =>
      _localizedValues[locale.languageCode]!['edit_result']!;
  String get editMatchResult =>
      _localizedValues[locale.languageCode]!['edit_match_result']!;
  String get selectWinner =>
      _localizedValues[locale.languageCode]!['select_winner']!;
  String get resultRecorded =>
      _localizedValues[locale.languageCode]!['result_recorded']!;
  String get regenerateRound =>
      _localizedValues[locale.languageCode]!['regenerate_round']!;
  String get regenerateRoundConfirmation =>
      _localizedValues[locale.languageCode]!['regenerate_round_confirmation']!;
  String get roundRegenerated =>
      _localizedValues[locale.languageCode]!['round_regenerated']!;
  String get vs => _localizedValues[locale.languageCode]!['vs']!;
  String get rearrangePlayers =>
      _localizedValues[locale.languageCode]!['rearrange_players']!;
  String get rearrangePlayersDescription =>
      _localizedValues[locale.languageCode]!['rearrange_players_description']!;
  String get swapPlayers =>
      _localizedValues[locale.languageCode]!['swap_players']!;
  String get team => _localizedValues[locale.languageCode]!['team']!;
  String get playersRearranged =>
      _localizedValues[locale.languageCode]!['players_rearranged']!;

  // Rankings
  String get rank => _localizedValues[locale.languageCode]!['rank']!;
  String get points => _localizedValues[locale.languageCode]!['points']!;
  String get wins => _localizedValues[locale.languageCode]!['wins']!;
  String get losses => _localizedValues[locale.languageCode]!['losses']!;
  String get winRate => _localizedValues[locale.languageCode]!['win_rate']!;

  // Settings
  String get tournamentSettings =>
      _localizedValues[locale.languageCode]!['tournament_settings']!;
  String get scoringSettings =>
      _localizedValues[locale.languageCode]!['scoring_settings']!;
  String get winnerPoints =>
      _localizedValues[locale.languageCode]!['winner_points']!;
  String get loserPoints =>
      _localizedValues[locale.languageCode]!['loser_points']!;
  String get saveSettings =>
      _localizedValues[locale.languageCode]!['save_settings']!;
  String get settingsSaved =>
      _localizedValues[locale.languageCode]!['settings_saved']!;
  String get themeMode => _localizedValues[locale.languageCode]!['theme_mode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get light => _localizedValues[locale.languageCode]!['light']!;
  String get dark => _localizedValues[locale.languageCode]!['dark']!;
  String get system => _localizedValues[locale.languageCode]!['system']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get french => _localizedValues[locale.languageCode]!['french']!;
  String get appSettings =>
      _localizedValues[locale.languageCode]!['app_settings']!;
  String get scoringSystemDescription =>
      _localizedValues[locale.languageCode]!['scoring_system_description']!;
  String get winnerPointsHelp =>
      _localizedValues[locale.languageCode]!['winner_points_help']!;
  String get loserPointsHelp =>
      _localizedValues[locale.languageCode]!['loser_points_help']!;
  String get current => _localizedValues[locale.languageCode]!['current']!;
  String get winner => _localizedValues[locale.languageCode]!['winner']!;
  String get loser => _localizedValues[locale.languageCode]!['loser']!;

  // Backup
  String get exportBackupSuccess =>
      _localizedValues[locale.languageCode]!['export_backup_success']!;
  String get importBackupSuccess =>
      _localizedValues[locale.languageCode]!['import_backup_success']!;
  String get importBackupFile =>
      _localizedValues[locale.languageCode]!['import_backup_file']!;
  String get backupExported =>
      _localizedValues[locale.languageCode]!['backup_exported']!;
  String get errorExportingBackup =>
      _localizedValues[locale.languageCode]!['error_exporting_backup']!;
  String get errorImportingBackup =>
      _localizedValues[locale.languageCode]!['error_importing_backup']!;

  // Actions
  String get resetTournament =>
      _localizedValues[locale.languageCode]!['reset_tournament']!;
  String get deleteTournament =>
      _localizedValues[locale.languageCode]!['delete_tournament']!;
  String get resetConfirmation =>
      _localizedValues[locale.languageCode]!['reset_confirmation']!;
  String get deleteConfirmation =>
      _localizedValues[locale.languageCode]!['delete_confirmation']!;
  String get tournamentResetSuccess =>
      _localizedValues[locale.languageCode]!['tournament_reset_success']!;
  String get tournamentDeletedSuccess =>
      _localizedValues[locale.languageCode]!['tournament_deleted_success']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Badminton Tournament Manager',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'close': 'Close',
      'confirm': 'Confirm',
      'reset': 'Reset',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',

      // Navigation
      'players': 'Players',
      'rounds': 'Rounds',
      'rankings': 'Rankings',

      // Menu
      'settings': 'Settings',
      'export_backup': 'Export Backup',
      'import_backup': 'Import Backup',

      // Tournament
      'tournament_setup': 'Tournament Setup',
      'create_new_tournament': 'Create New Tournament',
      'tournament_name': 'Tournament Name',
      'tournament_mode': 'Tournament Mode',
      'singles': 'Singles (1v1)',
      'doubles': 'Doubles (2v2)',
      'create_tournament': 'Create Tournament',
      'start_tournament': 'Start Tournament',
      'no_tournament': 'No tournament',
      'tournament_name_hint': 'e.g., Summer Championship 2024',
      'enter_tournament_name': 'Please enter a tournament name',
      'tournament_created': 'Tournament created successfully',
      'tournament_started': 'Tournament started!',

      // Players
      'add_player': 'Add Player',
      'player_name': 'Player Name',
      'import_players': 'Import',
      'import_players_json': 'Import Players (JSON)',
      'no_players': 'No players yet',
      'minimum_players': 'Minimum players required',
      'player_name_hint': 'Enter player name',
      'player_added': 'Player added',
      'player_removed': 'Player removed',
      'add': 'Add',

      // Rounds
      'generate_round': 'Generate Round',
      'round': 'Round',
      'no_rounds': 'No rounds yet',
      'edit_result': 'Edit result',
      'edit_match_result': 'Edit Match Result',
      'select_winner': 'Select the winner:',
      'result_recorded': 'Result recorded',
      'regenerate_round': 'Regenerate Round',
      'regenerate_round_confirmation':
          'This will delete all current matches in this round and generate new random pairings. This action cannot be undone.',
      'round_regenerated': 'Round regenerated successfully',
      'vs': 'vs',
      'rearrange_players': 'Rearrange Players',
      'rearrange_players_description':
          'Tap on two players from different teams to swap them',
      'swap_players': 'Swap Players',
      'team': 'Team',
      'players_rearranged': 'Players rearranged successfully',

      // Rankings
      'rank': 'Rank',
      'points': 'Points',
      'wins': 'Wins',
      'losses': 'Losses',
      'win_rate': 'Win Rate',

      // Settings
      'tournament_settings': 'Tournament Settings',
      'scoring_settings': 'Scoring Settings',
      'winner_points': 'Winner Points',
      'loser_points': 'Loser Points',
      'save_settings': 'Save Settings',
      'settings_saved': 'Settings saved successfully!',
      'theme_mode': 'Theme Mode',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'english': 'English',
      'french': 'Français',
      'app_settings': 'App Settings',
      'scoring_system_description':
          'Configure how many points winners and losers receive',
      'winner_points_help': 'Points awarded to the winning team',
      'loser_points_help': 'Points awarded to the losing team (participation)',
      'current': 'Current',
      'winner': 'Winner',
      'loser': 'Loser',

      // Backup
      'export_backup_success': 'Backup exported',
      'import_backup_success': 'Backup imported successfully!',
      'import_backup_file': 'Import Backup',
      'backup_exported': 'Backup exported',
      'error_exporting_backup': 'Error exporting backup',
      'error_importing_backup': 'Error importing backup',

      // Actions
      'reset_tournament': 'Reset Tournament',
      'delete_tournament': 'Delete Tournament',
      'reset_confirmation':
          'This will reset all rounds and scores. Players will be kept. This action cannot be undone.',
      'delete_confirmation':
          'This will permanently delete the tournament and all data. This action cannot be undone.',
      'tournament_reset_success': 'Tournament reset successfully',
      'tournament_deleted_success': 'Tournament deleted',
    },
    'fr': {
      'app_title': 'Gestionnaire de Tournoi de Badminton',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'close': 'Fermer',
      'confirm': 'Confirmer',
      'reset': 'Réinitialiser',
      'yes': 'Oui',
      'no': 'Non',
      'error': 'Erreur',
      'success': 'Succès',

      // Navigation
      'players': 'Joueurs',
      'rounds': 'Manches',
      'rankings': 'Classement',

      // Menu
      'settings': 'Paramètres',
      'export_backup': 'Exporter Sauvegarde',
      'import_backup': 'Importer Sauvegarde',

      // Tournament
      'tournament_setup': 'Configuration du Tournoi',
      'create_new_tournament': 'Créer un Nouveau Tournoi',
      'tournament_name': 'Nom du Tournoi',
      'tournament_mode': 'Mode de Tournoi',
      'singles': 'Simple (1v1)',
      'doubles': 'Double (2v2)',
      'create_tournament': 'Créer le Tournoi',
      'start_tournament': 'Démarrer le Tournoi',
      'no_tournament': 'Aucun tournoi',
      'tournament_name_hint': 'ex : Championnat d\'été 2024',
      'enter_tournament_name': 'Veuillez entrer un nom de tournoi',
      'tournament_created': 'Tournoi créé avec succès',
      'tournament_started': 'Tournoi démarré !',

      // Players
      'add_player': 'Ajouter un Joueur',
      'player_name': 'Nom du Joueur',
      'import_players': 'Importer',
      'import_players_json': 'Importer des Joueurs (JSON)',
      'no_players': 'Aucun joueur pour le moment',
      'minimum_players': 'Nombre minimum de joueurs requis',
      'player_name_hint': 'Entrez le nom du joueur',
      'player_added': 'Joueur ajouté',
      'player_removed': 'Joueur supprimé',
      'add': 'Ajouter',

      // Rounds
      'generate_round': 'Générer une Manche',
      'round': 'Manche',
      'no_rounds': 'Aucune manche pour le moment',
      'edit_result': 'Modifier le résultat',
      'edit_match_result': 'Modifier le Résultat du Match',
      'select_winner': 'Sélectionnez le gagnant :',
      'result_recorded': 'Résultat enregistré',
      'regenerate_round': 'Régénérer la Manche',
      'regenerate_round_confirmation':
          'Ceci supprimera tous les matchs actuels de cette manche et générera de nouveaux appariements aléatoires. Cette action ne peut pas être annulée.',
      'round_regenerated': 'Manche régénérée avec succès',
      'vs': 'vs',
      'rearrange_players': 'Réorganiser les Joueurs',
      'rearrange_players_description':
          'Appuyez sur deux joueurs d\'équipes différentes pour les échanger',
      'swap_players': 'Échanger les Joueurs',
      'team': 'Équipe',
      'players_rearranged': 'Joueurs réorganisés avec succès',

      // Rankings
      'rank': 'Rang',
      'points': 'Points',
      'wins': 'Victoires',
      'losses': 'Défaites',
      'win_rate': 'Taux de Victoire',

      // Settings
      'tournament_settings': 'Paramètres du Tournoi',
      'scoring_settings': 'Paramètres de Score',
      'winner_points': 'Points Gagnant',
      'loser_points': 'Points Perdant',
      'save_settings': 'Enregistrer les Paramètres',
      'settings_saved': 'Paramètres enregistrés avec succès !',
      'theme_mode': 'Mode de Thème',
      'language': 'Langue',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'english': 'English',
      'french': 'Français',
      'app_settings': 'Paramètres de l\'Application',
      'scoring_system_description':
          'Configurer combien de points les gagnants et les perdants reçoivent',
      'winner_points_help': 'Points attribués à l\'équipe gagnante',
      'loser_points_help':
          'Points attribués à l\'équipe perdante (participation)',
      'current': 'Actuel',
      'winner': 'Gagnant',
      'loser': 'Perdant',

      // Backup
      'export_backup_success': 'Sauvegarde exportée',
      'import_backup_success': 'Sauvegarde importée avec succès !',
      'import_backup_file': 'Importer une Sauvegarde',
      'backup_exported': 'Sauvegarde exportée',
      'error_exporting_backup':
          'Erreur lors de l\'exportation de la sauvegarde',
      'error_importing_backup':
          'Erreur lors de l\'importation de la sauvegarde',

      // Actions
      'reset_tournament': 'Réinitialiser le Tournoi',
      'delete_tournament': 'Supprimer le Tournoi',
      'reset_confirmation':
          'Ceci réinitialisera toutes les manches et les scores. Les joueurs seront conservés. Cette action ne peut pas être annulée.',
      'delete_confirmation':
          'Ceci supprimera définitivement le tournoi et toutes les données. Cette action ne peut pas être annulée.',
      'tournament_reset_success': 'Tournoi réinitialisé avec succès',
      'tournament_deleted_success': 'Tournoi supprimé',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
