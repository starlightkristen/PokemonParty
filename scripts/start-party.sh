#!/bin/bash
# Pokemon Party Quick Start Script (Bash)
# Run from repo root: bash scripts/start-party.sh

set -e

PORT="${1:-8000}"
SKIP_TESTS="${2:-false}"

echo "=== Pokemon Party Setup ==="
echo "Port: $PORT"

# Check if we're in repo root
if [ ! -f "server/app/main.py" ]; then
    echo "Error: Run this script from the repository root"
    exit 1
fi

# 1. Activate venv if it exists
if [ -d ".venv" ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
else
    echo "No venv found at .venv - using system Python"
fi

# 2. Install Python deps if needed
echo "Checking Python dependencies..."
if [ -f "server/requirements.txt" ]; then
    python -m pip install -q -r server/requirements.txt
fi

# 3. Install Node deps if needed
if [ -f "package.json" ]; then
    echo "Checking Node dependencies..."
    if [ ! -d "node_modules" ]; then
        npm ci --silent
    fi
fi

# 4. Install Playwright browsers if needed
if [ ! -f "node_modules/.bin/playwright" ]; then
    echo "Installing Playwright..."
    npx playwright install --with-deps
fi

# 5. Start backend in background
echo "Starting backend on port $PORT..."
python -m uvicorn server.app.main:app --host 127.0.0.1 --port "$PORT" > /tmp/pokemon-party-backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

sleep 3

# 6. Check if server is running
if curl -s -f "http://127.0.0.1:$PORT/api/health" > /dev/null; then
    echo "✅ Backend is running!"
else
    echo "❌ Backend failed to start. Check logs:"
    cat /tmp/pokemon-party-backend.log
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

# 7. Open browser (platform-specific)
echo "Opening browser..."
if command -v xdg-open > /dev/null; then
    xdg-open "http://127.0.0.1:$PORT/welcome.html" &
elif command -v open > /dev/null; then
    open "http://127.0.0.1:$PORT/welcome.html"
fi

# 8. Run smoke test unless skipped
if [ "$SKIP_TESTS" != "true" ]; then
    echo "Running smoke test..."
    if npx playwright test playwright/tests/smoke.spec.ts --project=chromium; then
        echo "✅ Smoke tests passed!"
    else
        echo "⚠️ Smoke tests failed - check output above"
    fi
fi

# 9. Show report if available
if [ -f "playwright-report/index.html" ]; then
    echo ""
    echo "Playwright report available at: http://127.0.0.1:9323"
    npx playwright show-report --port 9323 > /dev/null 2>&1 &
fi

echo ""
echo "=== Setup Complete ==="
echo "Backend running on: http://127.0.0.1:$PORT (PID: $BACKEND_PID)"
echo "Backend logs: /tmp/pokemon-party-backend.log"
echo "Welcome page: http://127.0.0.1:$PORT/welcome.html"
echo ""
echo "To stop backend: kill $BACKEND_PID"
echo "Press Ctrl+C when done"

# Keep script running
wait $BACKEND_PID
