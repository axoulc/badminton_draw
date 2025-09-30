# 🎾 Badminton Tournament Manager

A modern, frugal web application for managing doubles badminton tournaments with random pairing, live scoring, and real-time rankings.

![Material 3](https://img.shields.io/badge/Material%203-Design-6750A4?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square)
![No Backend](https://img.shields.io/badge/Backend-None%20Required-00C853?style=flat-square)
![PWA Ready](https://img.shields.io/badge/PWA-Ready-FF6F00?style=flat-square)

## ✨ Features

### 🏆 **Tournament Management**
- **Player Management**: Add, edit, remove players with duplicate validation
- **Random Pairing**: Fisher-Yates shuffle algorithm with smart constraints
- **Live Scoring**: Simple winner selection with +2/+1 point system
- **Real-time Rankings**: Dynamic leaderboard with win rates and statistics
- **Tournament Lifecycle**: Setup → Active → Complete workflow

### 🎨 **Modern UI/UX**
- **Material 3 Design**: Latest Google design system
- **Responsive Layout**: Works on desktop, tablet, and mobile
- **Dark Mode Support**: Respects system preferences
- **Toast Notifications**: Real-time feedback for all actions
- **Accessibility**: ARIA labels and keyboard navigation

### 💾 **Data Management**
- **Local Storage**: No backend required, data persists in browser
- **Auto-save**: Automatic saving every 30 seconds
- **Backup/Restore**: Create and restore tournament snapshots
- **Export/Import**: JSON data exchange for sharing tournaments
- **CSV Export**: Export rankings for external analysis

### 🚀 **Deployment**
- **Docker Ready**: One-command deployment with nginx
- **Static Files**: Runs on any web server
- **No Dependencies**: Self-contained application
- **Offline Capable**: Works without internet connection

## 🏗️ **Architecture**

Built following **frugal development principles**:

- **Functional-First**: Every feature works reliably
- **Pragmatic**: "Good enough" solutions over perfection  
- **Simple**: Clean, maintainable code without over-engineering
- **Minimal**: Only essential dependencies

### **Tech Stack**
- **Frontend**: Vanilla JavaScript ES2022, Material 3 Web Components
- **Storage**: Browser localStorage with JSON serialization
- **Deployment**: Docker + nginx
- **Testing**: Jest (for critical business logic only)

### **Project Structure**
```
src/
├── models/          # Data entities (Player, Tournament, etc.)
├── services/        # Business logic (Pairing, Storage, etc.)
├── pages/           # UI components (Players, Scoring, etc.)
└── app.js          # Main application shell

public/
├── index.html      # Entry point
└── ...

specs/              # Technical specifications
.specify/           # Development artifacts
Dockerfile          # Container deployment
```

## 🚀 **Quick Start**

### **Option 1: Local Development**

1. **Clone the repository**
   ```bash
   git clone https://github.com/axoulc/badminton_draw.git
   cd badminton_draw
   ```

2. **Serve the files** (choose one method)
   
   **Using Python:**
   ```bash
   # Python 3
   python -m http.server 8000 --directory public
   
   # Python 2
   python -m SimpleHTTPServer 8000
   ```
   
   **Using Node.js:**
   ```bash
   npx serve public -p 8000
   ```
   
   **Using Live Server (VS Code extension):**
   - Open project in VS Code
   - Right-click on `public/index.html`
   - Select "Open with Live Server"

3. **Open in browser**
   ```
   http://localhost:8000
   ```

### **Option 2: Docker Deployment**

1. **Build the container**
   ```bash
   docker build -t badminton-tournament .
   ```

2. **Run the container**
   ```bash
   docker run -d -p 8000:80 --name tournament badminton-tournament
   ```

3. **Access the application**
   ```
   http://localhost:8000
   ```

## 📱 **How to Use**

### **1. Add Players**
- Navigate to the **Players** tab
- Enter player names (minimum 4 required)
- Edit or remove players as needed

### **2. Generate Rounds**
- Go to the **Rounds** tab
- Click **Generate Round** to create random pairings
- Algorithm prevents consecutive same partnerships

### **3. Score Matches**
- Switch to the **Scoring** tab
- Click **Score Match** for each game
- Select winning pair (winner gets +2, loser gets +1)

### **4. View Rankings**
- Check the **Rankings** tab for live leaderboard
- Sort by points, matches played, or win rate
- Export results to CSV

### **5. Manage Data**
- Use **Settings** (⚙️) for tournament configuration
- **Export** tournament data for backup
- **Import** previous tournaments to continue

## 🔧 **Configuration**

### **Scoring System**
- **Winner Points**: Default 2 (configurable 1-10)
- **Loser Points**: Default 1 (configurable 0-9)
- Access via Settings → Scoring

### **Data Persistence**
- **Auto-save**: Every 30 seconds (can be disabled)
- **Manual Save**: Click save button (💾) in header
- **Backups**: Create named backups anytime
- **Storage**: Browser localStorage (~5-10MB limit)

## 🐳 **Docker Deployment**

### **Production Deployment**

1. **Build for production**
   ```bash
   docker build -t badminton-tournament:latest .
   ```

2. **Run with restart policy**
   ```bash
   docker run -d \
     --name badminton-tournament \
     --restart unless-stopped \
     -p 80:80 \
     badminton-tournament:latest
   ```

### **Development with Volume Mounting**
```bash
docker run -d \
  --name badminton-dev \
  -p 8000:80 \
  -v $(pwd)/public:/usr/share/nginx/html \
  -v $(pwd)/src:/usr/share/nginx/html/src \
  nginx:alpine
```

### **Environment Variables**
```bash
# Optional: Custom nginx configuration
docker run -d \
  -p 80:80 \
  -e NGINX_HOST=tournament.example.com \
  -e NGINX_PORT=80 \
  badminton-tournament:latest
```

## 🔧 **Development**

### **Prerequisites**
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)
- Web server for local development
- Docker (optional, for containerized deployment)

### **Development Workflow**

1. **Install development tools** (optional)
   ```bash
   npm install  # For testing with Jest
   ```

2. **Run tests** (critical business logic only)
   ```bash
   npm test
   ```

3. **Serve locally**
   ```bash
   npm start  # Uses Python http.server
   ```

4. **Build Docker image**
   ```bash
   npm run docker:build
   npm run docker:run
   ```

### **Code Style**
- ES2022 JavaScript modules
- Material 3 design tokens
- Functional programming patterns
- Comprehensive JSDoc comments

## 🧪 **Testing**

Following **pragmatic testing** principles:

### **What's Tested**
- ✅ **Core Business Logic**: Pairing algorithms, scoring calculations
- ✅ **Data Validation**: Player/tournament state management
- ✅ **Storage Operations**: localStorage persistence and recovery

### **What's NOT Tested**
- ❌ UI interactions (manual testing preferred)
- ❌ CSS styling (visual inspection)
- ❌ Simple getters/setters

### **Run Tests**
```bash
npm test                    # Run all tests
npm test -- --watch        # Watch mode
npm test -- --coverage     # Coverage report
```

## 📊 **Browser Support**

### **Modern Browsers** (Material 3 Web Components)
- ✅ Chrome 90+ (recommended)
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### **Features**
- ✅ ES2022 modules
- ✅ Web Components
- ✅ localStorage
- ✅ CSS Grid/Flexbox
- ✅ Dark mode detection

## 🤝 **Contributing**

This project follows **frugal development principles**:

1. **Keep it simple** - No over-engineering
2. **Functional first** - Features must work reliably
3. **Pragmatic testing** - Test critical paths only
4. **Minimal dependencies** - Avoid unnecessary packages

### **Development Process**
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Follow existing code style and architecture
4. Test critical business logic changes
5. Submit pull request with clear description

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).

## 🆘 **Troubleshooting**

### **Common Issues**

**Application won't load:**
- Check browser console for errors
- Ensure serving over HTTP/HTTPS (not file://)
- Verify Material 3 components loaded

**Data not persisting:**
- Check localStorage quota (5-10MB limit)
- Clear browser cache and try again
- Export data before clearing storage

**Docker container fails:**
- Verify port 80 is available
- Check Docker logs: `docker logs badminton-tournament`
- Ensure sufficient disk space

**Mobile display issues:**
- Clear browser cache
- Check viewport meta tag
- Test in different orientations

### **Reset Application**
```bash
# Clear all stored data
localStorage.clear()  # In browser console

# Or use Settings → Tournament Actions → New Tournament
```

## 🎯 **Roadmap**

Future enhancements (following frugal principles):

- **PWA Support**: Offline installation capability
- **Tournament Templates**: Pre-configured tournament types
- **Player Statistics**: Historical performance tracking
- **Multi-language**: Internationalization support
- **Print Support**: Tournament brackets and results

---

**Built with ❤️ following frugal development principles**

*No backend required • No complex setup • Just works*