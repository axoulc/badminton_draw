// Round entity model with state transitions
export class Round {
    constructor(number, matches = []) {
        this.id = this.generateId();
        this.number = this.validateNumber(number);
        this.matches = matches;
        this.status = 'planned';
        this.createdAt = new Date();
    }

    static fromJSON(data) {
        const round = new Round(data.number);
        round.id = data.id;
        round.matches = data.matches || [];
        round.status = data.status || 'planned';
        round.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
        return round;
    }

    toJSON() {
        return {
            id: this.id,
            number: this.number,
            matches: this.matches,
            status: this.status,
            createdAt: this.createdAt.toISOString()
        };
    }

    validateNumber(number) {
        if (!Number.isInteger(number) || number < 1) {
            throw new Error('Round number must be a positive integer');
        }
        return number;
    }

    generateId() {
        return 'round_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    addMatch(match) {
        if (!match || typeof match !== 'object') {
            throw new Error('Invalid match object');
        }
        this.matches.push(match);
    }

    // State transition methods
    start() {
        if (this.status !== 'planned') {
            throw new Error('Round can only be started from planned state');
        }
        if (this.matches.length === 0) {
            throw new Error('Cannot start round without matches');
        }
        this.status = 'in-progress';
    }

    complete() {
        if (this.status !== 'in-progress') {
            throw new Error('Round can only be completed from in-progress state');
        }
        if (!this.allMatchesCompleted()) {
            throw new Error('Cannot complete round until all matches are finished');
        }
        this.status = 'completed';
    }

    // Validation methods
    validateMatches() {
        if (!Array.isArray(this.matches)) {
            throw new Error('Matches must be an array');
        }
        
        if (this.matches.length === 0) {
            throw new Error('Round must have at least one match');
        }

        // Validate all matches reference valid players
        const playerIds = new Set();
        for (const match of this.matches) {
            if (!match.pair1 || !match.pair2) {
                throw new Error('All matches must have two pairs');
            }
            
            // Check for player ID uniqueness within round
            [...match.pair1, ...match.pair2].forEach(playerId => {
                if (playerIds.has(playerId)) {
                    throw new Error('Player cannot appear in multiple matches in same round');
                }
                playerIds.add(playerId);
            });
        }
    }

    // Utility methods
    allMatchesCompleted() {
        return this.matches.length > 0 && this.matches.every(match => match.status === 'completed');
    }

    getCompletedMatches() {
        return this.matches.filter(match => match.status === 'completed');
    }

    getPendingMatches() {
        return this.matches.filter(match => match.status === 'pending');
    }

    getMatchById(matchId) {
        return this.matches.find(match => match.id === matchId);
    }

    // Check if round can be modified
    canModify() {
        return this.status === 'planned';
    }

    // Record a match result (triggers state transition if needed)
    recordMatchResult(matchId, winner) {
        const match = this.getMatchById(matchId);
        if (!match) {
            throw new Error('Match not found in this round');
        }

        // This will be handled by the match itself, but we track state transitions
        if (this.status === 'planned') {
            this.start();
        }

        // After match is completed, check if round should be completed
        if (this.allMatchesCompleted()) {
            this.complete();
        }
    }

    toString() {
        return `Round ${this.number} (${this.status}, ${this.matches.length} matches)`;
    }
}