# Pokemon Party Startup Script
# Run this script to prepare and start the party environment
# Usage: .\scripts\start-party.ps1

param(
    [string]$Port = "8000",
    [switch]$SkipTests,
    [switch]$OpenBrowser
)

$ErrorActionPreference = 'Stop'
Write-Host "[INFO] Starting Pokemon Party setup..." -ForegroundColor Cyan

# 1. Check we're in repo root
if (-not (Test-Path ".git")) {
    Write-Host "[FAIL] Not in a git repository. Please cd to the PokemonParty root." -ForegroundColor Red
    exit 1
}

# 2. Check required files exist
$requiredFiles = @(
    "server\app\main.py",
    "frontend\welcome.html",
    "frontend\checkin.html",
    "frontend\hold-scanner.html"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "[WARN] Missing expected file: $file" -ForegroundColor Yellow
    }
}

# 3. Activate venv if present
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "[INFO] Activating Python virtual environment..."
    & ".\.venv\Scripts\Activate.ps1"
} else {
    Write-Host "[WARN] No .venv found. Using system Python." -ForegroundColor Yellow
}

# 4. Check dependencies
Write-Host "[INFO] Checking Python dependencies..."
$pipList = pip list 2>$null
if ($pipList -match "fastapi" -and $pipList -match "uvicorn") {
    Write-Host "[PASS] Python dependencies look good." -ForegroundColor Green
} else {
    Write-Host "[WARN] Missing Python dependencies. Installing..." -ForegroundColor Yellow
    python -m pip install -r server\requirements.txt
}

Write-Host "[INFO] Checking Node dependencies..."
if (Test-Path "node_modules") {
    Write-Host "[PASS] node_modules present." -ForegroundColor Green
} else {
    Write-Host "[INFO] Installing Node dependencies..."
    npm ci
}

# 5. Check Playwright browsers
$playwrightCheck = npx playwright --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[PASS] Playwright is installed." -ForegroundColor Green
} else {
    Write-Host "[INFO] Installing Playwright browsers..."
    npx playwright install --with-deps
}

# 6. Run smoke test if requested
if (-not $SkipTests) {
    Write-Host "[INFO] Running smoke test to verify environment..."
    $testResult = npx playwright test playwright\tests\smoke.spec.ts --project=chromium --reporter=list 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] Smoke tests passed!" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Smoke tests failed. Review output above." -ForegroundColor Yellow
        Write-Host "       You can continue anyway, but some features may not work." -ForegroundColor Yellow
        $continue = Read-Host "Continue anyway? (y/n)"
        if ($continue -ne 'y') {
            exit 1
        }
    }
}

# 7. Start the backend server
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  POKEMON PARTY - READY TO START" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend will start on: http://127.0.0.1:$Port" -ForegroundColor Green
Write-Host "Welcome page:         http://127.0.0.1:$Port/welcome.html" -ForegroundColor Green
Write-Host "Check-in page:        http://127.0.0.1:$Port/checkin.html" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Open browser if requested
if ($OpenBrowser) {
    Start-Sleep -Seconds 2
    Start-Process "http://127.0.0.1:$Port/welcome.html"
}

# Start uvicorn (this will block)
python -m uvicorn server.app.main:app --reload --host 127.0.0.1 --port $Port
