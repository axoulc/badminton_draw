// PairingService implementation with Fisher-Yates shuffle
import { Match } from '../models/match.js';

export class PairingService {
    
    /**
     * Generate random doubles pairings with constraints
     * @param {Player[]} players - Array of active players
     * @param {Round} previousRound - Optional previous round for constraint checking
     * @returns {Match[]} Array of Match objects with pair assignments
     */
    generatePairings(players, previousRound = null) {
        if (!Array.isArray(players) || players.length < 4) {
            throw new Error('Need at least 4 players to generate pairings');
        }

        const activePlayers = players.filter(p => p.isActive);
        if (activePlayers.length < 4) {
            throw new Error('Need at least 4 active players to generate pairings');
        }

        // Handle odd number of players by having one sit out
        let playersForPairing = [...activePlayers];
        if (playersForPairing.length % 2 !== 0) {
            const sittingPlayer = this.selectSittingPlayer(playersForPairing);
            sittingPlayer.setActive(false);
            playersForPairing = playersForPairing.filter(p => p.id !== sittingPlayer.id);
        }

        // Shuffle players randomly
        const shuffledPlayers = this.shufflePlayers(playersForPairing);
        
        // Generate pairs and matches with constraint checking
        const matches = this.createMatches(shuffledPlayers, previousRound);
        
        // Validate the generated pairings
        if (!this.validatePairings(matches, previousRound)) {
            // If validation fails, try regenerating once more
            const reshuffledPlayers = this.shufflePlayers(playersForPairing);
            const newMatches = this.createMatches(reshuffledPlayers, previousRound);
            if (!this.validatePairings(newMatches, previousRound)) {
                // Accept the pairings even if not perfect (pragmatic approach)
                console.warn('Could not avoid all repeated partnerships, proceeding anyway');
            }
            return newMatches;
        }

        return matches;
    }

    /**
     * Create matches from shuffled players
     * @param {Player[]} shuffledPlayers - Already shuffled player array
     * @param {Round} previousRound - Previous round for constraint checking
     * @returns {Match[]} Array of matches
     */
    createMatches(shuffledPlayers, previousRound) {
        const matches = [];
        
        // Group players into pairs (every 2 consecutive players)
        const pairs = [];
        for (let i = 0; i < shuffledPlayers.length; i += 2) {
            pairs.push([shuffledPlayers[i].id, shuffledPlayers[i + 1].id]);
        }

        // Shuffle pairs to create random matchups
        const shuffledPairs = this.shuffleArray(pairs);

        // Create matches by pairing consecutive pairs
        for (let i = 0; i < shuffledPairs.length; i += 2) {
            if (i + 1 < shuffledPairs.length) {
                const match = new Match(shuffledPairs[i], shuffledPairs[i + 1]);
                matches.push(match);
            }
        }

        return matches;
    }

    /**
     * Validate that pairing constraints are satisfied
     * @param {Match[]} matches - Matches to validate
     * @param {Round} previousRound - Previous round for constraint checking
     * @returns {boolean} True if all constraints satisfied
     */
    validatePairings(matches, previousRound = null) {
        if (!Array.isArray(matches)) {
            return false;
        }

        // Check each player appears exactly once
        const playerIds = new Set();
        for (const match of matches) {
            const allPlayers = match.getAllPlayerIds();
            for (const playerId of allPlayers) {
                if (playerIds.has(playerId)) {
                    return false; // Player appears twice
                }
                playerIds.add(playerId);
            }
        }

        // Check no duplicate pairings from previous round (if provided)
        if (previousRound && previousRound.matches) {
            const previousPairings = this.extractPairings(previousRound.matches);
            const currentPairings = this.extractPairings(matches);
            
            for (const pairing of currentPairings) {
                if (this.pairingExists(pairing, previousPairings)) {
                    return false; // Duplicate pairing found
                }
            }
        }

        return true;
    }

    /**
     * Extract all partner pairings from matches
     * @param {Match[]} matches - Array of matches
     * @returns {string[][]} Array of partner pairs
     */
    extractPairings(matches) {
        const pairings = [];
        for (const match of matches) {
            // Add both pairs from the match
            pairings.push([...match.pair1].sort());
            pairings.push([...match.pair2].sort());
        }
        return pairings;
    }

    /**
     * Check if a pairing exists in a list of pairings
     * @param {string[]} pairing - Pair to check for
     * @param {string[][]} pairingsList - List of existing pairings
     * @returns {boolean} True if pairing exists
     */
    pairingExists(pairing, pairingsList) {
        const sortedPairing = [...pairing].sort();
        return pairingsList.some(existing => 
            existing.length === sortedPairing.length &&
            existing.every((id, index) => id === sortedPairing[index])
        );
    }

    /**
     * Find previous partners for a player
     * @param {string} playerId - Player to check
     * @param {Round} round - Round to examine
     * @returns {string[]} Array of previous partner IDs
     */
    findPreviousPartners(playerId, round) {
        if (!round || !round.matches) {
            return [];
        }

        const partners = [];
        for (const match of round.matches) {
            const partner = match.getPartner(playerId);
            if (partner) {
                partners.push(partner);
            }
        }
        return partners;
    }

    /**
     * Check if two players can be paired together
     * @param {string} player1Id - First player ID
     * @param {string} player2Id - Second player ID
     * @param {Round} previousRound - Previous round for constraint checking
     * @returns {boolean} True if pairing is allowed
     */
    canPairPlayers(player1Id, player2Id, previousRound = null) {
        if (!previousRound) {
            return true; // Always allowed if no previous round
        }

        const player1Partners = this.findPreviousPartners(player1Id, previousRound);
        return !player1Partners.includes(player2Id);
    }

    /**
     * Randomly shuffle player order using Fisher-Yates algorithm
     * @param {Player[]} players - Players to shuffle
     * @returns {Player[]} New array with shuffled players
     */
    shufflePlayers(players) {
        return this.shuffleArray([...players]);
    }

    /**
     * Generic array shuffle using Fisher-Yates algorithm
     * @param {any[]} array - Array to shuffle
     * @returns {any[]} New shuffled array
     */
    shuffleArray(array) {
        const shuffled = [...array];
        for (let i = shuffled.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
        }
        return shuffled;
    }

    /**
     * Randomly select which player sits out (odd numbers)
     * @param {Player[]} players - Array of players
     * @returns {Player} Player who will sit out
     */
    selectSittingPlayer(players) {
        if (players.length % 2 === 0) {
            throw new Error('No need to select sitting player for even number of players');
        }

        const randomIndex = Math.floor(Math.random() * players.length);
        return players[randomIndex];
    }

    /**
     * Get statistics about pairing fairness
     * @param {Round[]} rounds - All tournament rounds
     * @param {Player[]} players - All players
     * @returns {object} Pairing statistics
     */
    getPairingStats(rounds, players) {
        const stats = {
            totalPairings: 0,
            uniquePairings: new Set(),
            playerPairCounts: {},
            playerOpponentCounts: {}
        };

        // Initialize counters for each player
        players.forEach(player => {
            stats.playerPairCounts[player.id] = {};
            stats.playerOpponentCounts[player.id] = {};
            players.forEach(otherPlayer => {
                if (player.id !== otherPlayer.id) {
                    stats.playerPairCounts[player.id][otherPlayer.id] = 0;
                    stats.playerOpponentCounts[player.id][otherPlayer.id] = 0;
                }
            });
        });

        // Count pairings and opponents across all rounds
        for (const round of rounds) {
            for (const match of round.matches) {
                stats.totalPairings += 2; // Two pairs per match

                // Count partnerships
                this.countPartnership(match.pair1, stats.playerPairCounts);
                this.countPartnership(match.pair2, stats.playerPairCounts);

                // Count opponents
                this.countOpponents(match.pair1, match.pair2, stats.playerOpponentCounts);
                this.countOpponents(match.pair2, match.pair1, stats.playerOpponentCounts);

                // Track unique pairings
                const sortedPair1 = [...match.pair1].sort().join(',');
                const sortedPair2 = [...match.pair2].sort().join(',');
                stats.uniquePairings.add(sortedPair1);
                stats.uniquePairings.add(sortedPair2);
            }
        }

        return stats;
    }

    /**
     * Helper to count partnerships
     */
    countPartnership(pair, playerPairCounts) {
        const [player1, player2] = pair;
        playerPairCounts[player1][player2]++;
        playerPairCounts[player2][player1]++;
    }

    /**
     * Helper to count opponents
     */
    countOpponents(team, opponents, playerOpponentCounts) {
        for (const player of team) {
            for (const opponent of opponents) {
                playerOpponentCounts[player][opponent]++;
            }
        }
    }
}