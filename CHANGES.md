# Recent Changes - v2.0

## 📋 Specs Documentation

This project includes a **specs-kit** in the `specs/` directory for planning and documentation:
- `specs/001-i-want-an/spec.md` - Original feature specification
- `specs/001-i-want-an/plan.md` - Development plan
- `specs/001-i-want-an/tasks.md` - Task breakdown
- Other supporting docs (data-model, contracts, research)

Feel free to update these files as the project evolves!

---

## v2.0.1 - Bug Fixes (Latest)

### Fixed:
- ✅ **Settings Dialog Not Opening**: Added defensive checks and better error handling
- ✅ **Score Match Button Not Working**: Enhanced error handling and logging in scoring page
- ✅ **Material 3 Dialog Compatibility**: Fixed dialog.show() method calls
- ✅ **Console Logging**: Added debug logs to help troubleshoot issues

### How to Test:
1. **Clear browser cache** (Ctrl + Shift + Delete)
2. **Hard refresh** (Ctrl + F5)
3. Open browser console (F12) to see debug logs
4. Check for "v2.0 - Scoring & Doubles Mode" in footer

---

## Clear Your Browser Cache!

To see the new features, you need to clear your browser cache:

### In Chrome/Edge:
1. Press `Ctrl + Shift + Delete`
2. Select "Cached images and files"
3. Click "Clear data"
4. OR press `Ctrl + F5` to hard refresh

### Or:
- Open DevTools (F12)
- Right-click the refresh button
- Select "Empty Cache and Hard Reload"

---

## New Features Added:

### 1. ✅ Tournament Mode Setting (Singles/Doubles)
- **Location**: Settings → Tournament Mode section
- **Options**:
  - Singles (1 vs 1) - Traditional format
  - Doubles (2 vs 2) - Partners rotate each round
- **How to use**: 
  1. Click the settings icon (gear) in the header
  2. Select your preferred mode
  3. Click "Save Settings"

### 2. ✅ Match Scoring Fixed
- **Location**: Scoring tab
- Pending matches now display correctly with player names
- "Score Match" buttons work properly
- Match results are recorded successfully

### 3. ✅ Reset Match Status
- **Location**: Scoring tab → Completed Matches
- Each completed match now has a "Reset" button
- Resets match back to pending
- Automatically reverts player scores

### 4. ✅ Delete Rounds
- **Location**: Rounds tab → Rounds History
- Each completed round has a delete button (trash icon)
- Clicking it will:
  - Revert all player scores from that round
  - Remove the round completely
  - Renumber remaining rounds
- **Warning**: This action requires confirmation

### 5. ✅ Reset Tournament
- **Location**: Settings → Tournament Actions → "Reset Tournament" button
- Clears all data and starts fresh

---

## Testing Instructions:

1. **Test Singles Mode (1v1)**:
   - Add 4+ players
   - Keep mode as "Singles" (default)
   - Generate a round
   - You'll see matches with 2 players vs 2 players

2. **Test Doubles Mode (2v2) with Partner Rotation**:
   - Settings → Change mode to "Doubles"
   - Save settings
   - Generate Round 1 - note the partners
   - Score all matches
   - Generate Round 2 - partners will be different!

3. **Test Match Reset**:
   - Go to Scoring tab
   - Score a pending match
   - Find it in Completed Matches
   - Click "Reset" button
   - Check that scores reverted in Rankings

4. **Test Delete Round**:
   - Go to Rounds tab
   - Scroll to Rounds History
   - Click the trash icon on any round
   - Confirm deletion
   - Verify scores updated in Rankings

---

## Troubleshooting:

**If you don't see the changes:**
1. Clear browser cache (Ctrl + Shift + Delete)
2. Hard refresh (Ctrl + F5)
3. Close and reopen the browser
4. Check console for errors (F12)

**If tournament mode doesn't appear:**
- Make sure you're in Settings dialog
- Look for the "Tournament Mode" section at the top
- It should have radio buttons for Singles/Doubles

**If delete buttons don't appear:**
- Refresh the page after clearing cache
- Check that you have completed rounds
- Delete buttons only appear on completed rounds
