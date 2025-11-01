```markdown
# Contributing

Thanks for helping improve PokemonParty! This guide explains how to set up, run tests, and make a clean PR.

Getting started
1. Install Python 3.10+ and Node 18+.
2. Install backend deps:
   ```
   python -m pip install -r server/requirements.txt
   ```
3. Install Node deps:
   ```
   npm ci
   npx playwright install --with-deps
   ```

Run locally
- Start backend (serves static frontend):
  ```
  uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000
  ```
- Open UI: http://127.0.0.1:8000/welcome.html

Tests
- Run full Playwright suite:
  ```
  npx playwright test
  ```
- Run a single spec:
  ```
  npx playwright test playwright/tests/phase1.spec.ts
  ```

PR workflow
- Create a feature branch.
- Open a PR targeting `main`.
- Ensure CI passes. Add short description, links to Playwright report if relevant.
- Use descriptive commits and squash if requested by repo policy.

Testing guidance
- Prefer stable selectors (data-test-id).
- For hold-scanner acceptance in tests, use `?showWinner=1` when necessary.
```