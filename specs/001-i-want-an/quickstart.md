# Quickstart: Badminton Doubles Tournament Manager

## Prerequisites
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)
- Docker installed (for deployment testing)

## Development Setup

### 1. Local Development
```bash
# Navigate to project root
cd /path/to/badminton_draw

# Install dependencies (when package.json exists)
npm install

# Start development server (basic HTTP server)
npx http-server src -p 3000

# Open browser to http://localhost:3000
```

### 2. Docker Deployment Test
```bash
# Build Docker image
docker build -t badminton-tournament .

# Run container
docker run -p 8080:80 badminton-tournament

# Open browser to http://localhost:8080
```

## User Workflow Testing

### Test Scenario 1: Complete Tournament Flow
**Objective**: Verify end-to-end tournament functionality

1. **Setup Phase**
   - Open application in browser
   - Navigate to "Players" tab
   - Add 6 players: "Alice", "Bob", "Carol", "Dave", "Eve", "Frank"
   - Verify no duplicate names allowed
   - Remove one player, add back different name
   - Expected: Player list shows 6 unique names

2. **Round 1 Generation**
   - Navigate to "Rounds" tab
   - Click "Start Tournament" button
   - Click "Generate Round 1" 
   - Expected: 3 matches displayed with random pairings
   - Expected: 6 players assigned, none sitting out

3. **Score Recording**
   - Navigate to "Scoring" tab
   - Record winners for all 3 matches in Round 1
   - Expected: Cannot record same match twice
   - Expected: All players show updated scores

4. **Rankings Check**
   - Navigate to "Rankings" tab
   - Expected: 3 players with 2 points (winners)
   - Expected: 3 players with 1 point (losers)
   - Expected: Players sorted by score descending

5. **Round 2 Generation**
   - Navigate to "Rounds" tab
   - Click "Generate Round 2"
   - Expected: New pairings generated
   - Expected: No player paired with same partner as Round 1

6. **Complete Tournament**
   - Record Round 2 results
   - Check final rankings
   - Expected: Cumulative scores displayed correctly
   - Expected: Clear winner identifiable

### Test Scenario 2: Odd Player Count
**Objective**: Verify odd player handling

1. **Setup with 5 Players**
   - Add exactly 5 players
   - Start tournament and generate round
   - Expected: 2 matches created, 1 player sits out
   - Expected: Sitting player gets 0 points

2. **Multiple Rounds with Sitting**
   - Generate 3 rounds total
   - Expected: Different player sits out each round (ideally)
   - Expected: All players eventually participate

### Test Scenario 3: Data Persistence
**Objective**: Verify tournament state saves/loads

1. **Mid-Tournament Save**
   - Complete setup and Round 1 (don't finish tournament)
   - Refresh browser page
   - Expected: Tournament state restored
   - Expected: Can continue from where left off

2. **Tournament Reset**
   - Use reset tournament function
   - Expected: All scores cleared
   - Expected: Player list preserved
   - Expected: Can start new tournament with same players

### Test Scenario 4: Error Handling
**Objective**: Verify edge cases handled gracefully

1. **Insufficient Players**
   - Try to start tournament with only 3 players
   - Expected: Error message displayed
   - Expected: Tournament remains in setup state

2. **Invalid Operations**
   - Try to add duplicate player name
   - Try to record result for non-existent match
   - Try to generate round before previous round complete
   - Expected: Appropriate error messages for each case

## Manual Testing Checklist

### UI/UX Testing
- [ ] All tabs/pages accessible via navigation
- [ ] Material 3 design components render correctly
- [ ] Responsive design works on mobile devices
- [ ] Form validation provides clear feedback
- [ ] Loading states shown for operations
- [ ] Success/error messages displayed appropriately

### Functional Testing
- [ ] Player CRUD operations work correctly
- [ ] Random pairing generates valid matches
- [ ] Scoring system calculates points accurately
- [ ] Rankings update in real-time
- [ ] Tournament state transitions properly
- [ ] Data persists between browser sessions

### Performance Testing
- [ ] Initial page load under 2 seconds
- [ ] Tab navigation under 500ms
- [ ] Round generation completes quickly (<1s for 20 players)
- [ ] No memory leaks during extended use
- [ ] Works offline after initial load

### Browser Compatibility
- [ ] Chrome (latest version)
- [ ] Firefox (latest version) 
- [ ] Safari (latest version)
- [ ] Edge (latest version)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

## Success Criteria

### Core Functionality
✅ **Tournament organizer can manage player list easily**
✅ **System generates random, fair pairings each round**  
✅ **Scoring system tracks individual points correctly**
✅ **Live rankings display throughout tournament**
✅ **Data persists between browser sessions**

### Technical Requirements
✅ **Material 3 design system implemented**
✅ **Multi-page/tab navigation functional**
✅ **Docker deployment works correctly**
✅ **Minimal dependencies and complexity**
✅ **Mobile-responsive design**

### Quality Standards
✅ **Manual testing scenarios pass**
✅ **Error handling prevents crashes** 
✅ **Performance meets target metrics**
✅ **Cross-browser compatibility verified**
✅ **Constitution compliance maintained**

## Troubleshooting

### Common Issues
- **localStorage errors**: Check browser storage quota, try incognito mode
- **Pairing generation fails**: Ensure even number of players or accept sitting out
- **Docker build fails**: Verify Dockerfile syntax and dependency availability
- **Material 3 components not loading**: Check browser compatibility and network connectivity

### Debug Information
- Check browser console for JavaScript errors
- Inspect localStorage data: `localStorage.getItem('badminton_tournament')`
- Verify network requests if using external Material 3 CDN
- Check Docker container logs: `docker logs <container-id>`