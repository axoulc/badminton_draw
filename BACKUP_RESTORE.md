# 💾 Backup & Restore Guide

## Overview

The Badminton Tournament Manager now supports complete backup and restore functionality. All tournament data is saved in JSON format, allowing you to:

- Create safety backups before making changes
- Share tournaments with other organizers
- Move tournaments between devices
- Archive completed tournaments
- Restore after accidental deletion

## Quick Start

### Creating a Backup

1. **During a tournament:**
   - Click the menu button (⋮) in the top-right corner
   - Select **"Export Backup"**
   - A JSON file will automatically download
   - Filename format: `TournamentName_backup_2025-10-01.json`

### Restoring from a Backup

2. **With an existing tournament:**
   - Click the menu button (⋮)
   - Select **"Import Backup"**
   - Choose your backup JSON file
   - Confirm to replace current tournament

3. **Without a tournament (fresh start):**
   - On the Setup screen
   - Click **"Import Backup"** button
   - Choose your backup JSON file
   - Tournament will be restored immediately

## What's Included in a Backup

✅ **Tournament Configuration:**
- Tournament name
- Mode (Singles/Doubles)
- Status (Setup/Active/Completed)
- Winner points setting
- Loser points setting
- Created and updated timestamps

✅ **All Players:**
- Player names and IDs
- Wins and losses
- Total points
- Complete statistics

✅ **All Rounds:**
- Round numbers and IDs
- All matches in each round
- Match results (completed/incomplete)
- Winner selections

✅ **Complete History:**
- Every match ever played
- All score changes
- Full tournament progression

## Backup File Format

Backups are saved as standard JSON files. Here's what the structure looks like:

```json
{
  "id": "uuid",
  "name": "Summer Championship",
  "mode": "doubles",
  "status": "active",
  "winnerPoints": 2,
  "loserPoints": 1,
  "players": [
    {
      "id": "uuid",
      "name": "Alice",
      "wins": 3,
      "losses": 1,
      "points": 7
    }
  ],
  "rounds": [
    {
      "id": "uuid",
      "number": 1,
      "matches": [...]
    }
  ],
  "createdAt": "2025-10-01T10:00:00.000Z",
  "updatedAt": "2025-10-01T15:30:00.000Z"
}
```

## Best Practices

### 🎯 When to Create Backups

**Before major actions:**
- Before editing match results
- Before changing scoring settings
- Before resetting rounds
- Before deleting players

**Regular backups:**
- After completing each round
- At the end of each day (multi-day tournaments)
- Before closing the browser/app

**Archive backups:**
- When tournament is completed
- For historical records
- For analysis and reporting

### 📁 Where to Store Backups

**Local storage:**
- Downloads folder (automatically saved here)
- Create a "Tournament Backups" folder
- Name files clearly with date and tournament name

**Cloud storage:**
- Google Drive / Dropbox / OneDrive
- Automatic sync enabled
- Accessible from multiple devices

**Version control:**
- Keep multiple versions
- Example naming: `Summer2025_Round1.json`, `Summer2025_Round2.json`
- Don't delete old backups too quickly

### 🔄 Backup Workflow

**Daily tournament workflow:**
1. **Start of day:** Import backup from previous session
2. **After each round:** Export backup
3. **Before changes:** Export backup
4. **End of day:** Final backup export

**Weekly tournament workflow:**
1. **Week start:** Create initial backup
2. **After each session:** Export updated backup
3. **Week end:** Archive final backup

## Troubleshooting

### ❌ Import Fails: "Invalid backup file format"

**Causes:**
- File is corrupted
- JSON syntax error
- Wrong file type

**Solutions:**
- Try a different backup file
- Verify file extension is `.json`
- Open file in text editor to check if it's valid JSON

### ❌ File Won't Download

**Causes:**
- Browser blocking downloads
- Insufficient storage space

**Solutions:**
- Check browser download settings
- Allow downloads from the site
- Free up disk space

### ❌ Import Button Not Working

**Causes:**
- Browser security restrictions
- File picker not supported

**Solutions:**
- Use a modern browser (Chrome, Firefox, Edge)
- Enable file picker permissions
- Try incognito/private mode

## Advanced Usage

### Sharing Tournaments

**Send to co-organizer:**
1. Export backup file
2. Send via email/chat/drive
3. Recipient imports on their device
4. Both have identical tournament data

**Multiple device sync:**
1. Export from Device A
2. Upload to shared cloud folder
3. Download on Device B
4. Import backup
5. Continue tournament on any device

### Manual Editing

For advanced users, you can manually edit backup JSON files:

⚠️ **Warning:** Invalid JSON will fail to import

**Safe edits:**
- Correcting player names (typos)
- Adjusting point values
- Fixing tournament name

**Unsafe edits:**
- Changing IDs (will break references)
- Modifying structure
- Removing required fields

**Always:**
- Keep original backup before editing
- Validate JSON syntax after editing
- Test import before using in production

## FAQ

**Q: Will importing overwrite my current tournament?**
A: Yes, import replaces everything. Export first if you want to keep it!

**Q: Can I import backups from older versions?**
A: Yes, as long as the JSON structure is compatible.

**Q: Are backups encrypted?**
A: No, they're plain JSON. Don't include sensitive information.

**Q: How big are backup files?**
A: Small! Typically 5-50 KB depending on tournament size.

**Q: Can I edit player names in a backup?**
A: Yes! Edit the JSON file, then import. Keep original as backup.

**Q: Do backups include deleted players?**
A: No, only current tournament state is saved.

**Q: Can I merge two tournaments?**
A: Not automatically. You'd need to manually edit JSON (advanced).

**Q: What if I have multiple tournaments?**
A: Each tournament gets its own backup file. Name them clearly!

## Support

If you encounter issues with backup/restore:

1. Check this documentation first
2. Verify JSON file validity
3. Try with a fresh backup
4. Report issues with example files (remove sensitive data)

---

**Remember:** Regular backups = Peace of mind! 💾✨
