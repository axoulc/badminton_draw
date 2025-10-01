// Rankings Page - Material 3 Web Component
export class RankingsPage extends HTMLElement {
    constructor() {
        super();
        this.tournamentService = null;
        this.players = [];
        this.tournamentStats = {};
        this.refreshInterval = null;
        this.sortBy = 'score'; // 'score', 'matches', 'winRate'
        this.sortOrder = 'desc';
    }

    connectedCallback() {
        this.render();
        this.bindEvents();
        this.loadData();
        this.startAutoRefresh();
    }

    disconnectedCallback() {
        this.stopAutoRefresh();
    }

    setTournamentService(service) {
        this.tournamentService = service;
        // Only load data if the component is properly connected and rendered
        if (this.isConnected && this.querySelector('#rankings-list')) {
            this.loadData();
        }
        // Otherwise, loadData will be called by connectedCallback
    }

    startAutoRefresh() {
        // Refresh every 15 seconds for live updates
        this.refreshInterval = setInterval(() => {
            this.loadData();
        }, 15000);
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }

    loadData() {
        if (!this.tournamentService) return;
        
        this.players = this.tournamentService.getRankings();
        this.tournamentStats = this.tournamentService.getTournamentStats();
        this.updateDisplay();
    }

    render() {
        this.innerHTML = `
            <div class="rankings-page">
                <div class="page-header">
                    <h1 class="headline-large">Tournament Rankings</h1>
                    <div class="header-actions">
                        <md-text-button id="refresh-btn">
                            <md-icon slot="icon">refresh</md-icon>
                            Refresh
                        </md-text-button>
                        <md-outlined-button id="export-btn">
                            <md-icon slot="icon">download</md-icon>
                            Export
                        </md-outlined-button>
                    </div>
                </div>

                <div class="tournament-stats">
                    <div class="stats-grid">
                        <div class="stat-card">
                            <md-icon class="stat-icon">people</md-icon>
                            <div class="stat-info">
                                <span class="stat-value" id="total-players">0</span>
                                <span class="stat-label">Players</span>
                            </div>
                        </div>
                        <div class="stat-card">
                            <md-icon class="stat-icon">casino</md-icon>
                            <div class="stat-info">
                                <span class="stat-value" id="total-rounds">0</span>
                                <span class="stat-label">Rounds</span>
                            </div>
                        </div>
                        <div class="stat-card">
                            <md-icon class="stat-icon">sports_score</md-icon>
                            <div class="stat-info">
                                <span class="stat-value" id="total-matches">0</span>
                                <span class="stat-label">Matches</span>
                            </div>
                        </div>
                        <div class="stat-card">
                            <md-icon class="stat-icon">percent</md-icon>
                            <div class="stat-info">
                                <span class="stat-value" id="completion-rate">0%</span>
                                <span class="stat-label">Complete</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="rankings-section">
                    <div class="section-header">
                        <h2 class="title-large">Leaderboard</h2>
                        <div class="sort-controls">
                            <md-outlined-select id="sort-select" label="Sort by">
                                <md-select-option value="score" selected>
                                    <div slot="headline">Points</div>
                                </md-select-option>
                                <md-select-option value="matches">
                                    <div slot="headline">Matches Played</div>
                                </md-select-option>
                                <md-select-option value="winRate">
                                    <div slot="headline">Win Rate</div>
                                </md-select-option>
                            </md-outlined-select>
                            <md-icon-button id="sort-order-btn" title="Toggle sort order">
                                <md-icon>arrow_downward</md-icon>
                            </md-icon-button>
                        </div>
                    </div>

                    <div class="rankings-table">
                        <div class="table-header">
                            <div class="rank-col">Rank</div>
                            <div class="player-col">Player</div>
                            <div class="score-col">Points</div>
                            <div class="matches-col">Matches</div>
                            <div class="winrate-col">Win Rate</div>
                            <div class="trend-col">Trend</div>
                        </div>
                        
                        <div id="rankings-list" class="rankings-list">
                            <div class="empty-state" id="empty-state">
                                <md-icon class="empty-icon">emoji_events</md-icon>
                                <p class="body-large">No players to rank yet</p>
                                <p class="body-medium">Add players and play matches to see rankings</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="podium-section" id="podium-section" style="display: none;">
                    <div class="section-header">
                        <h2 class="title-large">Top 3 Players</h2>
                    </div>
                    
                    <div class="podium">
                        <div class="podium-place second" id="second-place">
                            <div class="place-number">2</div>
                            <div class="player-info">
                                <md-icon class="player-avatar">person</md-icon>
                                <h3 class="player-name">-</h3>
                                <p class="player-score">0 pts</p>
                            </div>
                        </div>
                        
                        <div class="podium-place first" id="first-place">
                            <div class="place-number">1</div>
                            <div class="player-info">
                                <md-icon class="player-avatar">person</md-icon>
                                <h3 class="player-name">-</h3>
                                <p class="player-score">0 pts</p>
                            </div>
                            <md-icon class="crown">emoji_events</md-icon>
                        </div>
                        
                        <div class="podium-place third" id="third-place">
                            <div class="place-number">3</div>
                            <div class="player-info">
                                <md-icon class="player-avatar">person</md-icon>
                                <h3 class="player-name">-</h3>
                                <p class="player-score">0 pts</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Player Details Dialog -->
                <md-dialog id="player-details-dialog">
                    <div slot="headline" id="player-details-title">Player Details</div>
                    <div slot="content" id="player-details-content">
                        <!-- Player details will be populated here -->
                    </div>
                    <div slot="actions">
                        <md-filled-button id="close-details-btn">Close</md-filled-button>
                    </div>
                </md-dialog>
            </div>
        `;
    }

    bindEvents() {
        // Refresh button
        this.querySelector('#refresh-btn').addEventListener('click', () => {
            this.loadData();
            this.showSuccess('Rankings refreshed');
        });

        // Export button
        this.querySelector('#export-btn').addEventListener('click', () => {
            this.exportRankings();
        });

        // Sort controls
        this.querySelector('#sort-select').addEventListener('change', (e) => {
            this.sortBy = e.target.value;
            this.updateRankings();
        });

        this.querySelector('#sort-order-btn').addEventListener('click', () => {
            this.toggleSortOrder();
        });

        // Player details dialog
        this.querySelector('#close-details-btn').addEventListener('click', () => {
            this.querySelector('#player-details-dialog').close();
        });
    }

    updateDisplay() {
        this.updateStats();
        this.updateRankings();
        this.updatePodium();
    }

    updateStats() {
        const totalPlayersEl = this.querySelector('#total-players');
        const totalRoundsEl = this.querySelector('#total-rounds');
        const totalMatchesEl = this.querySelector('#total-matches');
        const completionRateEl = this.querySelector('#completion-rate');

        // Check if elements exist before accessing them
        if (!totalPlayersEl || !totalRoundsEl || !totalMatchesEl || !completionRateEl) {
            console.warn('Rankings stats elements not found, DOM may not be ready');
            return;
        }

        totalPlayersEl.textContent = this.tournamentStats.totalPlayers || 0;
        totalRoundsEl.textContent = this.tournamentStats.totalRounds || 0;
        totalMatchesEl.textContent = this.tournamentStats.totalMatches || 0;
        
        const completionRate = this.tournamentStats.totalMatches > 0 
            ? Math.round((this.tournamentStats.completedMatches / this.tournamentStats.totalMatches) * 100)
            : 0;
        completionRateEl.textContent = `${completionRate}%`;
    }

    updateRankings() {
        const listContainer = this.querySelector('#rankings-list');
        const emptyState = this.querySelector('#empty-state');

        if (this.players.length === 0) {
            emptyState.style.display = 'flex';
            return;
        }

        emptyState.style.display = 'none';

        // Sort players based on current criteria
        const sortedPlayers = this.getSortedPlayers();

        const rankingsHTML = sortedPlayers.map((player, index) => {
            const rank = index + 1;
            const winRate = player.matchesPlayed > 0 
                ? Math.round((player.matchesWon / player.matchesPlayed) * 100)
                : 0;
            
            const trend = this.getPlayerTrend(player);
            const rankClass = this.getRankClass(rank);

            return `
                <div class="player-row ${rankClass}" data-player-id="${player.id}">
                    <div class="rank-col">
                        <div class="rank-badge">
                            <span class="rank-number">${rank}</span>
                            ${rank <= 3 ? this.getRankIcon(rank) : ''}
                        </div>
                    </div>
                    <div class="player-col">
                        <div class="player-info">
                            <md-icon class="player-avatar">person</md-icon>
                            <div class="player-details">
                                <h3 class="player-name">${this.escapeHtml(player.name)}</h3>
                                <p class="player-status">${player.status}</p>
                            </div>
                        </div>
                    </div>
                    <div class="score-col">
                        <span class="score-value">${player.score}</span>
                        <span class="score-label">pts</span>
                    </div>
                    <div class="matches-col">
                        <span class="matches-played">${player.matchesPlayed}</span>
                        <span class="matches-won">/ ${player.matchesWon} won</span>
                    </div>
                    <div class="winrate-col">
                        <div class="winrate-display">
                            <span class="winrate-value">${winRate}%</span>
                            <div class="winrate-bar">
                                <div class="winrate-fill" style="width: ${winRate}%"></div>
                            </div>
                        </div>
                    </div>
                    <div class="trend-col">
                        <div class="trend-indicator ${trend.class}">
                            <md-icon class="trend-icon">${trend.icon}</md-icon>
                        </div>
                    </div>
                </div>
            `;
        }).join('');

        listContainer.innerHTML = rankingsHTML;

        // Bind click events for player details
        listContainer.querySelectorAll('.player-row').forEach(row => {
            row.addEventListener('click', (e) => {
                const playerId = e.currentTarget.dataset.playerId;
                this.showPlayerDetails(playerId);
            });
        });
    }

    updatePodium() {
        const podiumSection = this.querySelector('#podium-section');
        
        if (this.players.length < 3) {
            podiumSection.style.display = 'none';
            return;
        }

        podiumSection.style.display = 'block';
        
        const sortedPlayers = this.getSortedPlayers();
        const topThree = sortedPlayers.slice(0, 3);

        // Update podium places
        if (topThree[0]) {
            this.updatePodiumPlace('first-place', topThree[0], 1);
        }
        if (topThree[1]) {
            this.updatePodiumPlace('second-place', topThree[1], 2);
        }
        if (topThree[2]) {
            this.updatePodiumPlace('third-place', topThree[2], 3);
        }
    }

    updatePodiumPlace(elementId, player, rank) {
        const element = this.querySelector(`#${elementId}`);
        const nameEl = element.querySelector('.player-name');
        const scoreEl = element.querySelector('.player-score');

        nameEl.textContent = player.name;
        scoreEl.textContent = `${player.score} pts`;
    }

    getSortedPlayers() {
        const sorted = [...this.players].sort((a, b) => {
            let aValue, bValue;

            switch (this.sortBy) {
                case 'matches':
                    aValue = a.matchesPlayed;
                    bValue = b.matchesPlayed;
                    break;
                case 'winRate':
                    aValue = a.matchesPlayed > 0 ? (a.matchesWon / a.matchesPlayed) : 0;
                    bValue = b.matchesPlayed > 0 ? (b.matchesWon / b.matchesPlayed) : 0;
                    break;
                default: // score
                    aValue = a.score;
                    bValue = b.score;
            }

            const result = this.sortOrder === 'desc' ? bValue - aValue : aValue - bValue;
            
            // Secondary sort by score if primary values are equal
            if (result === 0 && this.sortBy !== 'score') {
                return this.sortOrder === 'desc' ? b.score - a.score : a.score - b.score;
            }
            
            return result;
        });

        return sorted;
    }

    getPlayerTrend(player) {
        // Simple trend calculation based on recent performance
        // This would be more sophisticated with match history
        const winRate = player.matchesPlayed > 0 ? (player.matchesWon / player.matchesPlayed) : 0;
        
        if (winRate >= 0.7) {
            return { class: 'trending-up', icon: 'trending_up' };
        } else if (winRate >= 0.4) {
            return { class: 'trending-flat', icon: 'trending_flat' };
        } else {
            return { class: 'trending-down', icon: 'trending_down' };
        }
    }

    getRankClass(rank) {
        if (rank === 1) return 'rank-first';
        if (rank === 2) return 'rank-second';
        if (rank === 3) return 'rank-third';
        return '';
    }

    getRankIcon(rank) {
        const icons = ['', 'emoji_events', 'military_tech', 'workspace_premium'];
        return `<md-icon class="rank-icon">${icons[rank]}</md-icon>`;
    }

    toggleSortOrder() {
        this.sortOrder = this.sortOrder === 'desc' ? 'asc' : 'desc';
        const button = this.querySelector('#sort-order-btn');
        const icon = button.querySelector('md-icon');
        
        icon.textContent = this.sortOrder === 'desc' ? 'arrow_downward' : 'arrow_upward';
        button.title = `Sort ${this.sortOrder === 'desc' ? 'descending' : 'ascending'}`;
        
        this.updateRankings();
    }

    showPlayerDetails(playerId) {
        const player = this.players.find(p => p.id === playerId);
        if (!player) return;

        const winRate = player.matchesPlayed > 0 
            ? Math.round((player.matchesWon / player.matchesPlayed) * 100)
            : 0;
        const lossRate = 100 - winRate;

        const content = `
            <div class="player-detail-content">
                <div class="player-header">
                    <md-icon class="player-avatar-large">person</md-icon>
                    <div class="player-info">
                        <h2 class="title-large">${this.escapeHtml(player.name)}</h2>
                        <p class="body-medium">Status: ${player.status}</p>
                    </div>
                </div>
                
                <div class="detail-stats">
                    <div class="stat-row">
                        <span class="stat-label">Total Points:</span>
                        <span class="stat-value primary">${player.score}</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Matches Played:</span>
                        <span class="stat-value">${player.matchesPlayed}</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Matches Won:</span>
                        <span class="stat-value success">${player.matchesWon}</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Matches Lost:</span>
                        <span class="stat-value error">${player.matchesPlayed - player.matchesWon}</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Win Rate:</span>
                        <span class="stat-value">${winRate}%</span>
                    </div>
                </div>
                
                <div class="performance-chart">
                    <h3 class="title-medium">Performance</h3>
                    <div class="chart-bar">
                        <div class="bar-section wins" style="width: ${winRate}%">
                            <span class="bar-label">Wins: ${winRate}%</span>
                        </div>
                        <div class="bar-section losses" style="width: ${lossRate}%">
                            <span class="bar-label">Losses: ${lossRate}%</span>
                        </div>
                    </div>
                </div>
            </div>
        `;

        this.querySelector('#player-details-title').textContent = `${player.name} - Details`;
        this.querySelector('#player-details-content').innerHTML = content;
        this.querySelector('#player-details-dialog').show();
    }

    exportRankings() {
        if (this.players.length === 0) {
            this.showError('No data to export');
            return;
        }

        try {
            const sortedPlayers = this.getSortedPlayers();
            const csvContent = this.generateCSV(sortedPlayers);
            
            const blob = new Blob([csvContent], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            a.download = `tournament-rankings-${new Date().toISOString().split('T')[0]}.csv`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            
            URL.revokeObjectURL(url);
            this.showSuccess('Rankings exported successfully');
        } catch (error) {
            this.showError(`Export failed: ${error.message}`);
        }
    }

    generateCSV(players) {
        const headers = ['Rank', 'Player Name', 'Points', 'Matches Played', 'Matches Won', 'Win Rate (%)'];
        const rows = players.map((player, index) => {
            const rank = index + 1;
            const winRate = player.matchesPlayed > 0 
                ? Math.round((player.matchesWon / player.matchesPlayed) * 100)
                : 0;
            
            return [
                rank,
                player.name,
                player.score,
                player.matchesPlayed,
                player.matchesWon,
                winRate
            ];
        });

        const csvContent = [headers, ...rows]
            .map(row => row.map(field => `"${field}"`).join(','))
            .join('\n');

        return csvContent;
    }

    showSuccess(message) {
        const toast = document.createElement('div');
        toast.className = 'toast success';
        toast.innerHTML = `
            <md-icon>check_circle</md-icon>
            <span>${this.escapeHtml(message)}</span>
        `;
        
        document.body.appendChild(toast);
        setTimeout(() => toast.classList.add('show'), 100);
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, 3000);
    }

    showError(message) {
        const toast = document.createElement('div');
        toast.className = 'toast error';
        toast.innerHTML = `
            <md-icon>error</md-icon>
            <span>${this.escapeHtml(message)}</span>
        `;
        
        document.body.appendChild(toast);
        setTimeout(() => toast.classList.add('show'), 100);
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, 4000);
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

customElements.define('rankings-page', RankingsPage);