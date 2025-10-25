# Phase 1 Playwright Test Package

Contains Playwright Phase 1 tests, CI workflow and helper scripts.

Run locally:
1) Start backend:
   uvicorn server.app.main:app --host 127.0.0.1 --port 8000
2) (Optional) Generate placeholder audio:
   python scripts/generate_placeholder_audio.py
3) Run tests:
   bash scripts/run_playwright.sh

Playwright report: playwright-report/
