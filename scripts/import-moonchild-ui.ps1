param(
    [string]$RepoRoot = ".",
    [string]$MoonchildFolder = ".\moonchild-ui",
    [string]$FrontendFolder = ".\frontend"
)

Write-Host "[INFO] Moonchild UI importer starting..." -ForegroundColor Cyan
Write-Host "[INFO] Repo root: $RepoRoot"
Write-Host "[INFO] Moonchild folder: $MoonchildFolder"
Write-Host "[INFO] Frontend folder: $FrontendFolder"

if (!(Test-Path $MoonchildFolder)) {
    Write-Host "[FAIL] Moonchild folder not found at $MoonchildFolder" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $FrontendFolder)) {
    Write-Host "[INFO] Frontend folder not found. Creating..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $FrontendFolder | Out-Null
}

# List of known pages
$pages = @(
    "welcome.html",
    "checkin.html",
    "habitat.html",
    "professor-intro.html",
    "starter-randomizer.html",
    "admin.html"
)

foreach ($page in $pages) {
    $src = Join-Path $MoonchildFolder $page
    $dst = Join-Path $FrontendFolder $page
    
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "[PASS] Imported $page from Moonchild." -ForegroundColor Green
    } else {
        Write-Host "[INFO] $page not found in Moonchild folder. Keeping existing version if present." -ForegroundColor Gray
    }
}

# Copy assets if present
$assetsSrc = Join-Path $MoonchildFolder "assets"
$assetsDst = Join-Path $FrontendFolder "assets"

if (Test-Path $assetsSrc) {
    if (!(Test-Path $assetsDst)) {
        New-Item -ItemType Directory -Path $assetsDst | Out-Null
    }
    Copy-Item "$assetsSrc\*" $assetsDst -Recurse -Force
    Write-Host "[PASS] Assets copied from Moonchild." -ForegroundColor Green
} else {
    Write-Host "[INFO] No assets folder in Moonchild export." -ForegroundColor Gray
}

Write-Host "[INFO] Moonchild UI import complete." -ForegroundColor Cyan
