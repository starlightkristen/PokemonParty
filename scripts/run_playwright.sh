#!/usr/bin/env bash
set -euo pipefail
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found. Install Node (v16/18) to run Playwright tests."
  exit 1
fi

if [ ! -d node_modules ]; then
  echo "Installing Playwright..."
  npm init -y
  npm i -D @playwright/test
  npx playwright install --with-deps
fi

echo "Running Playwright Phase 1 tests..."
npx playwright test playwright/tests/phase1.spec.ts --project=chromium --workers=1
