// Match entity model with pair validation
export class Match {
    constructor(pair1, pair2) {
        this.id = this.generateId();
        this.pair1 = this.validatePair(pair1, 'pair1');
        this.pair2 = this.validatePair(pair2, 'pair2');
        this.validateNoDuplicatePlayers();
        this.winner = null;
        this.status = 'pending';
    }

    static fromJSON(data) {
        const match = new Match(data.pair1, data.pair2);
        match.id = data.id;
        match.winner = data.winner;
        match.status = data.status || 'pending';
        return match;
    }

    toJSON() {
        return {
            id: this.id,
            pair1: this.pair1,
            pair2: this.pair2,
            winner: this.winner,
            status: this.status
        };
    }

    generateId() {
        return 'match_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    validatePair(pair, pairName) {
        if (!Array.isArray(pair)) {
            throw new Error(`${pairName} must be an array`);
        }
        
        if (pair.length !== 2) {
            throw new Error(`${pairName} must contain exactly 2 players`);
        }

        if (pair[0] === pair[1]) {
            throw new Error(`${pairName} cannot have duplicate players`);
        }

        // Validate player IDs are strings
        pair.forEach((playerId, index) => {
            if (!playerId || typeof playerId !== 'string') {
                throw new Error(`${pairName}[${index}] must be a valid player ID`);
            }
        });

        return [...pair]; // Return copy to prevent external modification
    }

    validateNoDuplicatePlayers() {
        const allPlayers = [...this.pair1, ...this.pair2];
        const uniquePlayers = new Set(allPlayers);
        
        if (allPlayers.length !== uniquePlayers.size) {
            throw new Error('A player cannot appear in both pairs of the same match');
        }
    }

    // Record match result and transition to completed state
    recordResult(winningPair) {
        if (this.status === 'completed') {
            throw new Error('Cannot modify completed match result');
        }

        if (winningPair !== 1 && winningPair !== 2) {
            throw new Error('Winner must be 1 (pair1) or 2 (pair2)');
        }

        this.winner = winningPair;
        this.status = 'completed';
    }

    // Get winning and losing pairs
    getWinningPair() {
        if (this.winner === null) {
            return null;
        }
        return this.winner === 1 ? this.pair1 : this.pair2;
    }

    getLosingPair() {
        if (this.winner === null) {
            return null;
        }
        return this.winner === 1 ? this.pair2 : this.pair1;
    }

    // Get all player IDs in this match
    getAllPlayerIds() {
        return [...this.pair1, ...this.pair2];
    }

    // Check if a player is in this match
    hasPlayer(playerId) {
        return this.getAllPlayerIds().includes(playerId);
    }

    // Check if two players are paired together in this match
    arePlayersPaired(playerId1, playerId2) {
        return (this.pair1.includes(playerId1) && this.pair1.includes(playerId2)) ||
               (this.pair2.includes(playerId1) && this.pair2.includes(playerId2));
    }

    // Get the partner of a player in this match
    getPartner(playerId) {
        if (this.pair1.includes(playerId)) {
            return this.pair1.find(id => id !== playerId);
        }
        if (this.pair2.includes(playerId)) {
            return this.pair2.find(id => id !== playerId);
        }
        return null;
    }

    // Get opponents of a player
    getOpponents(playerId) {
        if (this.pair1.includes(playerId)) {
            return this.pair2;
        }
        if (this.pair2.includes(playerId)) {
            return this.pair1;
        }
        return [];
    }

    // Check if match can be modified
    canModify() {
        return this.status === 'pending';
    }

    // Reset match result
    reset() {
        if (this.status === 'completed') {
            this.winner = null;
            this.status = 'pending';
        }
    }

    // Utility methods for display
    getPairDisplayNames(players) {
        // Helper to get player names for display (requires players array)
        const getPairNames = (pair) => {
            return pair.map(id => {
                const player = players.find(p => p.id === id);
                return player ? player.name : 'Unknown';
            });
        };

        return {
            pair1Names: getPairNames(this.pair1),
            pair2Names: getPairNames(this.pair2)
        };
    }

    toString() {
        const pair1Str = this.pair1.join(' & ');
        const pair2Str = this.pair2.join(' & ');
        const statusStr = this.status === 'completed' ? 
            ` (Winner: Pair ${this.winner})` : ' (Pending)';
        return `${pair1Str} vs ${pair2Str}${statusStr}`;
    }
}