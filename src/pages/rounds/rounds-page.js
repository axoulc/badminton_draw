// Rounds Management Page - Material 3 Web Component
export class RoundsPage extends HTMLElement {
    constructor() {
        super();
        this.tournamentService = null;
        this.rounds = [];
        this.currentRound = null;
        this.refreshInterval = null;
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
        if (this.isConnected && this.querySelector('#rounds-list')) {
            this.loadData();
        }
        // Otherwise, loadData will be called by connectedCallback
    }

    startAutoRefresh() {
        // Refresh every 30 seconds to show live updates
        this.refreshInterval = setInterval(() => {
            this.loadData();
        }, 30000);
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }

    loadData() {
        if (!this.tournamentService) return;
        
        this.rounds = this.tournamentService.getRounds();
        this.currentRound = this.tournamentService.getCurrentRound();
        this.updateDisplay();
    }

    render() {
        this.innerHTML = `
            <div class="rounds-page">
                <div class="page-header">
                    <h1 class="headline-large">Rounds Management</h1>
                    <div class="stats-chips">
                        <md-filter-chip id="total-rounds-chip" label="0 rounds"></md-filter-chip>
                        <md-filter-chip id="current-round-chip" label="No active round"></md-filter-chip>
                    </div>
                </div>

                <div class="generate-round-section" id="generate-section">
                    <div class="section-content">
                        <div class="action-info">
                            <md-icon class="section-icon">casino</md-icon>
                            <div class="action-details">
                                <h2 class="title-large">Generate New Round</h2>
                                <p class="body-medium">Create random pairings for the next round</p>
                                <p class="body-small" id="pairing-info"></p>
                            </div>
                        </div>
                        <md-filled-button id="generate-round-btn">
                            <md-icon slot="icon">shuffle</md-icon>
                            Generate Round
                        </md-filled-button>
                    </div>
                </div>

                <div class="current-round-section" id="current-round-section" style="display: none;">
                    <div class="section-header">
                        <div class="round-info">
                            <h2 class="title-large" id="current-round-title">Round 1</h2>
                            <div class="round-stats">
                                <md-filter-chip id="matches-progress-chip" label="0/0 completed"></md-filter-chip>
                            </div>
                        </div>
                        <div class="round-actions">
                            <md-text-button id="refresh-btn">
                                <md-icon slot="icon">refresh</md-icon>
                                Refresh
                            </md-text-button>
                        </div>
                    </div>
                    
                    <div id="current-matches" class="matches-grid">
                        <!-- Current round matches will be populated here -->
                    </div>
                </div>

                <div class="rounds-history-section">
                    <div class="section-header">
                        <h2 class="title-large">Tournament History</h2>
                        <div class="history-actions">
                            <md-text-button id="expand-all-btn">
                                <md-icon slot="icon">unfold_more</md-icon>
                                Expand All
                            </md-text-button>
                        </div>
                    </div>
                    
                    <div id="rounds-history" class="rounds-history">
                        <div class="empty-state" id="history-empty-state">
                            <md-icon class="empty-icon">history</md-icon>
                            <p class="body-large">No rounds completed yet</p>
                            <p class="body-medium">Generate your first round to begin the tournament</p>
                        </div>
                    </div>
                </div>

                <!-- Round Details Dialog -->
                <md-dialog id="round-details-dialog">
                    <div slot="headline" id="dialog-round-title">Round Details</div>
                    <div slot="content" id="dialog-round-content">
                        <!-- Round details will be populated here -->
                    </div>
                    <div slot="actions">
                        <md-filled-button id="close-dialog-btn">Close</md-filled-button>
                    </div>
                </md-dialog>
            </div>
        `;
    }

    bindEvents() {
        // Generate round button
        this.querySelector('#generate-round-btn').addEventListener('click', () => {
            this.generateNewRound();
        });

        // Refresh button
        this.querySelector('#refresh-btn').addEventListener('click', () => {
            this.loadData();
            this.showSuccess('Data refreshed');
        });

        // Expand all rounds
        this.querySelector('#expand-all-btn').addEventListener('click', () => {
            this.expandAllRounds();
        });

        // Close dialog
        this.querySelector('#close-dialog-btn').addEventListener('click', () => {
            this.querySelector('#round-details-dialog').close();
        });
    }

    updateDisplay() {
        this.updateStats();
        this.updateGenerateSection();
        this.updateCurrentRound();
        this.updateRoundsHistory();
    }

    updateStats() {
        const totalChip = this.querySelector('#total-rounds-chip');
        const currentChip = this.querySelector('#current-round-chip');

        // Check if elements exist before accessing them
        if (!totalChip || !currentChip) {
            console.warn('Rounds stats elements not found, DOM may not be ready');
            return;
        }

        totalChip.label = `${this.rounds.length} round${this.rounds.length !== 1 ? 's' : ''}`;
        
        if (this.currentRound) {
            currentChip.label = `Round ${this.currentRound.number} active`;
        } else if (this.rounds.length > 0) {
            currentChip.label = 'All rounds completed';
        } else {
            currentChip.label = 'No active round';
        }
    }

    updateGenerateSection() {
        const section = this.querySelector('#generate-section');
        const button = this.querySelector('#generate-round-btn');
        const info = this.querySelector('#pairing-info');

        // Check if elements exist before accessing them
        if (!section || !button || !info) {
            console.warn('Generate section elements not found, DOM may not be ready');
            return;
        }

        if (!this.tournamentService) {
            section.style.display = 'none';
            return;
        }

        const canGenerate = this.canGenerateNewRound();
        const players = this.tournamentService.getPlayers();
        
        if (canGenerate) {
            section.style.display = 'block';
            button.disabled = false;
            
            const activePlayers = players.filter(p => p.status === 'active');
            const nextRoundNumber = this.rounds.length + 1;
            info.textContent = `Round ${nextRoundNumber} will pair ${activePlayers.length} active players`;
        } else {
            if (players.length < 4) {
                info.textContent = 'Need at least 4 players to generate rounds';
                button.disabled = true;
            } else if (this.currentRound && this.currentRound.status !== 'completed') {
                info.textContent = 'Complete current round before generating next one';
                button.disabled = true;
            } else {
                section.style.display = 'none';
            }
        }
    }

    updateCurrentRound() {
        const section = this.querySelector('#current-round-section');
        const title = this.querySelector('#current-round-title');
        const matchesContainer = this.querySelector('#current-matches');
        const progressChip = this.querySelector('#matches-progress-chip');

        // Check if elements exist before accessing them
        if (!section || !title || !matchesContainer || !progressChip) {
            console.warn('Current round elements not found, DOM may not be ready');
            return;
        }

        if (!this.currentRound) {
            section.style.display = 'none';
            return;
        }

        section.style.display = 'block';
        title.textContent = `Round ${this.currentRound.number}`;

        const completedMatches = this.currentRound.getCompletedMatches().length;
        const totalMatches = this.currentRound.matches.length;
        progressChip.label = `${completedMatches}/${totalMatches} completed`;

        // Render current round matches
        matchesContainer.innerHTML = this.renderMatches(this.currentRound.matches, true);
    }

    updateRoundsHistory() {
        const historyContainer = this.querySelector('#rounds-history');
        const emptyState = this.querySelector('#history-empty-state');

        // Check if elements exist before accessing them
        if (!historyContainer || !emptyState) {
            console.warn('Rounds history elements not found, DOM may not be ready');
            return;
        }

        const completedRounds = this.rounds.filter(r => r.status === 'completed');

        if (completedRounds.length === 0) {
            emptyState.style.display = 'flex';
            return;
        }

        emptyState.style.display = 'none';

        const historyHTML = completedRounds.reverse().map(round => `
            <div class="round-card" data-round-number="${round.number}">
                <div class="round-card-header" onclick="this.parentElement.classList.toggle('expanded')">
                    <div class="round-info">
                        <h3 class="title-medium">Round ${round.number}</h3>
                        <p class="body-small">${round.matches.length} matches played</p>
                    </div>
                    <div class="round-summary">
                        <span class="body-small">${this.formatRoundTime(round.completedAt)}</span>
                        <md-icon class="expand-icon">expand_more</md-icon>
                    </div>
                </div>
                <div class="round-card-content">
                    ${this.renderMatches(round.matches, false)}
                </div>
            </div>
        `).join('');

        historyContainer.innerHTML = historyHTML;
    }

    renderMatches(matches, isCurrentRound = false) {
        return matches.map(match => {
            const pair1Names = `${match.pair1.player1.name} / ${match.pair1.player2.name}`;
            const pair2Names = `${match.pair2.player1.name} / ${match.pair2.player2.name}`;
            
            let statusContent = '';
            let cardClass = 'match-card';
            
            if (match.status === 'completed') {
                cardClass += ' completed';
                const winnerPair = match.winningPair === 1 ? pair1Names : pair2Names;
                statusContent = `
                    <div class="match-result">
                        <md-icon class="winner-icon">emoji_events</md-icon>
                        <span class="winner-text">Winner: ${winnerPair}</span>
                    </div>
                `;
            } else if (isCurrentRound) {
                cardClass += ' pending';
                statusContent = `
                    <div class="match-pending">
                        <md-icon class="pending-icon">schedule</md-icon>
                        <span class="pending-text">Pending</span>
                        <md-text-button class="score-match-btn" data-match-id="${match.id}">
                            <md-icon slot="icon">sports_score</md-icon>
                            Score Match
                        </md-text-button>
                    </div>
                `;
            }

            return `
                <div class="${cardClass}" data-match-id="${match.id}">
                    <div class="match-pairs">
                        <div class="pair ${match.winningPair === 1 ? 'winner' : ''}">
                            <md-icon class="pair-icon">people</md-icon>
                            <span class="pair-names">${pair1Names}</span>
                        </div>
                        <div class="vs-divider">
                            <md-icon>close</md-icon>
                        </div>
                        <div class="pair ${match.winningPair === 2 ? 'winner' : ''}">
                            <md-icon class="pair-icon">people</md-icon>
                            <span class="pair-names">${pair2Names}</span>
                        </div>
                    </div>
                    ${statusContent}
                </div>
            `;
        }).join('');
    }

    canGenerateNewRound() {
        if (!this.tournamentService) return false;
        
        const tournament = this.tournamentService.getCurrentTournament();
        if (!tournament) return false;

        const players = this.tournamentService.getPlayers();
        if (players.length < 4) return false;

        // Check if current round is completed or if there's no current round
        if (this.currentRound && this.currentRound.status !== 'completed') {
            return false;
        }

        return tournament.status === 'active' || tournament.status === 'setup';
    }

    generateNewRound() {
        if (!this.canGenerateNewRound()) {
            this.showError('Cannot generate new round at this time');
            return;
        }

        try {
            // Start tournament if it's in setup
            const tournament = this.tournamentService.getCurrentTournament();
            if (tournament.status === 'setup') {
                this.tournamentService.startTournament();
            }

            const newRound = this.tournamentService.generateRound();
            this.loadData();
            this.showSuccess(`Generated Round ${newRound.number} with ${newRound.matches.length} matches`);

            // Scroll to current round section
            this.querySelector('#current-round-section').scrollIntoView({ 
                behavior: 'smooth', 
                block: 'start' 
            });
        } catch (error) {
            this.showError(`Failed to generate round: ${error.message}`);
        }
    }

    expandAllRounds() {
        const roundCards = this.querySelectorAll('.round-card');
        roundCards.forEach(card => {
            card.classList.add('expanded');
        });
    }

    formatRoundTime(timestamp) {
        if (!timestamp) return 'Unknown time';
        
        const date = new Date(timestamp);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays < 7) return `${diffDays}d ago`;
        
        return date.toLocaleDateString();
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

customElements.define('rounds-page', RoundsPage);