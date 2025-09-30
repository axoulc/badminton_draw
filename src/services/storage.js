// StorageService implementation with localStorage JSON persistence
import { Tournament } from '../models/tournament.js';

export class StorageService {
    constructor() {
        this.storageKey = 'badminton_tournament';
        this.backupPrefix = 'badminton_tournament_backup_';
    }

    /**
     * Persist complete tournament state to localStorage
     * @param {Tournament} tournament - Tournament object to save
     * @throws {Error} If localStorage quota exceeded or serialization fails
     */
    saveTournament(tournament) {
        if (!tournament || !(tournament instanceof Tournament)) {
            throw new Error('Invalid tournament object provided');
        }

        try {
            const tournamentData = tournament.toJSON();
            const jsonString = JSON.stringify(tournamentData, null, 2);
            
            // Check if we have enough space (rough estimate)
            if (jsonString.length > 4 * 1024 * 1024) { // 4MB limit check
                console.warn('Tournament data is very large, may exceed localStorage limits');
            }

            localStorage.setItem(this.storageKey, jsonString);
            
            // Also save a timestamp for tracking
            localStorage.setItem(this.storageKey + '_timestamp', new Date().toISOString());
            
        } catch (error) {
            if (error.name === 'QuotaExceededError') {
                throw new Error('Not enough storage space to save tournament data');
            } else {
                throw new Error(`Failed to save tournament: ${error.message}`);
            }
        }
    }

    /**
     * Load tournament state from localStorage
     * @returns {Tournament|null} Tournament object or null if not found
     * @throws {Error} If data is corrupted or deserialization fails
     */
    loadTournament() {
        try {
            const jsonString = localStorage.getItem(this.storageKey);
            
            if (!jsonString) {
                return null; // No saved tournament
            }

            const tournamentData = JSON.parse(jsonString);
            
            // Validate basic structure
            if (!this.validateTournamentData(tournamentData)) {
                throw new Error('Saved tournament data structure is invalid');
            }

            return Tournament.fromJSON(tournamentData);
            
        } catch (error) {
            if (error instanceof SyntaxError) {
                throw new Error('Saved tournament data is corrupted (invalid JSON)');
            } else {
                throw new Error(`Failed to load tournament: ${error.message}`);
            }
        }
    }

    /**
     * Remove tournament data from localStorage
     */
    clearTournament() {
        try {
            localStorage.removeItem(this.storageKey);
            localStorage.removeItem(this.storageKey + '_timestamp');
        } catch (error) {
            console.warn('Error clearing tournament data:', error.message);
        }
    }

    /**
     * Check if tournament data exists in localStorage
     * @returns {boolean} True if tournament data exists
     */
    hasSavedTournament() {
        return localStorage.getItem(this.storageKey) !== null;
    }

    /**
     * Get last save timestamp
     * @returns {Date|null} Last save date or null if no data
     */
    getLastSaveTime() {
        const timestamp = localStorage.getItem(this.storageKey + '_timestamp');
        return timestamp ? new Date(timestamp) : null;
    }

    /**
     * Export tournament as JSON string for backup
     * @param {Tournament} tournament - Tournament to export
     * @returns {string} Formatted JSON string
     * @throws {Error} If no tournament provided
     */
    exportTournament(tournament) {
        if (!tournament) {
            // Try to load from localStorage if no tournament provided
            tournament = this.loadTournament();
            if (!tournament) {
                throw new Error('No tournament data to export');
            }
        }

        try {
            const exportData = {
                ...tournament.toJSON(),
                exportedAt: new Date().toISOString(),
                version: '1.0.0'
            };

            return JSON.stringify(exportData, null, 2);
        } catch (error) {
            throw new Error(`Failed to export tournament: ${error.message}`);
        }
    }

    /**
     * Import tournament from JSON backup
     * @param {string} jsonData - JSON string of tournament data
     * @returns {Tournament} Restored tournament object
     * @throws {Error} If JSON is invalid or data structure is wrong
     */
    importTournament(jsonData) {
        if (!jsonData || typeof jsonData !== 'string') {
            throw new Error('Invalid JSON data provided');
        }

        try {
            const importData = JSON.parse(jsonData);
            
            // Handle different export formats
            let tournamentData = importData;
            if (importData.exportedAt && importData.version) {
                // This is an export format, extract the tournament data
                delete importData.exportedAt;
                delete importData.version;
                tournamentData = importData;
            }

            // Validate the data structure
            if (!this.validateTournamentData(tournamentData)) {
                throw new Error('Imported data structure is invalid');
            }

            return Tournament.fromJSON(tournamentData);
            
        } catch (error) {
            if (error instanceof SyntaxError) {
                throw new Error('Invalid JSON format in import data');
            } else {
                throw new Error(`Failed to import tournament: ${error.message}`);
            }
        }
    }

    /**
     * Create a backup of current tournament data
     * @param {string} backupName - Optional backup name
     * @returns {string} Backup key used
     */
    createBackup(backupName = null) {
        const tournament = this.loadTournament();
        if (!tournament) {
            throw new Error('No tournament data to backup');
        }

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const backupKey = this.backupPrefix + (backupName || timestamp);
        
        try {
            const tournamentData = tournament.toJSON();
            const backupData = {
                ...tournamentData,
                backedUpAt: new Date().toISOString(),
                originalName: tournament.name
            };

            localStorage.setItem(backupKey, JSON.stringify(backupData));
            return backupKey;
        } catch (error) {
            throw new Error(`Failed to create backup: ${error.message}`);
        }
    }

    /**
     * List all available backups
     * @returns {Array} Array of backup info objects
     */
    listBackups() {
        const backups = [];
        
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key && key.startsWith(this.backupPrefix)) {
                try {
                    const data = JSON.parse(localStorage.getItem(key));
                    backups.push({
                        key: key,
                        name: data.originalName || 'Unknown',
                        backedUpAt: new Date(data.backedUpAt),
                        players: data.players ? data.players.length : 0,
                        rounds: data.rounds ? data.rounds.length : 0
                    });
                } catch (error) {
                    console.warn(`Corrupted backup found: ${key}`);
                }
            }
        }

        return backups.sort((a, b) => b.backedUpAt - a.backedUpAt);
    }

    /**
     * Restore tournament from backup
     * @param {string} backupKey - Backup key to restore from
     * @returns {Tournament} Restored tournament
     */
    restoreFromBackup(backupKey) {
        const backupData = localStorage.getItem(backupKey);
        if (!backupData) {
            throw new Error('Backup not found');
        }

        try {
            const data = JSON.parse(backupData);
            // Remove backup-specific fields
            delete data.backedUpAt;
            delete data.originalName;
            
            if (!this.validateTournamentData(data)) {
                throw new Error('Backup data structure is invalid');
            }

            return Tournament.fromJSON(data);
        } catch (error) {
            throw new Error(`Failed to restore backup: ${error.message}`);
        }
    }

    /**
     * Delete a backup
     * @param {string} backupKey - Backup key to delete
     * @returns {boolean} True if deleted successfully
     */
    deleteBackup(backupKey) {
        if (!backupKey.startsWith(this.backupPrefix)) {
            throw new Error('Invalid backup key');
        }

        try {
            localStorage.removeItem(backupKey);
            return true;
        } catch (error) {
            console.warn(`Failed to delete backup ${backupKey}:`, error.message);
            return false;
        }
    }

    /**
     * Validate tournament data structure
     * @param {any} data - Data to validate
     * @returns {boolean} True if valid tournament data
     */
    validateTournamentData(data) {
        if (!data || typeof data !== 'object') {
            return false;
        }

        // Check required fields
        const requiredFields = ['id', 'name', 'players', 'rounds', 'status'];
        for (const field of requiredFields) {
            if (!(field in data)) {
                return false;
            }
        }

        // Validate data types
        if (typeof data.id !== 'string' || 
            typeof data.name !== 'string' ||
            !Array.isArray(data.players) ||
            !Array.isArray(data.rounds) ||
            typeof data.status !== 'string') {
            return false;
        }

        // Validate status values
        const validStatuses = ['setup', 'active', 'completed'];
        if (!validStatuses.includes(data.status)) {
            return false;
        }

        // Validate players structure
        for (const player of data.players) {
            if (!player.id || typeof player.name !== 'string' || typeof player.score !== 'number') {
                return false;
            }
        }

        // Validate rounds structure
        for (const round of data.rounds) {
            if (!round.id || typeof round.number !== 'number' || !Array.isArray(round.matches)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Get storage usage statistics
     * @returns {object} Storage statistics
     */
    getStorageStats() {
        try {
            const tournamentData = localStorage.getItem(this.storageKey);
            const tournamentSize = tournamentData ? new Blob([tournamentData]).size : 0;
            
            let backupSize = 0;
            let backupCount = 0;
            
            for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                if (key && key.startsWith(this.backupPrefix)) {
                    const data = localStorage.getItem(key);
                    if (data) {
                        backupSize += new Blob([data]).size;
                        backupCount++;
                    }
                }
            }

            return {
                tournamentSize: tournamentSize,
                backupSize: backupSize,
                totalSize: tournamentSize + backupSize,
                backupCount: backupCount,
                hasTournament: !!tournamentData,
                lastSave: this.getLastSaveTime()
            };
        } catch (error) {
            return {
                error: error.message,
                tournamentSize: 0,
                backupSize: 0,
                totalSize: 0,
                backupCount: 0,
                hasTournament: false,
                lastSave: null
            };
        }
    }

    /**
     * Auto-save functionality (call this periodically or on changes)
     * @param {Tournament} tournament - Tournament to auto-save
     * @param {number} debounceMs - Debounce delay in milliseconds
     */
    autoSave(tournament, debounceMs = 1000) {
        // Clear any existing auto-save timeout
        if (this.autoSaveTimeout) {
            clearTimeout(this.autoSaveTimeout);
        }

        // Set new timeout for debounced save
        this.autoSaveTimeout = setTimeout(() => {
            try {
                this.saveTournament(tournament);
                console.log('Tournament auto-saved at', new Date().toLocaleTimeString());
            } catch (error) {
                console.error('Auto-save failed:', error.message);
            }
        }, debounceMs);
    }
}