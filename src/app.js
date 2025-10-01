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
        console.log('🎬 BadmintonTournamentApp connectedCallback called');
        
        // Prevent multiple initialization if already rendered
        if (this.hasAttribute('initialized')) {
            console.log('⚠️ Already initialized, skipping');
            return;
        }
        
        console.log('🔄 Starting app initialization...');
        await this.render();
        console.log('✅ Render complete');
        
        this.initializeApp();
        console.log('✅ App initialization complete');
        
        this.bindEvents();
        console.log('✅ Event binding complete');
        
        this.loadInitialData();
        console.log('✅ Initial data loaded');
        
        // Mark as initialized to prevent duplicate calls
        this.setAttribute('initialized', 'true');
        console.log('🎉 BadmintonTournamentApp fully initialized');
    }

    async render() {
        this.innerHTML = `
            <div class="app">
                <!-- App Header -->
                <header class="app-header">
                    <div class="header-content">
                        <div class="app-title">
                            <md-icon class="app-icon">sports_tennis</md-icon>
                            <h1 class="headline-medium">Badminton Tournament <span style="font-size: 0.6em; color: var(--md-sys-color-primary);">v2.0.2-FIXED</span></h1>
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
                            <h3 class="title-medium">Tournament Mode</h3>
                            <div class="setting-row">
                                <label class="body-large">Game Format:</label>
                                <div class="radio-group">
                                    <label class="radio-label">
                                        <input type="radio" name="tournament-mode" value="singles" id="mode-singles" checked>
                                        <span>Singles (1 vs 1)</span>
                                    </label>
                                    <label class="radio-label">
                                        <input type="radio" name="tournament-mode" value="doubles" id="mode-doubles">
                                        <span>Doubles (2 vs 2) - Partners rotate each round</span>
                                    </label>
                                </div>
                            </div>
                            <div class="setting-info">
                                <md-icon>info</md-icon>
                                <span class="body-small">
                                    In doubles mode, each player will have a different partner every round.
                                    Make sure you have an even number of players (minimum 4).
                                </span>
                            </div>
                        </div>
                        
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
                        <span class="status-separator">•</span>
                        <span class="version-info">v2.0 - Scoring & Doubles Mode</span>
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

    /**
     * Helper method to properly open Material 3 dialogs
     * @param {HTMLElement} dialog - The md-dialog element to open
     * @returns {Promise<boolean>} - True if dialog opened successfully
     */
    async openMaterialDialog(dialog) {
        console.log('🔧 openMaterialDialog called with:', dialog);
        if (!dialog) {
            console.error('❌ Dialog element is null');
            return false;
        }

        try {
            console.log('🎯 Opening Material dialog:', dialog.id, dialog.tagName);
            
            // Wait for md-dialog to be defined if not already
            if (!customElements.get('md-dialog')) {
                console.log('⏳ Waiting for md-dialog to be defined...');
                await customElements.whenDefined('md-dialog');
                console.log('✅ md-dialog is now defined!');
            } else {
                console.log('✅ md-dialog already defined');
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
                
                // Verify dialog opened successfully
                setTimeout(() => {
                    const isOpen = dialog.hasAttribute('open') || dialog.open;
                    console.log('✅ Dialog opened successfully:', isOpen);
                }, 100);
                
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
        if (tabs) {
            // Material 3 tabs change event
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
            
            // Fallback: Add click handlers to individual tabs
            const individualTabs = this.querySelectorAll('md-primary-tab');
            individualTabs.forEach((tab, index) => {
                tab.addEventListener('click', (e) => {
                    e.preventDefault();
                    console.log(`🔍 Tab ${index} clicked`);
                    
                    const pageMap = {
                        0: 'players',
                        1: 'rounds', 
                        2: 'scoring',
                        3: 'rankings'
                    };
                    
                    const targetPage = pageMap[index];
                    if (targetPage) {
                        // Remove active state from all tabs
                        individualTabs.forEach(t => t.removeAttribute('active'));
                        // Add active state to clicked tab
                        tab.setAttribute('active', '');
                        
                        console.log(`🎯 Navigating to page: ${targetPage}`);
                        this.navigateToPage(targetPage);
                    }
                });
            });
        }

        // Header actions
        const saveBtn = this.querySelector('#save-btn');
        if (saveBtn) {
            saveBtn.addEventListener('click', () => {
                this.saveTournament();
            });
        }

        const settingsBtn = this.querySelector('#settings-btn');
        console.log('🔍 Settings button element:', settingsBtn);
        if (settingsBtn) {
            console.log('✅ Settings button found, adding click listener');
            console.log('🔬 Button details:', {
                tagName: settingsBtn.tagName,
                id: settingsBtn.id,
                constructor: settingsBtn.constructor.name,
                hasClickMethod: typeof settingsBtn.click
            });
            
            // Add multiple event listeners to catch any click
            settingsBtn.addEventListener('click', (e) => {
                console.log('🔥 Settings button clicked (click event)');
                console.log('🔧 Event details:', e);
                console.log('🔧 Calling openSettings()...');
                this.openSettings();
            });
            
            // Also try mousedown and touch events
            settingsBtn.addEventListener('mousedown', (e) => {
                console.log('🖱️ Settings button mousedown');
            });
            
            settingsBtn.addEventListener('touchstart', (e) => {
                console.log('👆 Settings button touchstart');
            });
            
            // Remove the auto-test since we know the click works
            
        } else {
            console.error('❌ Settings button NOT found in DOM');
        }

        // Settings dialog
        const cancelSettingsBtn = this.querySelector('#cancel-settings-btn');
        if (cancelSettingsBtn) {
            cancelSettingsBtn.addEventListener('click', () => {
                const dialog = this.querySelector('#settings-dialog');
                this.closeDialog(dialog);
            });
        }

        const saveSettingsBtn = this.querySelector('#save-settings-btn');
        if (saveSettingsBtn) {
            saveSettingsBtn.addEventListener('click', () => {
                this.saveSettings();
            });
        }

        // Data management buttons
        const exportBtn = this.querySelector('#export-data-btn');
        if (exportBtn) {
            exportBtn.addEventListener('click', () => {
                this.exportTournament();
            });
        }

        const importBtn = this.querySelector('#import-data-btn');
        if (importBtn) {
            importBtn.addEventListener('click', () => {
                const fileInput = this.querySelector('#import-file-input');
                if (fileInput) fileInput.click();
            });
        }

        const importFileInput = this.querySelector('#import-file-input');
        if (importFileInput) {
            importFileInput.addEventListener('change', (e) => {
                this.importTournament(e.target.files[0]);
            });
        }

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
        
        console.log(`🎯 Navigating to page: ${pageId}`);
        
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
            const individualTabs = this.querySelectorAll('md-primary-tab');
            
            // Try Material 3 way first
            if (tabs && tabs.activeTabIndex !== undefined) {
                tabs.activeTabIndex = tabIndex;
                console.log(`✅ Set Material 3 activeTabIndex to ${tabIndex}`);
            }
            
            // Fallback: manually set active attributes
            if (individualTabs.length > 0) {
                individualTabs.forEach((tab, index) => {
                    if (index === tabIndex) {
                        tab.setAttribute('active', '');
                        console.log(`✅ Set tab ${index} as active`);
                    } else {
                        tab.removeAttribute('active');
                    }
                });
            }
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

    async openSettings() {
        try {
            console.log('🚀 openSettings() called');
            console.log('📍 this context:', this);
            const dialog = this.querySelector('#settings-dialog');
            console.log('🔍 Dialog element found:', dialog);
            
            if (!dialog) {
                console.error('Settings dialog not found');
                return;
            }
            
            const settings = this.tournamentService.getSettings();
            console.log('Current settings:', settings);
            
            // Populate current settings
            const winnerPointsInput = this.querySelector('#winner-points');
            const loserPointsInput = this.querySelector('#loser-points');
            
            if (winnerPointsInput) winnerPointsInput.value = settings.winnerPoints;
            if (loserPointsInput) loserPointsInput.value = settings.loserPoints;
            
            // Set tournament mode
            const mode = settings.mode || 'singles';
            const modeRadio = this.querySelector(`#mode-${mode}`);
            if (modeRadio) {
                modeRadio.checked = true;
            }
            
            // Open dialog using helper method
            const opened = await this.openMaterialDialog(dialog);
            if (!opened) {
                this.showError('Failed to open settings dialog');
            }
            
        } catch (error) {
            console.error('Error opening settings:', error);
            this.showError(`Failed to open settings: ${error.message}`);
        }
    }

    saveSettings() {
        try {
            const winnerPoints = parseInt(this.querySelector('#winner-points').value);
            const loserPoints = parseInt(this.querySelector('#loser-points').value);
            const tournamentMode = this.querySelector('input[name="tournament-mode"]:checked').value;
            
            if (winnerPoints <= loserPoints) {
                this.showError('Winner points must be greater than loser points');
                return;
            }
            
            this.tournamentService.updateSettings({
                winnerPoints,
                loserPoints,
                mode: tournamentMode
            });
            
            this.closeDialog(this.querySelector('#settings-dialog'));
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

    // Helper method to close all dialogs
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