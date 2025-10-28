# Pokemon Party — Volunteer Runbook

**Quick Reference for Event Day**

---

## Before the Party (30-60 minutes before)

### Option A: Quick Start (Recommended)

**Windows:**
```powershell
.\scripts\start-party.ps1
```

**Mac/Linux:**
```bash
bash scripts/start-party.sh
```

This script will:
- ✅ Activate Python environment
- ✅ Install dependencies
- ✅ Start the backend server
- ✅ Open welcome page in browser
- ✅ Run smoke tests
- ✅ Display test report

### Option B: Manual Start

1. Open PowerShell/Terminal in repo folder
2. Start backend:
   ```
   python -m uvicorn server.app.main:app --host 127.0.0.1 --port 8000
   ```
3. Open browser to: http://127.0.0.1:8000/welcome.html
4. Test pages work:
   - Welcome: http://127.0.0.1:8000/welcome.html
   - Check-in: http://127.0.0.1:8000/checkin.html
   - Hold Scanner: http://127.0.0.1:8000/hold-scanner.html

---

## During the Party

### Normal Operation
- Keep backend terminal/PowerShell window open
- Navigate between pages as needed
- Pages should load quickly (they're static HTML)

### If Something Breaks

**Problem: Page won't load (404 error)**
- ✅ Check backend is running (terminal should show "Uvicorn running")
- ✅ Restart backend: Ctrl+C, then rerun uvicorn command
- ✅ Check URL matches exactly: `http://127.0.0.1:8000/...`

**Problem: Port 8000 already in use**
- ✅ Find process: `netstat -ano | findstr :8000` (Windows) or `lsof -i :8000` (Mac/Linux)
- ✅ Kill old process or use different port: `--port 8001`

**Problem: Page loads but doesn't work**
- ✅ Check browser console (F12) for errors
- ✅ Refresh page (Ctrl+R or Cmd+R)
- ✅ Clear browser cache (Ctrl+Shift+Delete)

---

## After the Party

1. Stop backend: Press **Ctrl+C** in terminal
2. Save logs (optional):
   ```powershell
   # Windows
   Copy-Item -Recurse artifacts C:\backup\pokemon-party-logs
   
   # Mac/Linux
   cp -r artifacts ~/pokemon-party-logs
   ```
3. Report any issues: Create GitHub issue with title "party: [problem description]"

---

## Emergency Contacts

- **Primary Contact:** @starlightkristen (GitHub)
- **Open urgent issue:** Go to https://github.com/starlightkristen/PokemonParty/issues/new
  - Title: `party: urgent - [short description]`
  - Tag: @starlightkristen

---

## Quick Command Cheat Sheet

```powershell
# Start backend
python -m uvicorn server.app.main:app --host 127.0.0.1 --port 8000

# Check if running
curl http://127.0.0.1:8000/api/health

# Stop all Python processes (nuclear option)
Get-Process python | Stop-Process  # Windows
pkill python  # Mac/Linux

# View backend logs (if running in background)
cat /tmp/pokemon-party-backend.log  # Mac/Linux
```

---

## URLs to Bookmark

- Welcome: http://127.0.0.1:8000/welcome.html
- Check-in: http://127.0.0.1:8000/checkin.html
- Habitat: http://127.0.0.1:8000/habitat.html
- Professor Intro: http://127.0.0.1:8000/professor-intro.html
- Hold Scanner: http://127.0.0.1:8000/hold-scanner.html

---

**That's it! Keep this page open during the event for quick reference.**
