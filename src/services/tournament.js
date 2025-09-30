// TournamentService implementation with player/round/match management
import { Tournament } from '../models/tournament.js';
import { Round } from '../models/round.js';
import { PairingService } from './pairing.js';
import { StorageService } from './storage.js';

export class TournamentService {
    constructor() {
        this.tournament = null;
        this.pairingService = new PairingService();
        this.storageService = new StorageService();
        this.autoSaveEnabled = true;
    }

    // Tournament lifecycle management
    
    /**
     * Create a new tournament
     * @param {string} name - Tournament name
     * @returns {Tournament} New tournament instance
     */
    createTournament(name = 'Badminton Tournament') {
        this.tournament = new Tournament(name);
        this.autoSave();
        return this.tournament;
    }

    /**
     * Load existing tournament from storage
     * @returns {Tournament|null} Loaded tournament or null if none exists
     */
    loadTournament() {
        try {
            this.tournament = this.storageService.loadTournament();
            return this.tournament;
        } catch (error) {
            console.error('Failed to load tournament:', error.message);
            return null;
        }
    }

    /**
     * Get current tournament
     * @returns {Tournament|null} Current tournament instance
     */
    getCurrentTournament() {
        return this.tournament;
    }

    /**
     * Save current tournament to storage
     */
    saveTournament() {
        if (this.tournament) {
            this.storageService.saveTournament(this.tournament);
        }
    }

    /**
     * Reset tournament (clear scores, keep players)
     */
    resetTournament() {
        if (!this.tournament) {
            throw new Error('No tournament to reset');
        }
        
        this.tournament.reset();
        this.autoSave();
    }

    // Player Management

    /**
     * Add new player to tournament
     * @param {string} name - Player name
     * @returns {Player} Added player
     */
    addPlayer(name) {
        if (!this.tournament) {
            this.createTournament();
        }

        const player = this.tournament.addPlayer(name);
        this.autoSave();
        return player;
    }

    /**
     * Remove player from tournament
     * @param {string} playerId - Player ID to remove
     * @returns {boolean} True if removed successfully
     */
    removePlayer(playerId) {
        if (!this.tournament) {
            return false;
        }

        const result = this.tournament.removePlayer(playerId);
        if (result) {
            this.autoSave();
        }
        return result;
    }

    /**
     * Update player name
     * @param {string} playerId - Player ID
     * @param {string} newName - New player name
     * @returns {Player} Updated player
     */
    updatePlayer(playerId, newName) {
        if (!this.tournament) {
            throw new Error('No tournament available');
        }

        const player = this.tournament.updatePlayer(playerId, newName);
        this.autoSave();
        return player;
    }

    /**
     * Get all tournament players
     * @returns {Player[]} Array of players sorted by score
     */
    getPlayers() {
        if (!this.tournament) {
            return [];
        }
        return this.tournament.getPlayers();
    }

    /**
     * Get player by ID
     * @param {string} playerId - Player ID
     * @returns {Player|null} Player or null if not found
     */
    getPlayer(playerId) {
        if (!this.tournament) {
            return null;
        }
        return this.tournament.getPlayer(playerId);
    }

    // Tournament state management

    /**
     * Start tournament (transition from setup to active)
     */
    startTournament() {
        if (!this.tournament) {
            throw new Error('No tournament to start');
        }

        this.tournament.start();
        this.autoSave();
    }

    /**
     * Complete tournament
     */
    completeTournament() {
        if (!this.tournament) {
            throw new Error('No tournament to complete');
        }

        this.tournament.complete();
        this.autoSave();
    }

    /**
     * Get tournament status
     * @returns {string} Tournament status
     */
    getTournamentStatus() {
        if (!this.tournament) {
            return 'none';
        }
        return this.tournament.status;
    }

    /**
     * Check if tournament can be started
     * @returns {boolean} True if tournament can start
     */
    canStartTournament() {
        if (!this.tournament) {
            return false;
        }
        return this.tournament.canStartTournament();
    }

    // Round Management

    /**
     * Generate new round with random pairings
     * @returns {Round} Generated round
     */
    generateRound() {
        if (!this.tournament) {
            throw new Error('No tournament available');
        }

        if (!this.tournament.canAddRound()) {
            throw new Error('Cannot add round: tournament not active or previous round not completed');
        }

        const activePlayers = this.tournament.getActivePlayers();
        const lastRound = this.tournament.getLastRound();
        
        // Generate pairings using PairingService
        const matches = this.pairingService.generatePairings(activePlayers, lastRound);
        
        // Create new round
        const roundNumber = this.tournament.rounds.length + 1;
        const round = new Round(roundNumber, matches);
        
        // Add round to tournament
        this.tournament.addRound(round);
        this.autoSave();
        
        return round;
    }

    /**
     * Get current active round
     * @returns {Round|null} Current round or null
     */
    getCurrentRound() {
        if (!this.tournament) {
            return null;
        }
        return this.tournament.getCurrentRound();
    }

    /**
     * Get all tournament rounds
     * @returns {Round[]} Array of rounds
     */
    getRounds() {
        if (!this.tournament) {
            return [];
        }
        return this.tournament.getRounds();
    }

    /**
     * Get round by number
     * @param {number} roundNumber - Round number
     * @returns {Round|null} Round or null if not found
     */
    getRound(roundNumber) {
        if (!this.tournament) {
            return null;
        }
        return this.tournament.rounds.find(r => r.number === roundNumber);
    }

    // Match Management

    /**
     * Record match result and update player scores
     * @param {string} matchId - Match ID
     * @param {number} winningPair - 1 or 2 indicating winning pair
     */
    recordMatchResult(matchId, winningPair) {
        if (!this.tournament) {
            throw new Error('No tournament available');
        }

        this.tournament.recordMatchResult(matchId, winningPair);
        this.autoSave();
    }

    /**
     * Get specific match by ID
     * @param {string} matchId - Match ID
     * @returns {Match|null} Match or null if not found
     */
    getMatch(matchId) {
        if (!this.tournament) {
            return null;
        }

        for (const round of this.tournament.rounds) {
            const match = round.getMatchById(matchId);
            if (match) {
                return match;
            }
        }
        return null;
    }

    /**
     * Get all matches from current round
     * @returns {Match[]} Array of matches
     */
    getCurrentRoundMatches() {
        const currentRound = this.getCurrentRound();
        return currentRound ? currentRound.matches : [];
    }

    /**
     * Get pending matches from current round
     * @returns {Match[]} Array of pending matches
     */
    getPendingMatches() {
        const currentRound = this.getCurrentRound();
        return currentRound ? currentRound.getPendingMatches() : [];
    }

    /**
     * Get completed matches from current round
     * @returns {Match[]} Array of completed matches
     */
    getCompletedMatches() {
        const currentRound = this.getCurrentRound();
        return currentRound ? currentRound.getCompletedMatches() : [];
    }

    // Rankings and Statistics

    /**
     * Get current player rankings
     * @returns {Player[]} Players sorted by score descending
     */
    getRankings() {
        if (!this.tournament) {
            return [];
        }
        return this.tournament.getRankings();
    }

    /**
     * Get tournament statistics
     * @returns {object} Tournament statistics
     */
    getTournamentStats() {
        if (!this.tournament) {
            return {
                totalPlayers: 0,
                totalRounds: 0,
                completedRounds: 0,
                totalMatches: 0,
                completedMatches: 0
            };
        }
        return this.tournament.getTournamentStats();
    }

    /**
     * Get pairing statistics (fairness analysis)
     * @returns {object} Pairing statistics
     */
    getPairingStats() {
        if (!this.tournament) {
            return null;
        }
        return this.pairingService.getPairingStats(this.tournament.rounds, this.tournament.players);
    }

    // Settings Management

    /**
     * Update tournament settings
     * @param {object} newSettings - New settings to apply
     */
    updateSettings(newSettings) {
        if (!this.tournament) {
            throw new Error('No tournament available');
        }

        this.tournament.updateSettings(newSettings);
        this.autoSave();
    }

    /**
     * Get current tournament settings
     * @returns {object} Tournament settings
     */
    getSettings() {
        if (!this.tournament) {
            return { winnerPoints: 2, loserPoints: 1 };
        }
        return this.tournament.settings;
    }

    // Data Management

    /**
     * Export tournament data
     * @returns {string} JSON string of tournament data
     */
    exportTournament() {
        return this.storageService.exportTournament(this.tournament);
    }

    /**
     * Import tournament data
     * @param {string} jsonData - JSON string of tournament data
     * @returns {Tournament} Imported tournament
     */
    importTournament(jsonData) {
        this.tournament = this.storageService.importTournament(jsonData);
        this.saveTournament();
        return this.tournament;
    }

    /**
     * Create backup of current tournament
     * @param {string} backupName - Optional backup name
     * @returns {string} Backup key
     */
    createBackup(backupName) {
        return this.storageService.createBackup(backupName);
    }

    /**
     * List available backups
     * @returns {Array} Array of backup info
     */
    listBackups() {
        return this.storageService.listBackups();
    }

    /**
     * Restore tournament from backup
     * @param {string} backupKey - Backup key to restore
     * @returns {Tournament} Restored tournament
     */
    restoreFromBackup(backupKey) {
        this.tournament = this.storageService.restoreFromBackup(backupKey);
        this.saveTournament();
        return this.tournament;
    }

    // Utility methods

    /**
     * Enable or disable auto-save
     * @param {boolean} enabled - Whether to enable auto-save
     */
    setAutoSave(enabled) {
        this.autoSaveEnabled = enabled;
    }

    /**
     * Auto-save current tournament (if enabled)
     */
    autoSave() {
        if (this.autoSaveEnabled && this.tournament) {
            this.storageService.autoSave(this.tournament);
        }
    }

    /**
     * Check if there's a saved tournament
     * @returns {boolean} True if saved tournament exists
     */
    hasSavedTournament() {
        return this.storageService.hasSavedTournament();
    }

    /**
     * Get storage statistics
     * @returns {object} Storage usage stats
     */
    getStorageStats() {
        return this.storageService.getStorageStats();
    }

    /**
     * Validate current tournament state
     * @returns {object} Validation results
     */
    validateTournament() {
        if (!this.tournament) {
            return { valid: false, errors: ['No tournament loaded'] };
        }

        const errors = [];
        const warnings = [];

        // Check player count
        if (this.tournament.players.length < 4) {
            errors.push('Tournament needs at least 4 players');
        }

        // Check for duplicate names
        const names = this.tournament.players.map(p => p.name.toLowerCase());
        const uniqueNames = new Set(names);
        if (names.length !== uniqueNames.size) {
            errors.push('Duplicate player names found');
        }

        // Check round consistency
        for (const round of this.tournament.rounds) {
            try {
                round.validateMatches();
            } catch (error) {
                errors.push(`Round ${round.number}: ${error.message}`);
            }
        }

        // Check for reasonable score distribution
        if (this.tournament.players.length > 0) {
            const scores = this.tournament.players.map(p => p.score);
            const maxScore = Math.max(...scores);
            const minScore = Math.min(...scores);
            
            if (maxScore - minScore > this.tournament.rounds.length * 2 * 2) {
                warnings.push('Large score gap detected - check for scoring errors');
            }
        }

        return {
            valid: errors.length === 0,
            errors: errors,
            warnings: warnings
        };
    }
}