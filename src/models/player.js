// Player entity model with validation
export class Player {
    constructor(name, id = null) {
        this.id = id || this.generateId();
        this.name = this.validateName(name);
        this.score = 0;
        this.isActive = true;
    }

    static fromJSON(data) {
        const player = new Player(data.name, data.id);
        player.score = data.score || 0;
        player.isActive = data.isActive !== undefined ? data.isActive : true;
        return player;
    }

    toJSON() {
        return {
            id: this.id,
            name: this.name,
            score: this.score,
            isActive: this.isActive
        };
    }

    validateName(name) {
        if (!name || typeof name !== 'string' || name.trim().length === 0) {
            throw new Error('Player name must be a non-empty string');
        }
        return name.trim();
    }

    generateId() {
        return 'player_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    addScore(points) {
        if (typeof points !== 'number' || points < 0) {
            throw new Error('Score must be a non-negative number');
        }
        this.score += points;
    }

    resetScore() {
        this.score = 0;
    }

    setActive(active) {
        this.isActive = !!active;
    }

    updateName(newName) {
        this.name = this.validateName(newName);
    }

    // State transition methods
    activate() {
        this.isActive = true;
    }

    deactivate() {
        this.isActive = false;
    }

    // Validation method
    static validateUniqueNames(players) {
        const names = players.map(p => p.name.toLowerCase());
        const uniqueNames = new Set(names);
        if (names.length !== uniqueNames.size) {
            throw new Error('Player names must be unique');
        }
    }

    // Utility methods
    equals(other) {
        return other instanceof Player && this.id === other.id;
    }

    toString() {
        return `Player(${this.name}, score: ${this.score})`;
    }
}