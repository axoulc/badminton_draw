import { Player } from './player.js';
import { Round } from './round.js';

// Tournament entity model with business rules
export class Tournament {
    constructor(name = 'Badminton Tournament') {
        this.id = this.generateId();
        this.name = name;
        this.players = [];
        this.rounds = [];
        this.currentRound = null;
        this.status = 'setup';
        this.createdAt = new Date();
        this.settings = {
            winnerPoints: 2,
            loserPoints: 1
        };
    }

    static fromJSON(data) {
        const tournament = new Tournament(data.name);
        tournament.id = data.id;
        tournament.players = (data.players || []).map(p => Player.fromJSON(p));
        tournament.rounds = (data.rounds || []).map(r => Round.fromJSON(r));
        tournament.currentRound = data.currentRound;
        tournament.status = data.status || 'setup';
        tournament.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
        tournament.settings = { ...tournament.settings, ...(data.settings || {}) };
        return tournament;
    }

    toJSON() {
        return {
            id: this.id,
            name: this.name,
            players: this.players.map(p => p.toJSON()),
            rounds: this.rounds.map(r => r.toJSON()),
            currentRound: this.currentRound,
            status: this.status,
            createdAt: this.createdAt.toISOString(),
            settings: this.settings
        };
    }

    generateId() {
        return 'tournament_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    // Tournament state transitions
    start() {
        if (this.status !== 'setup') {
            throw new Error('Tournament can only be started from setup state');
        }
        if (this.players.length < 4) {
            throw new Error('Tournament requires at least 4 players to start');
        }
        this.status = 'active';
    }

    complete() {
        if (this.status !== 'active') {
            throw new Error('Tournament can only be completed from active state');
        }
        this.status = 'completed';
    }

    reset() {
        // Reset tournament scores but keep players
        this.players.forEach(player => player.resetScore());
        this.rounds = [];
        this.currentRound = null;
        this.status = 'setup';
    }

    // Player management
    addPlayer(name) {
        if (this.status === 'active') {
            throw new Error('Cannot add players during active tournament');
        }

        // Check for duplicate names
        const existingPlayer = this.players.find(p => 
            p.name.toLowerCase() === name.toLowerCase()
        );
        if (existingPlayer) {
            throw new Error('Player name must be unique');
        }

        const player = new Player(name);
        this.players.push(player);
        return player;
    }

    removePlayer(playerId) {
        if (this.status === 'active') {
            throw new Error('Cannot remove players during active tournament');
        }

        const index = this.players.findIndex(p => p.id === playerId);
        if (index === -1) {
            return false;
        }

        this.players.splice(index, 1);
        return true;
    }

    updatePlayer(playerId, newName) {
        if (this.status === 'active') {
            throw new Error('Cannot update players during active tournament');
        }

        const player = this.getPlayer(playerId);
        if (!player) {
            throw new Error('Player not found');
        }

        // Check for duplicate names (excluding current player)
        const existingPlayer = this.players.find(p => 
            p.id !== playerId && p.name.toLowerCase() === newName.toLowerCase()
        );
        if (existingPlayer) {
            throw new Error('Player name must be unique');
        }

        player.updateName(newName);
        return player;
    }

    getPlayer(playerId) {
        return this.players.find(p => p.id === playerId);
    }

    getPlayers() {
        return [...this.players].sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
    }

    getActivePlayers() {
        return this.players.filter(p => p.isActive);
    }

    // Round management
    addRound(round) {
        this.rounds.push(round);
        this.currentRound = round.number;
    }

    getCurrentRound() {
        if (this.currentRound === null) {
            return null;
        }
        return this.rounds.find(r => r.number === this.currentRound);
    }

    getRounds() {
        return [...this.rounds].sort((a, b) => a.number - b.number);
    }

    getLastRound() {
        if (this.rounds.length === 0) {
            return null;
        }
        return this.rounds.reduce((latest, round) => 
            round.number > latest.number ? round : latest
        );
    }

    // Validation methods
    canStartTournament() {
        return this.status === 'setup' && this.players.length >= 4;
    }

    canAddRound() {
        if (this.status !== 'active') {
            return false;
        }

        const currentRound = this.getCurrentRound();
        return !currentRound || currentRound.status === 'completed';
    }

    // Scoring methods
    recordMatchResult(matchId, winningPair) {
        const currentRound = this.getCurrentRound();
        if (!currentRound) {
            throw new Error('No active round to record results');
        }

        const match = currentRound.getMatchById(matchId);
        if (!match) {
            throw new Error('Match not found in current round');
        }

        // Record the match result
        match.recordResult(winningPair);

        // Update player scores
        const winningPairIds = match.getWinningPair();
        const losingPairIds = match.getLosingPair();

        winningPairIds.forEach(playerId => {
            const player = this.getPlayer(playerId);
            if (player) {
                player.addScore(this.settings.winnerPoints);
            }
        });

        losingPairIds.forEach(playerId => {
            const player = this.getPlayer(playerId);
            if (player) {
                player.addScore(this.settings.loserPoints);
            }
        });

        // Update round state
        currentRound.recordMatchResult(matchId, winningPair);
    }

    // Rankings and statistics
    getRankings() {
        return this.getPlayers(); // Already sorted by score descending
    }

    getTournamentStats() {
        return {
            totalPlayers: this.players.length,
            totalRounds: this.rounds.length,
            completedRounds: this.rounds.filter(r => r.status === 'completed').length,
            totalMatches: this.rounds.reduce((total, round) => total + round.matches.length, 0),
            completedMatches: this.rounds.reduce((total, round) => 
                total + round.getCompletedMatches().length, 0
            )
        };
    }

    // Settings management
    updateSettings(newSettings) {
        if (this.status === 'active') {
            throw new Error('Cannot modify settings during active tournament');
        }
        this.settings = { ...this.settings, ...newSettings };
    }

    toString() {
        return `Tournament: ${this.name} (${this.status}, ${this.players.length} players, ${this.rounds.length} rounds)`;
    }
}