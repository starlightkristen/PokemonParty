# Agent Status — PokemonParty

Last updated: 2025-10-28 00:18:34 UTC  
Author: automation / @starlightkristen

---

## Purpose & scope

This file is the single-authority snapshot for:
- Agents and maintainers automating tasks against this repo.
- Humans (volunteers) running the Pokemon Party live demo.
- Future projects that will reuse this repo as a template.

Important context: this codebase was created as both
1) a reusable CI + test + ops template for future projects, and  
2) an event-focused project whose immediate goal is to run a 2-hour birthday party experience (“Pokemon Party”).  

This document prioritizes finishing the Pokemon Party to a reliable, low-friction state for the event while preserving the repo’s template value for later reuse.

---

## Current verified state (summary)

- Repo: `starlightkristen/PokemonParty` — marked as a GitHub template.
- Backup tag pushed: `v1.0.0-backup`
- Release published: `v1.0.0`
- Verified Playwright pipeline: workflow display name “Playwright Phase1 Tests”
  - Example successful run: `18829483655` (no failing jobs found)
  - Workflow ID (from gh workflow list): `200910760`
- Docs: `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `CHANGELOG.md`, `AGENT_STATUS.md` (this file)
- Frontend: 13 static HTML placeholder pages in `frontend/` instrumented with `data-test-id` selectors for Playwright.
- Backend: FastAPI app under `server/` providing minimal/test endpoints and serving static files from `frontend/`.
- Playwright tests: located under `playwright/tests/` (Phase1 + smoke).
- Devops: Playwright CI + nightly-smoke workflow, Dependabot enabled, CODEOWNERS present.
- Local archive created: `../PokemonParty-v1.0.0-backup.zip` (snapshot for offline recovery).

---

## Project goals (explicit)

Primary (for the birthday party)
- Get the event flow working reliably on a laptop or small VM so the two-hour party runs smoothly:
  - Start backend
  - Confirm all placeholder frontend pages load
  - Run the smoke test once to validate the flow
  - Provide a simple runbook for volunteers to recover from common problems

Secondary (template / future reuse)
- Keep the repo template-ready with Docker/devops additions so it can be reused for future events/projects.

This file organizes actionable steps and runbook items for both goals.

---

## Finish-line checklist for the party (order + estimated times)

1. Verify backend serves static pages and API endpoints (10–15 min)
   - Command (repo root):
     - python -m uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000
   - Open http://127.0.0.1:8000/welcome.html in browser and click through basic flows.

2. Run Playwright smoke locally (10–20 min)
   - npm ci
   - npx playwright install --with-deps
   - npx playwright test playwright/tests/smoke.spec.ts --project=chromium
   - Confirm tests pass. If not, check logs at `./artifacts/run-logs/` or rerun failing test interactively (npx playwright test -g "<test name>").

3. Prepare a local machine for party (20–40 min)
   - Create a dedicated user session or terminal tabs:
     - Terminal 1: Backend (uvicorn)
     - Terminal 2: Test/ops (run smoke or quick-checks)
     - Terminal 3: Browser for manual control + Playwright report viewer
   - Copy or ensure `artifacts/playwright-report` is present (download from CI if helpful).
   - Create a backup of the server environment (zip or Docker snapshot).

4. Deploy/host static pages for easier viewing (optional, 15 min)
   - If using GitHub Pages or the deploy workflow, ensure the Pages deployment shows the placeholder site.
   - Alternatively, continue serving via the backend on the laptop.

5. Volunteer runbook dry run (15–30 min)
   - Walk through start, simulate failures, practice recovery.

Total prep: ~1–2 hours depending on polish choices. Aim to finish these steps at least 30–60 minutes before the event.

---

## Runbook — step-by-step (for volunteers on event day)

Pre-event (30–60 minutes before start)
1. Open terminal, navigate to repo root.
2. If using virtualenv:
   - python -m venv .venv
   - Activate: `. .venv/Scripts/activate` (Windows) or `source .venv/bin/activate` (macOS/Linux)
3. Install deps (if not preinstalled):
   - python -m pip install -r server/requirements.txt
   - npm ci
   - npx playwright install --with-deps
4. Start backend:
   - python -m uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000
   - Confirm output contains "Uvicorn running" and "0.0.0.0:8000" or similar.
5. Quick manual validation:
   - Open browser to http://127.0.0.1:8000/welcome.html
   - Visit /checkin.html and /hold-scanner.html and ensure pages load.
6. Optional (recommended): run smoke test once:
   - npx playwright test playwright/tests/smoke.spec.ts --project=chromium
   - If it passes, you’re good. If it fails, see Troubleshooting below.

During party
- If UI needs resetting: use test-only toggles (e.g., `?showWinner=1`) or call test seed endpoints (if present) to set the expected state.
- Keep a console tab open capturing uvicorn logs and `tail -f artifacts/run-logs/*.log` (if you plan to run tests during party).

Shutdown (after event)
- Stop uvicorn (Ctrl+C)
- Save logs and artifacts:
  - zip -r PokemonParty-logs-YYYYMMDD.zip artifacts run-logs
- Create a short post-event issue with observations and improvements.

---

## Troubleshooting quick reference (most common problems)

1. 404 for static pages
   - Cause: backend not running or wrong static path.
   - Fix:
     - Confirm uvicorn process running.
     - Check server logs for StaticFiles mount error.
     - Confirm file exists: `ls frontend/*.html`

2. Port 8000 already in use
   - Fix:
     - Check process: PowerShell `netstat -ano | Select-String ":8000"` then `tasklist /FI "PID eq <pid>"`
     - Kill or use alternate port: `uvicorn server.app.main:app --port 8001` and adjust any tests (or open pages at new URL).

3. Playwright smoke fails (test timeouts or selectors not found)
   - Fix:
     - Run single test with -g to see interactive failure: `npx playwright test -g "<test name>" --debug`
     - Confirm backend endpoints return expected JSON by curl:
       - curl -s http://127.0.0.1:8000/api/health
       - curl -s http://127.0.0.1:8000/api/animals/catalog

4. Playwright report not opening at localhost:9323
   - Make sure `npx playwright show-report ./artifacts/playwright-report --port 9323` is run and that the folder contains `index.html`.
   - If missing, download artifacts from CI run: `gh run download <run-id> -D ./artifacts/playwright-report`

5. Dependency install failures (pip/npm)
   - Fix: run `python -m pip install --upgrade pip` then `pip install -r server/requirements.txt`; for Node, remove node_modules and run `npm ci`.

---

## Minimal required endpoints for the party

These are the endpoints Playwright and the static pages expect. Confirm they exist in `server/app/*` (use `/docs` when server is running):

- GET /api/health
- GET /api/animals/catalog
- POST /api/checkin/manual
- GET /api/hold/state (or /api/hold/status)
- POST /api/hold/submit
- POST /api/animals/current
- POST /api/scene/progress
- GET /api/session/status

If any are missing, add a small stub that returns deterministic responses for the event (an in-memory implementation is fine).

---

## Commands & one-liners (copy/paste)

Start backend:
```bash
python -m uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000
```

Run smoke tests:
```bash
npm ci
npx playwright install --with-deps
npx playwright test playwright/tests/smoke.spec.ts --project=chromium
```

View Playwright report (after artifacts are present):
```bash
npx playwright show-report ./artifacts/playwright-report --port 9323
# or serve statically
python -m http.server 9323 --directory ./artifacts/playwright-report
```

Download artifacts from a run:
```bash
gh run download <run-id> --repo starlightkristen/PokemonParty -D ./artifacts/playwright-report
```

Create a PR to trigger CI (safe method if workflows lack workflow_dispatch):
```bash
BR="ci/trigger-$(date -u +%Y%m%d%H%M%S)"
git checkout -b "$BR"
git commit --allow-empty -m "chore(ci): trigger CI via PR"
git push --set-upstream origin "$BR"
gh pr create --base main --head "$BR" --title "chore(ci): trigger CI run" --body "Trigger CI for diagnostics"
```

Mark workflow manual (one-time change; PR recommended):
- Add `workflow_dispatch:` under `on:` at the top of the Playwright workflow YAML.

---

## Party-specific low-risk enhancements (do before the event if possible)

1. Add a guarded `/api/test/seed` endpoint (dev-only) so tests and volunteers can set the exact winner/roster state without query strings.
2. Add a `scripts/start-party.sh` or `scripts/start-party.ps1` that:
   - activates venv,
   - starts uvicorn in background,
   - opens the welcome page in the browser,
   - runs one smoke test to confirm readiness, and
   - collects the Playwright report.
3. Pre-generate and commit a small static `frontend/demo-data.json` used by the static pages to avoid flakiness from dynamic data.
4. Add a short `RUNBOOK_FOR_VOLUNTEERS.md` that summarizes the Runbook section in pared-down checklist form (one page).

---

## Reuse notes (how to use this repo as template for other projects)

- Quick create from this template (CLI):
  ```bash
  gh repo create MyNewProject --template starlightkristen/PokemonParty --public
  ```
- When reusing, update:
  - README/title/license
  - Replace placeholder frontend pages or scaffold the SPA
  - Update Playwright tests to use project‑specific selectors/IDs
  - Parameterize playwright.config.ts baseURL via env var for multi-environment use
- Consider extracting reusable CI into a small `devops` repo if multiple teams reuse identical Playwright CI patterns.

---

## Known issues / TODO (prioritized)

1. Add Dockerfile + docker-compose for deterministic local runs (HIGH)  
2. Add `workflow_dispatch` to Playwright CI so manual runs don't require PRs (MEDIUM)  
3. Replace query-string test toggles (`?showWinner=1`) with guarded `/api/test/seed` (MEDIUM)  
4. Add `scripts/start-party.*` to reduce volunteer friction (HIGH for the party)  
5. Scaffold React+Vite to replace static placeholders when time permits (LOW for the party)  
6. Add simple monitoring/alert (Slack) for nightly smoke failures (LOW)

---

## Roles & contacts (who to ping during the event)

- Repo owner / primary contact: @starlightkristen (owner)
- If you have CODEOWNERS configured, use that to request urgent reviews.
- If the volunteer running the laptop needs immediate help, open a new issue titled `party: urgent - <short problem>` and ping @starlightkristen.

---

## Post-event wrap-up checklist

- Save and attach artifacts (Playwright report, combined logs) to a release or issue.
- Create a short postmortem (1–2 paragraphs) documenting any test flakiness or UX gaps.
- Convert any quick fixes from the event into formal PRs for the template (Docker, runbook scripts, test seed endpoint).

---

## Appendix — Helpful links & quick commands for agents

- Show default branch / template flag:
  ```bash
  gh repo view starlightkristen/PokemonParty --json defaultBranchRef,isTemplate
  ```
- List workflows:
  ```bash
  gh workflow list --repo starlightkristen/PokemonParty
  ```
- List recent runs:
  ```bash
  gh run list --repo starlightkristen/PokemonParty --limit 10
  ```
- View a run log:
  ```bash
  gh run view <run-id> --repo starlightkristen/PokemonParty --log
  ```

---

If you want, I can now:
- create this `AGENT_STATUS.md` in a branch and open a PR (ready-to-merge), or
- create the recommended `scripts/start-party.*` helper and a small Docker PR (high impact for the event).

Pick one action and I will produce the exact gh/git commands to execute it.  