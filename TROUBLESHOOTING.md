# Troubleshooting Guide - v2.0.1

## 🔍 Debug Steps

### 1. Clear Browser Cache (CRITICAL!)

**Method 1: Full Cache Clear**
```
1. Press Ctrl + Shift + Delete
2. Select "Cached images and files"
3. Time range: "All time"
4. Click "Clear data"
5. Close and reopen browser
```

**Method 2: Hard Refresh**
```
1. Press Ctrl + F5 (Windows/Linux)
2. Or Cmd + Shift + R (Mac)
3. Or F12 → Right-click refresh → "Empty Cache and Hard Reload"
```

### 2. Verify Version

After clearing cache, check the **footer** at the bottom of the page.  
You should see: `v2.0 - Scoring & Doubles Mode`

If you don't see this, your cache hasn't been cleared!

### 3. Check Browser Console

**Open Console:**
- Press F12
- Click "Console" tab

**What to Look For:**

✅ **Good Signs:**
```
✓ Main application module loaded
✓ Custom element fully initialized
✓ Switching to full application
🔄 Initializing Material 3 components...
✓ Material 3 components fully initialized
```

❌ **Bad Signs (Errors):**
```
❌ Failed to load module
❌ Uncaught TypeError
❌ Settings dialog not found
❌ Match not found
```

### 4. Test Settings Button

**Steps:**
1. Click the ⚙️ (gear/settings) icon in top-right header
2. Check console for: `"Settings button clicked"`
3. Check console for: `"Opening settings..."`
4. Dialog should appear with "Tournament Settings" title

**If Nothing Happens:**
- Check console for errors
- Verify cache is cleared
- Look for: `"Dialog element found: md-dialog"`

**Common Issues:**
- Dialog not found → Cache issue or Material 3 not loaded
- `dialog.show is not a function` → Fixed in v2.0.1

### 5. Test Scoring

**Prerequisites:**
1. Add 4+ players in Players tab
2. Generate a round in Rounds tab
3. Go to Scoring tab

**Steps:**
1. Click "Score Match" button
2. Check console for: `"Opening score dialog for match: ..."`
3. Check console for: `"Match found: ..."`
4. Dialog should appear with player names

**If Nothing Happens:**
- Check console: `"Pending matches: [...]"`
- Verify matches exist in current round
- Look for: `"Match missing player data"` error

**Common Issues:**
- No matches displayed → No active round (generate one first)
- Button doesn't work → Check console for errors
- Match data incomplete → Refresh page and check again

---

## 🐛 Known Issues & Fixes

### Issue 1: Settings Dialog Won't Open
**Symptoms:** Clicking settings button does nothing  
**Cause:** Material 3 dialog not initialized or cached old code  
**Fix:**
1. Clear browser cache completely
2. Hard refresh (Ctrl + F5)
3. Check console for initialization logs
4. Look for version "v2.0" in footer

### Issue 2: Score Match Button Doesn't Work
**Symptoms:** Click does nothing, no dialog appears  
**Cause:** Match data not enriched with player objects  
**Fix:**
1. Refresh the page
2. Check console logs for "Match found" message
3. If "Match missing player data" appears, restart server
4. Verify you have an active round with pending matches

### Issue 3: Material 3 Theme Unloads
**Symptoms:** Page loads styled, then switches to basic HTML  
**Cause:** Custom element initialization conflict  
**Fix:**
- Already fixed in v2.0
- Clear cache to get latest code
- Look for Material 3 initialization logs in console

### Issue 4: Tournament Mode Not Visible
**Symptoms:** Can't see Singles/Doubles radio buttons  
**Cause:** Browser showing cached version  
**Fix:**
1. Clear cache thoroughly
2. Look for "Tournament Mode" section at TOP of settings dialog
3. Should be BEFORE "Scoring" section

---

## 📊 Debug Console Commands

Open browser console (F12) and try these:

```javascript
// Check if app element exists
document.querySelector('badminton-tournament-app')

// Check if settings dialog exists
document.querySelector('#settings-dialog')

// Try to open settings manually
document.querySelector('#settings-dialog').show()

// Check for pending matches
document.querySelector('scoring-page').pendingMatches

// Check Material 3 components
console.log(customElements.get('md-dialog'))
console.log(customElements.get('md-icon-button'))
```

---

## 🚀 Quick Fix Checklist

- [ ] Browser cache cleared (Ctrl + Shift + Delete)
- [ ] Page hard refreshed (Ctrl + F5)
- [ ] Version shows "v2.0" in footer
- [ ] Browser console open (F12)
- [ ] No red errors in console
- [ ] Material 3 initialization logs present
- [ ] At least 4 players added
- [ ] Round generated before testing scoring

---

## 📝 Reporting Issues

If problems persist, check console and note:

1. **Browser & Version**: (e.g., Chrome 120, Firefox 115)
2. **Console Errors**: Copy full error messages
3. **Steps Taken**: What you clicked/did
4. **Expected**: What should happen
5. **Actual**: What actually happened
6. **Version**: Footer should show "v2.0"

---

## 🎯 Expected Behavior

### Settings Dialog
1. Click ⚙️ icon
2. Dialog slides in from right or appears centered
3. Shows 4 sections:
   - Tournament Mode (radio buttons)
   - Scoring (points inputs)
   - Data Management (export/import)
   - Tournament Actions (reset/new)

### Score Match
1. Click "Score Match" on pending match
2. Dialog shows:
   - Player1 / Player2 vs Player3 / Player4
   - Two buttons: "Pair 1 Wins" and "Pair 2 Wins"
3. Click winner
4. Confirmation dialog appears
5. Click "Confirm"
6. Match moves to completed
7. Scores update in Rankings tab

### Tournament Mode
1. Open Settings
2. Select "Doubles (2 vs 2)"
3. Save Settings
4. Generate Round 1 → Note partners
5. Score all matches
6. Generate Round 2 → Partners are different!

---

## 🔧 Developer Tools

### Check Network Tab
1. Press F12 → Network tab
2. Refresh page (F5)
3. Look for:
   - `app.js` - Should load with status 200
   - `scoring-page.js` - Should load with status 200
   - `tournament.js` - Should load with status 200
4. If any show 304 (cached), do hard refresh

### Application Tab (Storage)
1. F12 → Application tab
2. Local Storage → http://localhost:3000
3. Look for `badminton_tournament` key
4. If needed, right-click → Delete to reset tournament

---

## ✅ Success Indicators

You know everything is working when:
- ✅ Footer shows "v2.0 - Scoring & Doubles Mode"
- ✅ Settings button opens dialog with Tournament Mode section
- ✅ Score Match buttons work and show player names
- ✅ No errors in console (except deprecation warnings are OK)
- ✅ Material 3 styled components everywhere
- ✅ Delete buttons appear on completed rounds
- ✅ Reset buttons appear on completed matches
