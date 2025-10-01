// Scoring Page - Material 3 Web Component
export class ScoringPage extends HTMLElement {
    constructor() {
        super();
        this.tournamentService = null;
        this.pendingMatches = [];
        this.completedMatches = [];
        this.currentRound = null;
        this.selectedMatch = null;
    }

    connectedCallback() {
        this.render();
        this.bindEvents();
        this.loadData();
    }

    setTournamentService(service) {
        this.tournamentService = service;
        // Only load data if the component is properly connected and rendered
        if (this.isConnected && this.querySelector('#pending-matches-list')) {
            this.loadData();
        }
        // Otherwise, loadData will be called by connectedCallback
    }

    loadData() {
        if (!this.tournamentService) return;
        
        this.currentRound = this.tournamentService.getCurrentRound();
        if (this.currentRound) {
            this.pendingMatches = this.currentRound.getPendingMatches();
            this.completedMatches = this.currentRound.getCompletedMatches();
        } else {
            this.pendingMatches = [];
            this.completedMatches = [];
        }
        
        this.updateDisplay();
    }

    render() {
        this.innerHTML = `
            <div class="scoring-page">
                <div class="page-header">
                    <h1 class="headline-large">Match Scoring</h1>
                    <div class="stats-chips">
                        <md-filter-chip id="pending-matches-chip" label="0 pending"></md-filter-chip>
                        <md-filter-chip id="completed-matches-chip" label="0 completed"></md-filter-chip>
                    </div>
                </div>

                <div class="no-round-section" id="no-round-section">
                    <div class="empty-state">
                        <md-icon class="empty-icon">sports_score</md-icon>
                        <h2 class="title-large">No Active Round</h2>
                        <p class="body-medium">Generate a round from the Rounds page to start scoring matches</p>
                        <md-outlined-button id="go-to-rounds-btn">
                            <md-icon slot="icon">casino</md-icon>
                            Go to Rounds
                        </md-outlined-button>
                    </div>
                </div>

                <div class="scoring-sections" id="scoring-sections">
                    <!-- Pending Matches Section -->
                    <div class="pending-matches-section">
                        <div class="section-header">
                            <h2 class="title-large">Pending Matches</h2>
                            <div class="section-actions">
                                <md-text-button id="refresh-btn">
                                    <md-icon slot="icon">refresh</md-icon>
                                    Refresh
                                </md-text-button>
                            </div>
                        </div>
                        
                        <div id="pending-matches-list" class="matches-list">
                            <div class="empty-state" id="pending-empty-state">
                                <md-icon class="empty-icon">done_all</md-icon>
                                <p class="body-large">All matches completed!</p>
                                <p class="body-medium">Great job scoring all matches in this round</p>
                            </div>
                        </div>
                    </div>

                    <!-- Completed Matches Section -->
                    <div class="completed-matches-section">
                        <div class="section-header">
                            <h2 class="title-large">Completed Matches</h2>
                            <div class="section-actions">
                                <md-text-button id="expand-completed-btn">
                                    <md-icon slot="icon">unfold_more</md-icon>
                                    Show All
                                </md-text-button>
                            </div>
                        </div>
                        
                        <div id="completed-matches-list" class="matches-list collapsed">
                            <div class="empty-state" id="completed-empty-state">
                                <md-icon class="empty-icon">schedule</md-icon>
                                <p class="body-large">No completed matches yet</p>
                                <p class="body-medium">Completed matches will appear here</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Score Dialog -->
                <md-dialog id="score-dialog">
                    <div slot="headline">Score Match</div>
                    <div slot="content" id="score-dialog-content">
                        <div class="match-details">
                            <div class="match-pair">
                                <h3 class="title-medium">Pair 1</h3>
                                <p class="pair-names" id="pair1-names"></p>
                                <md-filled-button class="winner-btn" id="pair1-winner-btn" data-pair="1">
                                    <md-icon slot="icon">emoji_events</md-icon>
                                    Mark as Winner
                                </md-filled-button>
                            </div>
                            
                            <div class="vs-separator">
                                <md-icon>close</md-icon>
                            </div>
                            
                            <div class="match-pair">
                                <h3 class="title-medium">Pair 2</h3>
                                <p class="pair-names" id="pair2-names"></p>
                                <md-filled-button class="winner-btn" id="pair2-winner-btn" data-pair="2">
                                    <md-icon slot="icon">emoji_events</md-icon>
                                    Mark as Winner
                                </md-filled-button>
                            </div>
                        </div>
                        
                        <div class="score-info">
                            <p class="body-small">Winner gets <strong>+2 points</strong>, Loser gets <strong>+1 point</strong></p>
                        </div>
                    </div>
                    <div slot="actions">
                        <md-text-button id="cancel-score-btn">Cancel</md-text-button>
                    </div>
                </md-dialog>

                <!-- Confirm Score Dialog -->
                <md-dialog id="confirm-score-dialog">
                    <div slot="headline">Confirm Result</div>
                    <div slot="content">
                        <p>Confirm match result:</p>
                        <div class="result-summary">
                            <p><strong id="winner-summary"></strong> defeats <strong id="loser-summary"></strong></p>
                        </div>
                        <p class="body-small">This action cannot be undone.</p>
                    </div>
                    <div slot="actions">
                        <md-text-button id="cancel-confirm-btn">Cancel</md-text-button>
                        <md-filled-button id="confirm-result-btn">Confirm Result</md-filled-button>
                    </div>
                </md-dialog>

                <!-- Match Details Dialog -->
                <md-dialog id="match-details-dialog">
                    <div slot="headline" id="match-details-title">Match Details</div>
                    <div slot="content" id="match-details-content">
                        <!-- Match details will be populated here -->
                    </div>
                    <div slot="actions">
                        <md-filled-button id="close-details-btn">Close</md-filled-button>
                    </div>
                </md-dialog>
            </div>
        `;
    }

    bindEvents() {
        // Navigation
        const goToRoundsBtn = this.querySelector('#go-to-rounds-btn');
        if (goToRoundsBtn) {
            goToRoundsBtn.addEventListener('click', () => {
                this.dispatchEvent(new CustomEvent('navigate', { detail: { page: 'rounds' } }));
            });
        }

        // Refresh button
        const refreshBtn = this.querySelector('#refresh-btn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', () => {
                this.loadData();
                this.showSuccess('Data refreshed');
            });
        }

        // Expand/collapse completed matches
        const expandBtn = this.querySelector('#expand-completed-btn');
        if (expandBtn) {
            expandBtn.addEventListener('click', () => {
                this.toggleCompletedMatches();
            });
        }

        // Score dialog events
        const scoreDialog = this.querySelector('#score-dialog');
        
        const cancelScoreBtn = this.querySelector('#cancel-score-btn');
        if (cancelScoreBtn && scoreDialog) {
            cancelScoreBtn.addEventListener('click', () => {
                scoreDialog.close();
            });
        }

        const pair1WinnerBtn = this.querySelector('#pair1-winner-btn');
        if (pair1WinnerBtn) {
            pair1WinnerBtn.addEventListener('click', () => {
                this.showConfirmDialog(1);
            });
        }

        const pair2WinnerBtn = this.querySelector('#pair2-winner-btn');
        if (pair2WinnerBtn) {
            pair2WinnerBtn.addEventListener('click', () => {
                this.showConfirmDialog(2);
            });
        }

        // Confirm dialog events
        const confirmDialog = this.querySelector('#confirm-score-dialog');
        
        this.querySelector('#cancel-confirm-btn').addEventListener('click', () => {
            confirmDialog.close();
        });

        this.querySelector('#confirm-result-btn').addEventListener('click', () => {
            this.recordMatchResult();
        });

        // Match details dialog
        this.querySelector('#close-details-btn').addEventListener('click', () => {
            this.querySelector('#match-details-dialog').close();
        });
    }

    updateDisplay() {
        this.updateStats();
        
        if (!this.currentRound) {
            this.querySelector('#no-round-section').style.display = 'block';
            this.querySelector('#scoring-sections').style.display = 'none';
            return;
        }

        this.querySelector('#no-round-section').style.display = 'none';
        this.querySelector('#scoring-sections').style.display = 'block';
        
        this.updatePendingMatches();
        this.updateCompletedMatches();
    }

    updateStats() {
        const pendingChip = this.querySelector('#pending-matches-chip');
        const completedChip = this.querySelector('#completed-matches-chip');

        // Check if elements exist before accessing them
        if (!pendingChip || !completedChip) {
            console.warn('Scoring stats elements not found, DOM may not be ready');
            return;
        }

        pendingChip.label = `${this.pendingMatches.length} pending`;
        completedChip.label = `${this.completedMatches.length} completed`;
    }

    updatePendingMatches() {
        const listContainer = this.querySelector('#pending-matches-list');
        const emptyState = this.querySelector('#pending-empty-state');

        if (this.pendingMatches.length === 0) {
            emptyState.style.display = 'flex';
            return;
        }

        emptyState.style.display = 'none';

        const matchesHTML = this.pendingMatches.map(match => {
            console.log('🔍 Rendering scoring match:', match);
            
            // Defensive checks for player objects
            const player1Name = match.pair1?.player1?.name || 'Unknown Player';
            const player2Name = match.pair1?.player2?.name || 'Unknown Player';
            const player3Name = match.pair2?.player1?.name || 'Unknown Player';
            const player4Name = match.pair2?.player2?.name || 'Unknown Player';
            
            const pair1Names = `${player1Name} / ${player2Name}`;
            const pair2Names = `${player3Name} / ${player4Name}`;

            return `
                <div class="match-card pending" data-match-id="${match.id}">
                    <div class="match-info">
                        <div class="match-pairs">
                            <div class="pair">
                                <md-icon class="pair-icon">people</md-icon>
                                <span class="pair-names">${pair1Names}</span>
                            </div>
                            <div class="vs-divider">
                                <md-icon>close</md-icon>
                            </div>
                            <div class="pair">
                                <md-icon class="pair-icon">people</md-icon>
                                <span class="pair-names">${pair2Names}</span>
                            </div>
                        </div>
                    </div>
                    <div class="match-actions">
                        <md-filled-button class="score-btn" data-match-id="${match.id}">
                            <md-icon slot="icon">sports_score</md-icon>
                            Score Match
                        </md-filled-button>
                    </div>
                </div>
            `;
        }).join('');

        listContainer.innerHTML = matchesHTML;

        // Bind score button events
        listContainer.querySelectorAll('.score-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const matchId = e.target.closest('[data-match-id]').dataset.matchId;
                this.openScoreDialog(matchId);
            });
        });
    }

    updateCompletedMatches() {
        const listContainer = this.querySelector('#completed-matches-list');
        const emptyState = this.querySelector('#completed-empty-state');

        if (this.completedMatches.length === 0) {
            emptyState.style.display = 'flex';
            return;
        }

        emptyState.style.display = 'none';

        const matchesHTML = this.completedMatches.map(match => {
            const pair1Names = `${match.pair1.player1.name} / ${match.pair1.player2.name}`;
            const pair2Names = `${match.pair2.player1.name} / ${match.pair2.player2.name}`;
            const winnerNames = match.winner === 1 ? pair1Names : pair2Names;

            return `
                <div class="match-card completed" data-match-id="${match.id}">
                    <div class="match-info">
                        <div class="match-pairs">
                            <div class="pair ${match.winner === 1 ? 'winner' : 'loser'}">
                                <md-icon class="pair-icon">people</md-icon>
                                <span class="pair-names">${pair1Names}</span>
                                ${match.winner === 1 ? '<md-icon class="winner-icon">emoji_events</md-icon>' : ''}
                            </div>
                            <div class="vs-divider">
                                <md-icon>close</md-icon>
                            </div>
                            <div class="pair ${match.winner === 2 ? 'winner' : 'loser'}">
                                <md-icon class="pair-icon">people</md-icon>
                                <span class="pair-names">${pair2Names}</span>
                                ${match.winner === 2 ? '<md-icon class="winner-icon">emoji_events</md-icon>' : ''}
                            </div>
                        </div>
                        <div class="match-result">
                            <p class="winner-text">Winner: ${winnerNames}</p>
                            <p class="completed-time">${this.formatTime(match.completedAt)}</p>
                        </div>
                    </div>
                    <div class="match-actions">
                        <md-outlined-button class="reset-btn" data-match-id="${match.id}">
                            <md-icon slot="icon">undo</md-icon>
                            Reset
                        </md-outlined-button>
                        <md-text-button class="details-btn" data-match-id="${match.id}">
                            <md-icon slot="icon">info</md-icon>
                            Details
                        </md-text-button>
                    </div>
                </div>
            `;
        }).join('');

        listContainer.innerHTML = matchesHTML;

        // Bind reset button events
        listContainer.querySelectorAll('.reset-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const matchId = e.target.closest('[data-match-id]').dataset.matchId;
                this.resetMatch(matchId);
            });
        });

        // Bind details button events
        listContainer.querySelectorAll('.details-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const matchId = e.target.closest('[data-match-id]').dataset.matchId;
                this.showMatchDetails(matchId);
            });
        });
    }

    /**
     * Helper method to properly open Material 3 dialogs
     * @param {HTMLElement} dialog - The md-dialog element to open
     * @returns {Promise<boolean>} - True if dialog opened successfully
     */
    async openMaterialDialog(dialog) {
        if (!dialog) {
            console.error('Dialog element is null');
            return false;
        }

        try {
            console.log('Opening Material dialog:', dialog.id);
            
            // Wait for md-dialog to be defined if not already
            if (!customElements.get('md-dialog')) {
                console.log('Waiting for md-dialog to be defined...');
                await customElements.whenDefined('md-dialog');
            }
            
            // Give the element a chance to upgrade
            await new Promise(resolve => setTimeout(resolve, 0));
            
            console.log('Dialog methods:', {
                hasShow: typeof dialog.show,
                hasOpen: typeof dialog.open,
                constructor: dialog.constructor.name
            });
            
            // Try to open the dialog
            if (typeof dialog.show === 'function') {
                console.log('✅ Opening with show() method');
                dialog.show();
                return true;
            } else {
                console.warn('⚠️ show() not available, using fallback');
                dialog.open = true;
                dialog.setAttribute('open', 'true');
                return true;
            }
        } catch (error) {
            console.error('Error opening dialog:', error);
            return false;
        }
    }

    async openScoreDialog(matchId) {
        try {
            console.log('Opening score dialog for match:', matchId);
            console.log('Pending matches:', this.pendingMatches);
            
            const match = this.pendingMatches.find(m => m.id === matchId);
            if (!match) {
                console.error('Match not found:', matchId);
                this.showError('Match not found');
                return;
            }

            console.log('Match found:', match);
            this.selectedMatch = match;

            // Check if match has enriched player data
            if (!match.pair1 || !match.pair1.player1 || !match.pair1.player2) {
                console.error('Match missing player data:', match);
                this.showError('Match data is incomplete. Try refreshing the page.');
                return;
            }

            const pair1Names = `${match.pair1.player1.name} / ${match.pair1.player2.name}`;
            const pair2Names = `${match.pair2.player1.name} / ${match.pair2.player2.name}`;

            const pair1NamesEl = this.querySelector('#pair1-names');
            const pair2NamesEl = this.querySelector('#pair2-names');
            
            if (pair1NamesEl) pair1NamesEl.textContent = pair1Names;
            if (pair2NamesEl) pair2NamesEl.textContent = pair2Names;

            const dialog = this.querySelector('#score-dialog');
            if (!dialog) {
                console.error('Score dialog not found');
                this.showError('Score dialog not found');
                return;
            }
            
            // Open dialog using helper method
            const opened = await this.openMaterialDialog(dialog);
            if (!opened) {
                this.showError('Failed to open score dialog');
            }
            
        } catch (error) {
            console.error('Error opening score dialog:', error);
            this.showError(`Failed to open scoring: ${error.message}`);
        }
    }

    showConfirmDialog(winningPair) {
        if (!this.selectedMatch) return;

        const pair1Names = `${this.selectedMatch.pair1.player1.name} / ${this.selectedMatch.pair1.player2.name}`;
        const pair2Names = `${this.selectedMatch.pair2.player1.name} / ${this.selectedMatch.pair2.player2.name}`;

        const winnerNames = winningPair === 1 ? pair1Names : pair2Names;
        const loserNames = winningPair === 1 ? pair2Names : pair1Names;

        this.querySelector('#winner-summary').textContent = winnerNames;
        this.querySelector('#loser-summary').textContent = loserNames;

        this.selectedWinningPair = winningPair;

        this.querySelector('#score-dialog').close();
        this.querySelector('#confirm-score-dialog').show();
    }

    recordMatchResult() {
        if (!this.selectedMatch || !this.selectedWinningPair) return;

        try {
            this.tournamentService.recordMatchResult(this.selectedMatch.id, this.selectedWinningPair);
            
            this.querySelector('#confirm-score-dialog').close();
            this.selectedMatch = null;
            this.selectedWinningPair = null;
            
            this.loadData();
            this.showSuccess('Match result recorded successfully');
        } catch (error) {
            this.showError(`Failed to record result: ${error.message}`);
        }
    }

    resetMatch(matchId) {
        if (!confirm('Are you sure you want to reset this match? This will remove the result and move it back to pending matches.')) {
            return;
        }

        try {
            this.tournamentService.resetMatch(matchId);
            this.loadData();
            this.showSuccess('Match reset successfully');
        } catch (error) {
            this.showError(`Failed to reset match: ${error.message}`);
        }
    }

    showMatchDetails(matchId) {
        const match = this.completedMatches.find(m => m.id === matchId);
        if (!match) return;

        const pair1Names = `${match.pair1.player1.name} / ${match.pair1.player2.name}`;
        const pair2Names = `${match.pair2.player1.name} / ${match.pair2.player2.name}`;
        const winnerNames = match.winningPair === 1 ? pair1Names : pair2Names;

        const content = `
            <div class="match-detail-content">
                <div class="detail-section">
                    <h3 class="title-medium">Match Participants</h3>
                    <div class="participants">
                        <div class="participant-pair ${match.winningPair === 1 ? 'winner' : ''}">
                            <md-icon class="pair-icon">people</md-icon>
                            <span>${pair1Names}</span>
                            ${match.winningPair === 1 ? '<md-icon class="winner-badge">emoji_events</md-icon>' : ''}
                        </div>
                        <div class="participant-pair ${match.winningPair === 2 ? 'winner' : ''}">
                            <md-icon class="pair-icon">people</md-icon>
                            <span>${pair2Names}</span>
                            ${match.winningPair === 2 ? '<md-icon class="winner-badge">emoji_events</md-icon>' : ''}
                        </div>
                    </div>
                </div>
                
                <div class="detail-section">
                    <h3 class="title-medium">Match Result</h3>
                    <p><strong>Winner:</strong> ${winnerNames}</p>
                    <p><strong>Completed:</strong> ${this.formatTime(match.completedAt)}</p>
                </div>
                
                <div class="detail-section">
                    <h3 class="title-medium">Points Awarded</h3>
                    <p>Winner: <strong>+2 points</strong></p>
                    <p>Loser: <strong>+1 point</strong></p>
                </div>
            </div>
        `;

        this.querySelector('#match-details-title').textContent = `Match Details`;
        this.querySelector('#match-details-content').innerHTML = content;
        this.querySelector('#match-details-dialog').show();
    }

    toggleCompletedMatches() {
        const listContainer = this.querySelector('#completed-matches-list');
        const button = this.querySelector('#expand-completed-btn');
        const icon = button.querySelector('md-icon');

        if (listContainer.classList.contains('collapsed')) {
            listContainer.classList.remove('collapsed');
            icon.textContent = 'unfold_less';
            button.innerHTML = '<md-icon slot="icon">unfold_less</md-icon>Hide All';
        } else {
            listContainer.classList.add('collapsed');
            icon.textContent = 'unfold_more';
            button.innerHTML = '<md-icon slot="icon">unfold_more</md-icon>Show All';
        }
    }

    formatTime(timestamp) {
        if (!timestamp) return 'Unknown time';
        
        const date = new Date(timestamp);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);

        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`;
        
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

customElements.define('scoring-page', ScoringPage);