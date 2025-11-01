# Pokemon Party Volunteer Runbook

## Quick Start (30 minutes before party)

### 1. Open Terminal
- Navigate to the PokemonParty folder
- Command: `cd C:\path\to\PokemonParty` (adjust as needed)

### 2. Start the Party Environment
```powershell
.\scripts\start-party.ps1 -OpenBrowser
```

This script will:
- ✓ Check all files are present
- ✓ Install missing dependencies
- ✓ Run a quick smoke test
- ✓ Start the backend server
- ✓ Open the welcome page in your browser

### 3. Verify Everything Works
Once the script completes, you should see:
- Terminal shows "Uvicorn running on http://127.0.0.1:8000"
- Browser opens to the Welcome page
- No error messages in the terminal

### 4. Important URLs
Keep these bookmarked or in a text file:

| Page | URL | Purpose |
|------|-----|---------|
| Welcome | http://127.0.0.1:8000/welcome.html | Main intro screen |
| Check-in | http://127.0.0.1:8000/checkin.html | Kids register here |
| Habitat | http://127.0.0.1:8000/habitat.html | Animal viewing |
| Professor Intro | http://127.0.0.1:8000/professor-intro.html | Professor Oak introduction |
| Hold Scanner | http://127.0.0.1:8000/hold-scanner.html | Interactive voting |

## During the Party

### Scene Flow
1. **Arrival (10 min)**: Keep Welcome page on projector, use Check-in page on tablet
2. **Introduction (5 min)**: Switch to Professor Intro page
3. **Animal Encounters (60 min)**: Use Habitat page, cycle through 3-4 animals
4. **Group Tasks (20 min)**: Use Hold Scanner for voting activities
5. **Wrap-up (5 min)**: Return to Welcome or show Mission Complete

### Common Tasks

#### Reset a Page
- Refresh the browser (F5 or Ctrl+R)
- State is maintained in the backend

#### Advance to Next Scene
- Use the navigation buttons on each page
- Manual URL navigation works too

#### Check Who's Registered
- Open Check-in page
- Scroll down to see the roster list

## Troubleshooting

### Problem: "Port 8000 already in use"

**Solution 1:** Find and stop the existing process
```powershell
netstat -ano | Select-String ":8000"
# Note the PID, then:
taskkill /PID <number> /F
```

**Solution 2:** Use a different port
```powershell
.\scripts\start-party.ps1 -Port 8001
```
(Update all URLs to use :8001 instead)

### Problem: Pages won't load (404 errors)

**Check:**
1. Is the terminal showing "Uvicorn running"?
2. Are you using the correct URL (http://127.0.0.1:8000)?
3. Does the `frontend` folder exist with HTML files?

**Fix:**
- Stop server (Ctrl+C)
- Run `.\scripts\start-party.ps1` again

### Problem: Tests failed during startup

**Options:**
1. Continue anyway - tests failing doesn't always mean the party won't work
2. Skip tests next time: `.\scripts\start-party.ps1 -SkipTests`

### Problem: Browser won't open automatically

**Fix:** Manually open browser and go to:
```
http://127.0.0.1:8000/welcome.html
```

### Problem: Laptop goes to sleep

**Prevention:**
- Go to Windows Settings → System → Power
- Set "Screen" to "Never" when plugged in
- Set "Sleep" to "Never" when plugged in

## Emergency Contacts

- Repo Owner: @starlightkristen
- For urgent technical issues during party: Open GitHub issue with title "party: urgent - [problem]"

## After the Party

1. **Stop the server:** Press Ctrl+C in the terminal
2. **Save logs (optional):**
   ```powershell
   Compress-Archive -Path artifacts,playwright-report -DestinationPath "party-logs-$(Get-Date -Format 'yyyyMMdd').zip"
   ```
3. **Report issues:** Create a GitHub issue documenting any problems for future improvement

## Cheat Sheet

| What You Need | Command/Action |
|---------------|----------------|
| Start everything | `.\scripts\start-party.ps1 -OpenBrowser` |
| Start without tests | `.\scripts\start-party.ps1 -SkipTests` |
| Stop server | `Ctrl+C` in terminal |
| Reload page | `F5` or `Ctrl+R` |
| Check backend is running | Look for "Uvicorn running" in terminal |
| Manual URL change | Type new URL in browser address bar |

## Pre-Party Checklist

- [ ] Laptop charged and plugged in
- [ ] Terminal open to PokemonParty folder
- [ ] Internet connection working (for first-time setup)
- [ ] Browser bookmarks set for all pages
- [ ] Projector/monitor connected and tested
- [ ] Tablet (if using) connected to same network
- [ ] Volume tested on all devices
- [ ] Ran `.\scripts\start-party.ps1` successfully at least once
- [ ] Welcome page loads and looks correct

## Success Criteria

You're ready for the party when:
- ✓ Script completes without errors
- ✓ Welcome page loads
- ✓ Can navigate between pages using buttons
- ✓ Check-in page shows roster when you add a name
- ✓ Terminal shows no error messages
