// Players Management Page - Material 3 Web Component
export class PlayersPage extends HTMLElement {
    constructor() {
        super();
        this.tournamentService = null;
        this.players = [];
        this.editingPlayer = null;
    }

    connectedCallback() {
        this.render();
        this.bindEvents();
        
        // Ensure DOM is ready before loading players
        setTimeout(() => {
            this.loadPlayers();
        }, 50);
    }

    setTournamentService(service) {
        this.tournamentService = service;
        // Force a refresh when tournament service is set
        if (this.isConnected) {
            setTimeout(() => {
                this.loadPlayers();
            }, 10);
        }
    }

    loadPlayers() {
        if (!this.tournamentService) return;
        
        this.players = this.tournamentService.getPlayers();
        this.updatePlayersList();
        this.updateStats();
    }

    render() {
        this.innerHTML = `
            <div class="players-page">
                <div class="page-header">
                    <h1 class="headline-large">Players Management</h1>
                    <div class="stats-chips">
                        <md-filter-chip id="total-players-chip" label="0 players"></md-filter-chip>
                        <md-filter-chip id="tournament-status-chip" label="Setup"></md-filter-chip>
                    </div>
                </div>

                <div class="add-player-section">
                    <div class="add-player-form">
                        <md-outlined-text-field 
                            id="player-name-input"
                            label="Player name"
                            supporting-text="Enter player's full name"
                            maxlength="50">
                        </md-outlined-text-field>
                        <md-filled-button id="add-player-btn">
                            <md-icon slot="icon">person_add</md-icon>
                            Add Player
                        </md-filled-button>
                    </div>
                </div>

                <div class="players-list-section">
                    <div class="section-header">
                        <h2 class="title-large">Tournament Players</h2>
                        <div class="list-actions">
                            <md-text-button id="clear-all-btn">
                                <md-icon slot="icon">clear_all</md-icon>
                                Clear All
                            </md-text-button>
                        </div>
                    </div>
                    
                    <div id="players-list" class="players-list">
                        <div class="empty-state" id="empty-state">
                            <md-icon class="empty-icon">people_outline</md-icon>
                            <p class="body-large">No players added yet</p>
                            <p class="body-medium">Add players to start your tournament</p>
                        </div>
                    </div>
                </div>

                <!-- Edit Player Dialog -->
                <md-dialog id="edit-player-dialog">
                    <div slot="headline">Edit Player</div>
                    <form slot="content" id="edit-player-form">
                        <md-outlined-text-field 
                            id="edit-player-name"
                            label="Player name"
                            required>
                        </md-outlined-text-field>
                    </form>
                    <div slot="actions">
                        <md-text-button form="edit-player-form" id="cancel-edit-btn">Cancel</md-text-button>
                        <md-filled-button form="edit-player-form" id="save-edit-btn">Save</md-filled-button>
                    </div>
                </md-dialog>

                <!-- Confirm Delete Dialog -->
                <md-dialog id="delete-player-dialog">
                    <div slot="headline">Delete Player</div>
                    <div slot="content">
                        <p>Are you sure you want to remove <strong id="delete-player-name"></strong> from the tournament?</p>
                        <p class="body-small">This action cannot be undone.</p>
                    </div>
                    <div slot="actions">
                        <md-text-button id="cancel-delete-btn">Cancel</md-text-button>
                        <md-filled-button id="confirm-delete-btn">Delete</md-filled-button>
                    </div>
                </md-dialog>
            </div>
        `;
    }

    bindEvents() {
        // Add player form
        const nameInput = this.querySelector('#player-name-input');
        const addBtn = this.querySelector('#add-player-btn');
        
        addBtn.addEventListener('click', () => this.addPlayer());
        nameInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                this.addPlayer();
            }
        });

        // Clear all players
        this.querySelector('#clear-all-btn').addEventListener('click', () => {
            this.clearAllPlayers();
        });

        // Edit player dialog
        const editDialog = this.querySelector('#edit-player-dialog');
        const editForm = this.querySelector('#edit-player-form');
        
        this.querySelector('#cancel-edit-btn').addEventListener('click', () => {
            this.closeDialog(editDialog);
        });
        
        this.querySelector('#save-edit-btn').addEventListener('click', () => {
            this.savePlayerEdit();
        });

        editForm.addEventListener('submit', (e) => {
            e.preventDefault();
            this.savePlayerEdit();
        });

        // Delete player dialog
        const deleteDialog = this.querySelector('#delete-player-dialog');
        
        this.querySelector('#cancel-delete-btn').addEventListener('click', () => {
            this.closeDialog(deleteDialog);
        });
        
        this.querySelector('#confirm-delete-btn').addEventListener('click', () => {
            this.confirmDeletePlayer();
        });
    }

    // Helper method to close all dialogs in this page
    closeAllDialogs() {
        const dialogs = this.querySelectorAll('md-dialog');
        dialogs.forEach(dialog => this.closeDialog(dialog));
    }

    // Helper method to close dialogs (works with both Material 3 and fallback)
    closeDialog(dialog) {
        if (dialog) {
            console.log('🔧 Closing dialog:', dialog.id);
            if (typeof dialog.close === 'function') {
                dialog.close();
            } else {
                // Fallback: hide the dialog
                dialog.style.display = 'none';
                dialog.removeAttribute('open');
            }
        }
    }

    // Helper method to show dialogs (works with both Material 3 and fallback)  
    async openDialog(dialog) {
        if (dialog) {
            console.log('🔧 Opening dialog:', dialog.id);
            
            // Close all other dialogs first
            this.closeAllDialogs();
            
            // Small delay to ensure other dialogs are closed
            await new Promise(resolve => setTimeout(resolve, 10));
            
            if (typeof dialog.show === 'function') {
                dialog.show();
            } else if (typeof dialog.showModal === 'function') {
                dialog.showModal();
            } else {
                // Fallback: show the dialog
                dialog.style.display = 'flex';
                dialog.setAttribute('open', '');
            }
        }
    }

    async addPlayer() {
        const nameInput = this.querySelector('#player-name-input');
        console.log('🔍 Name input element:', nameInput);
        
        if (!nameInput) {
            console.error('❌ Player name input not found');
            this.showError('Input field not found. Please try refreshing the page.');
            return;
        }
        
        // Material 3 text fields use different properties to get value
        let inputValue;
        
        // Wait for the component to be fully defined if it's still initializing
        if (nameInput.tagName.toLowerCase() === 'md-outlined-text-field') {
            await customElements.whenDefined('md-outlined-text-field').catch(() => {
                console.warn('Material 3 text field not fully loaded, trying anyway...');
            });
        }
        
        // Try multiple ways to get the value from Material 3 text field
        if (nameInput.value !== undefined && nameInput.value !== null) {
            inputValue = nameInput.value;
            console.log('✅ Got value from .value property:', inputValue);
        } else if (nameInput.getAttribute && nameInput.getAttribute('value')) {
            inputValue = nameInput.getAttribute('value');
            console.log('✅ Got value from value attribute:', inputValue);
        } else {
            // Try to find the internal input element (Material 3 components often have nested inputs)
            const internalInput = nameInput.querySelector('input');
            if (internalInput && internalInput.value !== undefined) {
                inputValue = internalInput.value;
                console.log('✅ Got value from internal input element:', inputValue);
            } else {
                // Final fallback - check for any input-like elements
                const inputElements = nameInput.querySelectorAll('input, textarea');
                if (inputElements.length > 0) {
                    inputValue = inputElements[0].value;
                    console.log('✅ Got value from nested input element:', inputValue);
                } else {
                    console.error('❌ Could not get value from Material 3 text field');
                    console.log('🔍 Element tagName:', nameInput.tagName);
                    console.log('🔍 Element innerHTML:', nameInput.innerHTML);
                    console.log('🔍 Available properties:', Object.getOwnPropertyNames(nameInput));
                    this.showError('Please enter a player name in the text field');
                    nameInput.focus();
                    return;
                }
            }
        }
        
        console.log('🔍 Final input value:', inputValue);
        
        if (inputValue === undefined || inputValue === null || inputValue === '') {
            console.error('❌ Input value is empty or invalid');
            this.showError('Please enter a player name');
            nameInput.focus();
            return;
        }
        
        const name = inputValue.trim();

        if (!name) {
            this.showError('Please enter a player name');
            nameInput.focus();
            return;
        }

        // Check for duplicate names
        if (this.players.some(p => p.name.toLowerCase() === name.toLowerCase())) {
            this.showError('Player with this name already exists');
            nameInput.focus();
            return;
        }

        try {
            const player = this.tournamentService.addPlayer(name);
            nameInput.value = '';
            this.loadPlayers();
            this.showSuccess(`Added ${player.name} to tournament`);
        } catch (error) {
            this.showError(`Failed to add player: ${error.message}`);
        }
    }

    async editPlayer(playerId) {
        const player = this.players.find(p => p.id === playerId);
        if (!player) return;

        this.editingPlayer = player;
        const dialog = this.querySelector('#edit-player-dialog');
        const nameInput = this.querySelector('#edit-player-name');
        
        nameInput.value = player.name;
        await this.openDialog(dialog);
        
        // Focus and select name for easy editing
        setTimeout(() => {
            nameInput.focus();
            nameInput.select();
        }, 100);
    }

    savePlayerEdit() {
        if (!this.editingPlayer) return;

        const nameInput = this.querySelector('#edit-player-name');
        const newName = nameInput.value.trim();

        if (!newName) {
            this.showError('Please enter a player name');
            return;
        }

        // Check for duplicate names (excluding current player)
        if (this.players.some(p => p.id !== this.editingPlayer.id && 
                            p.name.toLowerCase() === newName.toLowerCase())) {
            this.showError('Player with this name already exists');
            return;
        }

        try {
            this.tournamentService.updatePlayer(this.editingPlayer.id, newName);
            this.querySelector('#edit-player-dialog').close();
            this.editingPlayer = null;
            this.loadPlayers();
            this.showSuccess(`Updated player name to ${newName}`);
        } catch (error) {
            this.showError(`Failed to update player: ${error.message}`);
        }
    }

    async deletePlayer(playerId) {
        const player = this.players.find(p => p.id === playerId);
        if (!player) return;

        this.playerToDelete = player;
        const dialog = this.querySelector('#delete-player-dialog');
        const nameSpan = this.querySelector('#delete-player-name');
        
        nameSpan.textContent = player.name;
        await this.openDialog(dialog);
    }

    confirmDeletePlayer() {
        if (!this.playerToDelete) return;

        try {
            this.tournamentService.removePlayer(this.playerToDelete.id);
            this.closeDialog(this.querySelector('#delete-player-dialog'));
            this.playerToDelete = null;
            this.loadPlayers();
            this.showSuccess('Player removed from tournament');
        } catch (error) {
            this.showError(`Failed to remove player: ${error.message}`);
        }
    }

    clearAllPlayers() {
        if (this.players.length === 0) return;

        const confirmed = confirm(`Remove all ${this.players.length} players from the tournament?`);
        if (!confirmed) return;

        try {
            // Remove players one by one (tournament service doesn't have bulk delete)
            const playerIds = [...this.players.map(p => p.id)];
            playerIds.forEach(id => {
                this.tournamentService.removePlayer(id);
            });
            
            this.loadPlayers();
            this.showSuccess('All players removed from tournament');
        } catch (error) {
            this.showError(`Failed to clear players: ${error.message}`);
        }
    }

    updatePlayersList() {
        const listContainer = this.querySelector('#players-list');
        const emptyState = this.querySelector('#empty-state');

        console.log('🔍 Updating players list, player count:', this.players.length);
        console.log('🔍 Players data:', this.players);

        // Check if elements exist before accessing them
        if (!listContainer || !emptyState) {
            console.warn('Players list elements not found, DOM may not be ready. Retrying...');
            // Retry up to 5 times with increasing delays
            if (!this.retryCount) this.retryCount = 0;
            
            if (this.retryCount < 5) {
                this.retryCount++;
                setTimeout(() => {
                    this.updatePlayersList();
                }, 100 * this.retryCount);
            } else {
                console.error('❌ Failed to find players list elements after 5 retries');
            }
            return;
        }
        
        // Reset retry count on success
        this.retryCount = 0;

        if (this.players.length === 0) {
            emptyState.style.display = 'flex';
            return;
        }

        emptyState.style.display = 'none';

        // Create player cards
        const playersHTML = this.players.map(player => `
            <div class="player-card" data-player-id="${player.id}">
                <div class="player-info">
                    <md-icon class="player-avatar">person</md-icon>
                    <div class="player-details">
                        <h3 class="title-medium">${this.escapeHtml(player.name)}</h3>
                        <p class="body-medium">Score: ${player.score} points</p>
                        <p class="body-small">Matches: ${player.matchesPlayed} played, ${player.matchesWon} won</p>
                    </div>
                </div>
                <div class="player-actions">
                    <md-icon-button class="edit-player-btn" data-player-id="${player.id}">
                        <md-icon>edit</md-icon>
                    </md-icon-button>
                    <md-icon-button class="delete-player-btn" data-player-id="${player.id}">
                        <md-icon>delete</md-icon>
                    </md-icon-button>
                </div>
            </div>
        `).join('');

        listContainer.innerHTML = playersHTML;

        // Bind player action events
        listContainer.querySelectorAll('.edit-player-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const playerId = e.target.closest('[data-player-id]').dataset.playerId;
                this.editPlayer(playerId);
            });
        });

        listContainer.querySelectorAll('.delete-player-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const playerId = e.target.closest('[data-player-id]').dataset.playerId;
                this.deletePlayer(playerId);
            });
        });
    }

    updateStats() {
        const totalChip = this.querySelector('#total-players-chip');
        const statusChip = this.querySelector('#tournament-status-chip');

        // Check if elements exist before accessing them
        if (!totalChip || !statusChip) {
            console.warn('Stats elements not found, DOM may not be ready');
            return;
        }

        totalChip.label = `${this.players.length} player${this.players.length !== 1 ? 's' : ''}`;
        
        if (this.tournamentService) {
            const status = this.tournamentService.getTournamentStatus();
            statusChip.label = status.charAt(0).toUpperCase() + status.slice(1);
        }
    }

    showSuccess(message) {
        // Create simple toast notification
        const toast = document.createElement('div');
        toast.className = 'toast success';
        toast.innerHTML = `
            <md-icon>check_circle</md-icon>
            <span>${this.escapeHtml(message)}</span>
        `;
        
        document.body.appendChild(toast);
        
        // Animate in
        setTimeout(() => toast.classList.add('show'), 100);
        
        // Remove after 3 seconds
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, 3000);
    }

    showError(message) {
        // Create simple toast notification
        const toast = document.createElement('div');
        toast.className = 'toast error';
        toast.innerHTML = `
            <md-icon>error</md-icon>
            <span>${this.escapeHtml(message)}</span>
        `;
        
        document.body.appendChild(toast);
        
        // Animate in
        setTimeout(() => toast.classList.add('show'), 100);
        
        // Remove after 4 seconds (errors stay longer)
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

customElements.define('players-page', PlayersPage);