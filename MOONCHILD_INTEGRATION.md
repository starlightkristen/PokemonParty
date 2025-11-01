# Moonchild UI Integration Guide

## Overview

This project uses a dual-structure approach for UI development:
- **`frontend/`** - Production UI files served by FastAPI
- **`moonchild-ui/`** - Export folder for Moonchild designs (not committed to repo)

## Directory Structure

```
C:\Users\krist\PokemonParty
├── server/
│   └── app/
│       └── main.py           (FastAPI - serves /frontend at root)
├── frontend/                 (Production - what FastAPI serves)
│   ├── welcome.html
│   ├── checkin.html
│   ├── habitat.html
│   ├── professor-intro.html
│   ├── admin.html
│   ├── starter-randomizer.html
│   ├── css/
│   ├── js/
│   └── assets/              (images, fonts, etc.)
├── moonchild-ui/            (Export from Moonchild - gitignored)
│   ├── welcome.html
│   ├── checkin.html
│   ├── habitat.html
│   ├── professor-intro.html
│   └── assets/
└── scripts/
    ├── import-moonchild-ui.ps1
    └── start-party.ps1
```

## Scene Mapping

### Current Working Pages
- `welcome.html` - Simple welcome with status indicator
- `checkin.html` - Basic scan page
- `habitat.html` - Animal info + voting
- `professor-intro.html` - Simple intro
- `admin.html` - Admin controls
- `hold-scanner.html` - Type scanner game
- `hold-type-scanner.html` - Alternative scanner

### Moonchild Enhanced Pages
- `welcome.html` - Animated hero, Pokémon Academy title, trainer CTA
- `checkin.html` - Scan frame with instructions and Leon flavor text
- `habitat.html` - Nicer panel, bigger image, three Pokémon options with icons
- `professor-intro.html` - Frame with Oak video overlay, text on the right
- `starter-randomizer.html` - Spinner or picker screen (new)

## How to Import Moonchild Designs

### Method 1: Automatic Import (Recommended)

The `start-party.ps1` script automatically imports Moonchild UI if present:

```powershell
cd C:\Users\krist\PokemonParty
.\scripts\start-party.ps1 -OpenBrowser
```

This will:
1. Check if `moonchild-ui/` folder exists
2. Import any matching HTML pages
3. Copy assets folder
4. Start the backend server
5. Open browser to welcome page

### Method 2: Manual Import

Run the importer script directly:

```powershell
cd C:\Users\krist\PokemonParty
.\scripts\import-moonchild-ui.ps1 -RepoRoot "." -MoonchildFolder ".\moonchild-ui" -FrontendFolder ".\frontend"
```

### What Gets Imported

The importer will:
- ✅ Copy any HTML pages from `moonchild-ui/` to `frontend/`
- ✅ Copy the entire `assets/` folder (images, CSS, JS)
- ✅ Preserve existing pages not in Moonchild export
- ✅ Overwrite existing pages with Moonchild versions

### Export from Moonchild

1. **Static HTML Export:**
   - Export pages to `C:\Users\krist\PokemonParty\moonchild-ui\`
   - Ensure file names match: `welcome.html`, `checkin.html`, etc.
   - Include `assets/` folder for images/CSS/JS

2. **React/Vite Build:**
   - Build the Moonchild app: `npm run build`
   - This creates a `dist/` folder
   - **Option A:** Copy `dist/*` to `frontend/`
     ```powershell
     Copy-Item C:\path\to\moonchild\dist\* .\frontend\ -Recurse -Force
     ```
   - **Option B:** Update `main.py` to serve `dist/` folder:
     ```python
     app.mount("/", StaticFiles(directory="dist", html=True), name="frontend")
     ```

## Testing After Import

1. **Start the server:**
   ```powershell
   .\scripts\start-party.ps1 -OpenBrowser
   ```

2. **Verify pages load:**
   - http://127.0.0.1:8000/welcome.html
   - http://127.0.0.1:8000/checkin.html
   - http://127.0.0.1:8000/habitat.html

3. **Run tests:**
   ```powershell
   npx playwright test
   ```

4. **Check the design:**
   - Open dev console (F12)
   - Check for missing assets
   - Verify API calls work

## Troubleshooting

### Pages Not Loading
- Verify file names match exactly (case-sensitive on some systems)
- Check that `frontend/` folder exists
- Ensure FastAPI is mounting the correct directory

### Assets Not Loading
- Check that `assets/` folder was copied
- Verify asset paths in HTML are relative: `./assets/image.png`
- Not absolute: `/assets/image.png` works too

### Moonchild Export Not Found
- Ensure you've exported to `moonchild-ui/` folder
- Check file names match expected pages
- Run manual import to see detailed output

### API Calls Failing
- Backend must be running: `python -m uvicorn server.app.main:app --reload`
- Check API endpoints exist in `server/app/main.py`
- Open browser console to see actual errors

## Agent Task List

If handing this to an AI agent (OpenHands, Azure, Cursor):

1. ✅ Verify FastAPI is mounting `frontend/` at root
2. ✅ If `moonchild-ui/` exists, copy matching HTML files to `frontend/`
3. ✅ Preserve existing HTML files if Moonchild didn't export that scene
4. ✅ Re-run `scripts\comprehensive-verification.ps1`
5. ✅ Re-run `scripts\start-party.ps1 -OpenBrowser`
6. ✅ Confirm http://127.0.0.1:8000/welcome.html shows Moonchild design
7. ✅ Run `npx playwright test` to verify integration

## Notes

- **`moonchild-ui/`** is gitignored (add to `.gitignore` if not present)
- Only export/commit files you want in production
- Keep working versions in `frontend/` as fallbacks
- Importer script is non-destructive (keeps existing files)
- Can mix-and-match: Some pages from Moonchild, some original

## Quick Commands

```powershell
# Import Moonchild UI only
.\scripts\import-moonchild-ui.ps1

# Import and start server
.\scripts\start-party.ps1 -OpenBrowser

# Start server without import
python -m uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000

# Run tests
npx playwright test

# Open welcome page
Start-Process "http://127.0.0.1:8000/welcome.html"
```
