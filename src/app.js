// Main App Shell - Material 3 Badminton Tournament Manager
import { TournamentService } from './services/tournament.js';
import { PlayersPage } from './pages/players/players-page.js';
import { RoundsPage } from './pages/rounds/rounds-page.js';
import { ScoringPage } from './pages/scoring/scoring-page.js';
import { RankingsPage } from './pages/rankings/rankings-page.js';

class BadmintonTournamentApp extends HTMLElement {
    constructor() {
        super();
        this.tournamentService = new TournamentService();
        this.currentPage = 'players';
        this.pages = {};
        this.isLoading = false;
    }

    async connectedCallback() {
        // Prevent multiple initialization if already rendered
        if (this.hasAttribute('initialized')) {
            return;
        }
        
        await this.render();
        this.initializeApp();
        this.bindEvents();
        this.loadInitialData();
        
        // Mark as initialized to prevent duplicate calls
        this.setAttribute('initialized', 'true');
    }

    async render() {
        this.innerHTML = `
            <div class="app">
                <!-- App Header -->
                <header class="app-header">
                    <div class="header-content">
                        <div class="app-title">
                            <md-icon class="app-icon">sports_tennis</md-icon>
                            <h1 class="headline-medium">Badminton Tournament</h1>
                        </div>
                        <div class="header-actions">
                            <md-icon-button id="save-btn" title="Save Tournament">
                                <md-icon>save</md-icon>
                            </md-icon-button>
                            <md-icon-button id="settings-btn" title="Settings">
                                <md-icon>settings</md-icon>
                            </md-icon-button>
                        </div>
                    </div>
                </header>

                <!-- Navigation Tabs -->
                <nav class="app-navigation">
                    <md-tabs id="main-tabs">
                        <md-primary-tab id="players-tab" active>
                            <md-icon slot="icon">people</md-icon>
                            Players
                        </md-primary-tab>
                        <md-primary-tab id="rounds-tab">
                            <md-icon slot="icon">casino</md-icon>
                            Rounds
                        </md-primary-tab>
                        <md-primary-tab id="scoring-tab">
                            <md-icon slot="icon">sports_score</md-icon>
                            Scoring
                        </md-primary-tab>
                        <md-primary-tab id="rankings-tab">
                            <md-icon slot="icon">emoji_events</md-icon>
                            Rankings
                        </md-primary-tab>
                    </md-tabs>
                </nav>

                <!-- Main Content Area -->
                <main class="app-main" id="app-main">
                    <div class="loading-overlay" id="loading-overlay">
                        <md-circular-progress indeterminate></md-circular-progress>
                        <p class="loading-text">Loading tournament data...</p>
                    </div>
                    
                    <div class="page-container" id="page-container">
                        <!-- Pages will be rendered here -->
                    </div>
                </main>

                <!-- Settings Dialog -->
                <md-dialog id="settings-dialog">
                    <div slot="headline">Tournament Settings</div>
                    <form slot="content" id="settings-form">
                        <div class="settings-section">
                            <h3 class="title-medium">Scoring</h3>
                            <div class="setting-row">
                                <label class="body-large">Winner Points:</label>
                                <md-outlined-text-field 
                                    id="winner-points" 
                                    type="number" 
                                    min="1" 
                                    max="10" 
                                    value="2">
                                </md-outlined-text-field>
                            </div>
                            <div class="setting-row">
                                <label class="body-large">Loser Points:</label>
                                <md-outlined-text-field 
                                    id="loser-points" 
                                    type="number" 
                                    min="0" 
                                    max="9" 
                                    value="1">
                                </md-outlined-text-field>
                            </div>
                        </div>
                        
                        <div class="settings-section">
                            <h3 class="title-medium">Data Management</h3>
                            <div class="setting-row">
                                <md-outlined-button id="export-data-btn">
                                    <md-icon slot="icon">download</md-icon>
                                    Export Tournament
                                </md-outlined-button>
                                <md-outlined-button id="import-data-btn">
                                    <md-icon slot="icon">upload</md-icon>
                                    Import Tournament
                                </md-outlined-button>
                            </div>
                            <div class="setting-row">
                                <md-outlined-button id="create-backup-btn">
                                    <md-icon slot="icon">backup</md-icon>
                                    Create Backup
                                </md-outlined-button>
                                <md-outlined-button id="view-backups-btn">
                                    <md-icon slot="icon">restore</md-icon>
                                    View Backups
                                </md-outlined-button>
                            </div>
                        </div>
                        
                        <div class="settings-section">
                            <h3 class="title-medium">Tournament Actions</h3>
                            <div class="setting-row">
                                <md-outlined-button id="reset-tournament-btn">
                                    <md-icon slot="icon">refresh</md-icon>
                                    Reset Tournament
                                </md-outlined-button>
                                <md-outlined-button id="new-tournament-btn">
                                    <md-icon slot="icon">add</md-icon>
                                    New Tournament
                                </md-outlined-button>
                            </div>
                        </div>
                    </form>
                    <div slot="actions">
                        <md-text-button id="cancel-settings-btn">Cancel</md-text-button>
                        <md-filled-button id="save-settings-btn">Save Settings</md-filled-button>
                    </div>
                </md-dialog>

                <!-- Import File Input (Hidden) -->
                <input type="file" id="import-file-input" accept=".json" style="display: none;">

                <!-- Status Bar -->
                <footer class="app-status-bar" id="status-bar">
                    <div class="status-info">
                        <span id="tournament-status">Tournament: Setup</span>
                        <span class="status-separator">•</span>
                        <span id="auto-save-status">Auto-save: On</span>
                    </div>
                    <div class="status-actions">
                        <span id="last-saved">Never saved</span>
                    </div>
                </footer>
            </div>
        `;
        
        // Ensure Material 3 components are properly initialized
        await this.initializeMaterial3Components();
    }
    
    async initializeMaterial3Components() {
        console.log('🔄 Initializing Material 3 components...');
        
        // Wait for Material 3 components to be defined and upgrade
        const materialComponents = [
            'md-icon',
            'md-icon-button', 
            'md-tabs',
            'md-primary-tab',
            'md-circular-progress',
            'md-dialog',
            'md-outlined-text-field',
            'md-filled-button',
            'md-text-button',
            'md-outlined-button',
            'md-fab',
            'md-card',
            'md-list',
            'md-list-item',
            'md-checkbox',
            'md-switch',
            'md-slider',
            'md-select',
            'md-option'
        ];
        
        // Wait for all components to be defined (with timeout per component)
        const componentPromises = materialComponents.map(component => 
            Promise.race([
                customElements.whenDefined(component),
                new Promise(resolve => setTimeout(resolve, 2000)) // 2s timeout per component
            ]).catch(() => {
                console.warn(`⚠️ Component ${component} not available`);
            })
        );
        
        await Promise.all(componentPromises);
        console.log('✓ Material 3 component definitions loaded');
        
        // Query all Material 3 elements more comprehensively
        const mdSelectors = materialComponents.join(',');
        const mdElements = this.querySelectorAll(mdSelectors);
        console.log(`✓ Found ${mdElements.length} Material 3 elements to upgrade`);
        
        // Force upgrade of all Material 3 elements in this component
        const upgradePromises = Array.from(mdElements).map(async element => {
            if (element.tagName.toLowerCase().startsWith('md-')) {
                try {
                    // Wait for element's updateComplete if it's a lit-element
                    if (typeof element.updateComplete !== 'undefined') {
                        await Promise.race([
                            element.updateComplete,
                            new Promise(resolve => setTimeout(resolve, 1000))
                        ]);
                    }
                } catch (error) {
                    // Ignore individual element upgrade errors
                }
            }
        });
        
        await Promise.all(upgradePromises);
        
        // Additional delay to ensure rendering is complete
        await new Promise(resolve => setTimeout(resolve, 200));
        console.log('✓ Material 3 components fully initialized');
    }

    initializeApp() {
        // Initialize pages
        this.pages = {
            players: new PlayersPage(),
            rounds: new RoundsPage(),
            scoring: new ScoringPage(),
            rankings: new RankingsPage()
        };

        // Set tournament service for all pages
        Object.values(this.pages).forEach(page => {
            page.setTournamentService(this.tournamentService);
        });

        // Show initial page
        this.showPage('players');
    }

    bindEvents() {
        // Tab navigation
        const tabs = this.querySelector('#main-tabs');
        tabs.addEventListener('change', (e) => {
            const activeTab = e.target.activeTab;
            const pageMap = {
                0: 'players',
                1: 'rounds', 
                2: 'scoring',
                3: 'rankings'
            };
            
            const targetPage = pageMap[activeTab];
            if (targetPage) {
                this.navigateToPage(targetPage);
            }
        });

        // Header actions
        this.querySelector('#save-btn').addEventListener('click', () => {
            this.saveTournament();
        });

        this.querySelector('#settings-btn').addEventListener('click', () => {
            this.openSettings();
        });

        // Settings dialog
        this.querySelector('#cancel-settings-btn').addEventListener('click', () => {
            this.querySelector('#settings-dialog').close();
        });

        this.querySelector('#save-settings-btn').addEventListener('click', () => {
            this.saveSettings();
        });

        // Data management buttons
        this.querySelector('#export-data-btn').addEventListener('click', () => {
            this.exportTournament();
        });

        this.querySelector('#import-data-btn').addEventListener('click', () => {
            this.querySelector('#import-file-input').click();
        });

        this.querySelector('#import-file-input').addEventListener('change', (e) => {
            this.importTournament(e.target.files[0]);
        });

        this.querySelector('#create-backup-btn').addEventListener('click', () => {
            this.createBackup();
        });

        this.querySelector('#view-backups-btn').addEventListener('click', () => {
            this.viewBackups();
        });

        // Tournament actions
        this.querySelector('#reset-tournament-btn').addEventListener('click', () => {
            this.resetTournament();
        });

        this.querySelector('#new-tournament-btn').addEventListener('click', () => {
            this.createNewTournament();
        });

        // Listen for page navigation events
        this.addEventListener('navigate', (e) => {
            this.navigateToPage(e.detail.page);
        });

        // Auto-save interval
        setInterval(() => {
            this.autoSave();
        }, 30000); // Auto-save every 30 seconds

        // Update status bar periodically
        setInterval(() => {
            this.updateStatusBar();
        }, 5000);
    }

    async loadInitialData() {
        this.showLoading(true);
        
        try {
            // Small delay to ensure DOM is fully ready
            await new Promise(resolve => setTimeout(resolve, 100));
            
            // Try to load existing tournament
            const existingTournament = this.tournamentService.loadTournament();
            
            if (!existingTournament) {
                // Create new tournament if none exists
                this.tournamentService.createTournament('My Badminton Tournament');
            }
            
            // Refresh all pages with loaded data
            this.refreshAllPages();
            this.updateStatusBar();
            
        } catch (error) {
            console.error('Failed to load initial data:', error);
            this.showError('Failed to load tournament data');
        } finally {
            this.showLoading(false);
        }
    }

    showPage(pageId) {
        const container = this.querySelector('#page-container');
        const page = this.pages[pageId];
        
        if (!page) return;

        // Clear container and add new page
        container.innerHTML = '';
        container.appendChild(page);
        
        this.currentPage = pageId;
        
        // Update page data
        page.setTournamentService(this.tournamentService);
    }

    navigateToPage(pageId) {
        if (pageId === this.currentPage) return;
        
        // Update tab selection
        const tabMap = {
            'players': 0,
            'rounds': 1,
            'scoring': 2,
            'rankings': 3
        };
        
        const tabIndex = tabMap[pageId];
        if (tabIndex !== undefined) {
            const tabs = this.querySelector('#main-tabs');
            tabs.activeTabIndex = tabIndex;
        }
        
        this.showPage(pageId);
    }

    refreshAllPages() {
        Object.values(this.pages).forEach(page => {
            if (page.loadData && page.isConnected) {
                try {
                    page.loadData();
                } catch (error) {
                    console.warn(`Failed to load data for page:`, error);
                }
            }
        });
    }

    showLoading(show) {
        const overlay = this.querySelector('#loading-overlay');
        overlay.style.display = show ? 'flex' : 'none';
        this.isLoading = show;
    }

    saveTournament() {
        try {
            this.tournamentService.saveTournament();
            this.showSuccess('Tournament saved successfully');
            this.updateStatusBar();
        } catch (error) {
            this.showError(`Failed to save tournament: ${error.message}`);
        }
    }

    autoSave() {
        if (this.isLoading) return;
        
        try {
            this.tournamentService.autoSave();
            this.updateStatusBar();
        } catch (error) {
            console.warn('Auto-save failed:', error.message);
        }
    }

    openSettings() {
        const dialog = this.querySelector('#settings-dialog');
        const settings = this.tournamentService.getSettings();
        
        // Populate current settings
        this.querySelector('#winner-points').value = settings.winnerPoints;
        this.querySelector('#loser-points').value = settings.loserPoints;
        
        dialog.show();
    }

    saveSettings() {
        try {
            const winnerPoints = parseInt(this.querySelector('#winner-points').value);
            const loserPoints = parseInt(this.querySelector('#loser-points').value);
            
            if (winnerPoints <= loserPoints) {
                this.showError('Winner points must be greater than loser points');
                return;
            }
            
            this.tournamentService.updateSettings({
                winnerPoints,
                loserPoints
            });
            
            this.querySelector('#settings-dialog').close();
            this.showSuccess('Settings updated successfully');
            this.refreshAllPages();
        } catch (error) {
            this.showError(`Failed to save settings: ${error.message}`);
        }
    }

    exportTournament() {
        try {
            const jsonData = this.tournamentService.exportTournament();
            const blob = new Blob([jsonData], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            a.download = `badminton-tournament-${new Date().toISOString().split('T')[0]}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            
            URL.revokeObjectURL(url);
            this.showSuccess('Tournament exported successfully');
        } catch (error) {
            this.showError(`Export failed: ${error.message}`);
        }
    }

    importTournament(file) {
        if (!file) return;
        
        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const tournament = this.tournamentService.importTournament(e.target.result);
                this.refreshAllPages();
                this.updateStatusBar();
                this.showSuccess(`Imported tournament: ${tournament.name}`);
            } catch (error) {
                this.showError(`Import failed: ${error.message}`);
            }
        };
        reader.readAsText(file);
    }

    createBackup() {
        try {
            const backupKey = this.tournamentService.createBackup();
            this.showSuccess(`Backup created: ${backupKey}`);
        } catch (error) {
            this.showError(`Backup failed: ${error.message}`);
        }
    }

    viewBackups() {
        try {
            const backups = this.tournamentService.listBackups();
            if (backups.length === 0) {
                this.showInfo('No backups available');
                return;
            }
            
            // Simple backup list (could be enhanced with a proper dialog)
            const backupList = backups.map(backup => 
                `${backup.name} (${new Date(backup.timestamp).toLocaleString()})`
            ).join('\n');
            
            alert(`Available backups:\n\n${backupList}`);
        } catch (error) {
            this.showError(`Failed to list backups: ${error.message}`);
        }
    }

    resetTournament() {
        const confirmed = confirm('Reset tournament? This will clear all scores but keep players.');
        if (!confirmed) return;
        
        try {
            this.tournamentService.resetTournament();
            this.refreshAllPages();
            this.updateStatusBar();
            this.showSuccess('Tournament reset successfully');
        } catch (error) {
            this.showError(`Reset failed: ${error.message}`);
        }
    }

    createNewTournament() {
        const confirmed = confirm('Create new tournament? This will clear all current data.');
        if (!confirmed) return;
        
        try {
            this.tournamentService.createTournament('New Badminton Tournament');
            this.refreshAllPages();
            this.updateStatusBar();
            this.navigateToPage('players');
            this.showSuccess('New tournament created');
        } catch (error) {
            this.showError(`Failed to create tournament: ${error.message}`);
        }
    }

    updateStatusBar() {
        const statusElement = this.querySelector('#tournament-status');
        const autoSaveElement = this.querySelector('#auto-save-status');
        const lastSavedElement = this.querySelector('#last-saved');
        
        const tournament = this.tournamentService.getCurrentTournament();
        if (tournament) {
            statusElement.textContent = `Tournament: ${tournament.status}`;
        }
        
        autoSaveElement.textContent = `Auto-save: ${this.tournamentService.autoSaveEnabled ? 'On' : 'Off'}`;
        
        // Update last saved time (simplified)
        const now = new Date();
        lastSavedElement.textContent = `Last saved: ${now.toLocaleTimeString()}`;
    }

    showSuccess(message) {
        this.showToast(message, 'success');
    }

    showError(message) {
        this.showToast(message, 'error');
    }

    showInfo(message) {
        this.showToast(message, 'info');
    }

    showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icons = {
            success: 'check_circle',
            error: 'error',
            info: 'info'
        };
        
        toast.innerHTML = `
            <md-icon>${icons[type]}</md-icon>
            <span>${this.escapeHtml(message)}</span>
        `;
        
        document.body.appendChild(toast);
        
        setTimeout(() => toast.classList.add('show'), 100);
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, type === 'error' ? 4000 : 3000);
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Register the custom element
customElements.define('badminton-tournament-app', BadmintonTournamentApp);

// Export the class for use in other modules
export { BadmintonTournamentApp };