# Contributing

Thanks for helping improve PokemonParty! This guide explains how to set up, run tests, and make a clean PR.

## Getting Started

1. **Install Python 3.10+ and Node 18+**
   
2. **Install backend dependencies:**
   ```bash
   python -m pip install -r server/requirements.txt
   ```

3. **Install Node dependencies:**
   ```bash
   npm ci
   npx playwright install --with-deps
   ```

## Run Locally

- **Start backend** (serves static frontend):
  ```bash
  uvicorn server.app.main:app --reload --host 127.0.0.1 --port 8000
  ```

- **Open UI:** http://127.0.0.1:8000/welcome.html

## Tests

- **Run full Playwright suite:**
  ```bash
  npx playwright test
  ```

- **Run a single spec:**
  ```bash
  npx playwright test playwright/tests/phase1.spec.ts
  ```

- **View test report:**
  ```bash
  npx playwright show-report
  ```

## PR Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit with descriptive messages

3. **Push and open a PR** targeting `main`

4. **Ensure CI passes** - All 8 tests must pass

5. **Add description** with:
   - Short summary of changes
   - How to test locally
   - Links to Playwright report if relevant

6. **Code review** - A code owner will review your PR

7. **Squash commits** if requested by repo policy

## Testing Guidance

- **Use stable selectors** - Prefer `data-test-id` attributes
- **For hold-scanner tests** - Use `?showWinner=1` query parameter for deterministic behavior
- **Wait for elements** - Use `waitForSelector`, `waitForLoadState('networkidle')`
- **Keep tests fast** - Current suite runs in < 10 seconds

## Code Style

- **Backend (Python):** Follow PEP 8
- **Frontend (JavaScript):** Use modern ES6+ syntax
- **Tests (TypeScript):** Follow Playwright best practices

## Questions?

Open an issue or reach out to @starlightkristen for guidance!
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