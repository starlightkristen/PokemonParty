# Pokemon Party Quick Start Script (PowerShell)
# Run from repo root: .\scripts\start-party.ps1

param(
    [int]$Port = 8000,
    [switch]$SkipTests
)

Write-Output "=== Pokemon Party Setup ==="
Write-Output "Port: $Port"

# Check if we're in repo root
if (-(Test-Path "server\app\main.py")) {
    Write-Error "Run this script from the repository root: .\scripts\start-party.ps1"
    exit 1
}

# 1. Activate venv if it exists
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Output "Activating virtual environment..."
    & .\.venv\Scripts\Activate.ps1
} else {
    Write-Output "No venv found at .venv - using system Python"
}

# 2. Install Python deps if needed
Write-Output "Checking Python dependencies..."
if (Test-Path "server\requirements.txt") {
    python -m pip install -q -r server\requirements.txt
}

# 3. Install Node deps if needed
if (Test-Path "package.json") {
    Write-Output "Checking Node dependencies..."
    if (!(Test-Path "node_modules")) {
        npm ci --silent
    }
}

# 4. Install Playwright browsers if needed
if (!(Test-Path "node_modules\.bin\playwright")) {
    Write-Output "Installing Playwright..."
    npx playwright install --with-deps
}

# 5. Start backend in background
Write-Output "Starting backend on port $Port..."
$uvicornJob = Start-Job -ScriptBlock {
    param($p)
    python -m uvicorn server.app.main:app --host 127.0.0.1 --port $p
} -ArgumentList $Port

Start-Sleep -Seconds 3

# 6. Check if server is running
try {
    $health = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Output "✅ Backend is running!"
} catch {
    Write-Error "❌ Backend failed to start. Check logs:"
    Receive-Job $uvicornJob
    Stop-Job $uvicornJob
    Remove-Job $uvicornJob
    exit 1
}

# 7. Open browser
Write-Output "Opening browser..."
Start-Process "http://127.0.0.1:$Port/welcome.html"

# 8. Run smoke test unless skipped
if (-not $SkipTests) {
    Write-Output "Running smoke test..."
    npx playwright test playwright\tests\smoke.spec.ts --project=chromium
    
    if ($LASTEXITCODE -eq 0) {
        Write-Output "✅ Smoke tests passed!"
    } else {
        Write-Warning "⚠️ Smoke tests failed - check output above"
    }
}

# 9. Show report if available
if (Test-Path "playwright-report\index.html") {
    Write-Output "`nPlaywright report available at: http://127.0.0.1:9323"
    Start-Process -NoNewWindow -FilePath "npx" -ArgumentList "playwright show-report --port 9323"
}

Write-Output "`n=== Setup Complete ==="
Write-Output "Backend running on: http://127.0.0.1:$Port"
Write-Output "Welcome page: http://127.0.0.1:$Port/welcome.html"
Write-Output "`nTo stop backend: Get-Job | Where-Object { `$_.State -eq 'Running' } | Stop-Job"
Write-Output "Press Ctrl+C when done, then run: Get-Job | Remove-Job"
