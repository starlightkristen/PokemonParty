# Comprehensive verification script — run from repository root in PowerShell
# Requirements: gh (authenticated), git, network access

param(
    [switch]$DownloadArtifacts = $true,
    [switch]$OpenBrowser = $false
)

Write-Output "`n========================================"
Write-Output "POKEMONPARTY COMPREHENSIVE VERIFICATION"
Write-Output "========================================"
Write-Output "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

# Check prerequisites
Write-Output "=== Checking Prerequisites ==="
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh not authenticated. Run: gh auth login --web"
    exit 1
}
Write-Output "✓ gh authenticated"

if (!(Test-Path ".git")) {
    Write-Error "Not in a git repository root"
    exit 1
}
Write-Output "✓ In git repository"

$repoInfo = gh repo view --json nameWithOwner,defaultBranchRef -q '.'
$repo = ($repoInfo | ConvertFrom-Json).nameWithOwner
Write-Output "✓ Repository: $repo`n"

# 1) Git Status
Write-Output "=== 1) Git Status ==="
$currentBranch = git branch --show-current
Write-Output "Current branch: $currentBranch"
$uncommitted = git status --porcelain
if ($uncommitted) {
    Write-Output "⚠ Uncommitted changes:"
    $uncommitted | ForEach-Object { Write-Output "  $_" }
} else {
    Write-Output "✓ Working tree clean"
}
Write-Output ""

# 2) Merged PRs
Write-Output "=== 2) Recent Merged PRs (last 20) ==="
$mergedPrs = gh pr list --state merged --limit 20 --json number,title,author,mergedAt,url | ConvertFrom-Json
if ($mergedPrs -and $mergedPrs.Count -gt 0) {
    Write-Output "Total merged PRs: $($mergedPrs.Count)"
    $mergedPrs | ForEach-Object {
        $mergedDate = if ($_.mergedAt) { (Get-Date $_.mergedAt).ToString('yyyy-MM-dd HH:mm') } else { "N/A" }
        Write-Output "  #$($_.number) - $($_.title)"
        Write-Output "    By: $($_.author.login) | Merged: $mergedDate"
        Write-Output "    URL: $($_.url)"
    }
} else {
    Write-Output "⚠ No merged PRs found"
}
Write-Output ""

# 3) Open PRs
Write-Output "=== 3) Open PRs ==="
$openPrs = gh pr list --state open --json number,title,author,createdAt,url | ConvertFrom-Json
if ($openPrs -and $openPrs.Count -gt 0) {
    Write-Output "Open PRs: $($openPrs.Count)"
    $openPrs | ForEach-Object {
        Write-Output "  #$($_.number) - $($_.title)"
        Write-Output "    By: $($_.author.login) | Created: $(Get-Date $_.createdAt -Format 'yyyy-MM-dd HH:mm')"
        Write-Output "    URL: $($_.url)"
    }
} else {
    Write-Output "✓ No open PRs"
}
Write-Output ""

# 4) Recent GitHub Actions Runs
Write-Output "=== 4) Recent GitHub Actions Runs (last 10) ==="
$runs = gh run list --branch main --limit 10 --json databaseId,name,status,conclusion,createdAt,url | ConvertFrom-Json
if ($runs -and $runs.Count -gt 0) {
    $runs | ForEach-Object {
        $status = $_.status
        $conclusion = if ($_.conclusion) { $_.conclusion } else { "pending" }
        $emoji = switch ($conclusion) {
            "success" { "✓" }
            "failure" { "✗" }
            "cancelled" { "⊘" }
            default { "○" }
        }
        Write-Output "  $emoji Run #$($_.databaseId) - $($_.name)"
        Write-Output "    Status: $status | Conclusion: $conclusion"
        Write-Output "    Created: $(Get-Date $_.createdAt -Format 'yyyy-MM-dd HH:mm')"
        Write-Output "    URL: $($_.url)"
    }
} else {
    Write-Output "⚠ No workflow runs found"
}
Write-Output ""

# 5) Latest Run Details & Artifacts
Write-Output "=== 5) Latest Workflow Run Details ==="
if ($runs -and $runs.Count -gt 0) {
    $latestRun = $runs[0]
    $runId = $latestRun.databaseId
    Write-Output "Analyzing run #$runId..."
    
    # Save log
    $logDir = ".\artifacts\run-logs"
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logFile = Join-Path $logDir "run-$runId.log"
    Write-Output "Downloading logs to $logFile..."
    gh run view $runId --log > $logFile 2>&1
    Write-Output "✓ Saved logs: $logFile"
    
    # Try to download artifacts
    if ($DownloadArtifacts) {
        Write-Output "Attempting to download artifacts..."
        $artifactDir = ".\artifacts\playwright-report"
        New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null
        try {
            gh run download $runId --name "playwright-report" -D $artifactDir 2>&1
            if (Test-Path "$artifactDir\index.html") {
                Write-Output "✓ Downloaded playwright-report to $artifactDir"
                if ($OpenBrowser) {
                    Write-Output "Opening report in browser..."
                    Start-Process "$artifactDir\index.html"
                }
            } else {
                Write-Output "⚠ No playwright-report artifact found for run $runId"
            }
        } catch {
            Write-Output "⚠ Artifact download failed or no artifacts available"
        }
    }
} else {
    Write-Output "⚠ No runs to analyze"
}
Write-Output ""

# 6) File Structure Verification
Write-Output "=== 6) Critical Files Check ==="
$criticalFiles = @(
    "AGENT_STATUS.md",
    "CONTRIBUTING.md",
    "CHANGELOG.md",
    "README.md",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/workflows/playwright-ci.yml",
    ".github/workflows/nightly-smoke.yml",
    ".github/dependabot.yml",
    "playwright.config.ts",
    "server/app/main.py",
    "server/requirements.txt",
    "package.json",
    "scripts/run_playwright.sh"
)

$missing = @()
$present = @()

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        $present += $file
        $size = (Get-Item $file).Length
        Write-Output "  ✓ $file ($size bytes)"
    } else {
        $missing += $file
        Write-Output "  ✗ MISSING: $file"
    }
}
Write-Output ""

# 7) Frontend Pages Check
Write-Output "=== 7) Frontend HTML Pages ==="
$frontendFiles = Get-ChildItem -Path "frontend" -Filter "*.html" -ErrorAction SilentlyContinue
if ($frontendFiles -and $frontendFiles.Count -gt 0) {
    Write-Output "Found $($frontendFiles.Count) HTML files in frontend/:"
    $frontendFiles | ForEach-Object {
        Write-Output "  ✓ $($_.Name) ($($_.Length) bytes)"
    }
} else {
    Write-Output "⚠ No HTML files in frontend/ directory"
}
Write-Output ""

# 8) Playwright Tests Check
Write-Output "=== 8) Playwright Tests ==="
$testFiles = Get-ChildItem -Path "playwright/tests" -Filter "*.ts" -ErrorAction SilentlyContinue
if ($testFiles -and $testFiles.Count -gt 0) {
    Write-Output "Found $($testFiles.Count) test files:"
    $testFiles | ForEach-Object {
        Write-Output "  ✓ $($_.Name) ($($_.Length) bytes)"
    }
} else {
    Write-Output "⚠ No test files in playwright/tests/ directory"
}
Write-Output ""

# 9) Release Check
Write-Output "=== 9) Releases ==="
try {
    $releases = gh release list --limit 5 --json tagName,name,publishedAt,url | ConvertFrom-Json
    if ($releases -and $releases.Count -gt 0) {
        Write-Output "Found $($releases.Count) releases:"
        $releases | ForEach-Object {
            Write-Output "  • $($_.tagName) - $($_.name)"
            Write-Output "    Published: $(Get-Date $_.publishedAt -Format 'yyyy-MM-dd HH:mm')"
            Write-Output "    URL: $($_.url)"
        }
    } else {
        Write-Output "⚠ No releases found"
    }
} catch {
    Write-Output "⚠ Could not fetch releases: $($_.Exception.Message)"
}
Write-Output ""

# 10) Issues Summary
Write-Output "=== 10) Issues Summary ==="
$openIssues = gh issue list --state open --json number,title,author,createdAt | ConvertFrom-Json
$closedIssues = gh issue list --state closed --limit 10 --json number,title,closedAt | ConvertFrom-Json

Write-Output "Open issues: $($openIssues.Count)"
if ($openIssues -and $openIssues.Count -gt 0) {
    $openIssues | ForEach-Object {
        Write-Output "  • #$($_.number) - $($_.title)"
        Write-Output "    By: $($_.author.login) | Created: $(Get-Date $_.createdAt -Format 'yyyy-MM-dd')"
    }
}

Write-Output "`nRecently closed issues: $($closedIssues.Count)"
if ($closedIssues -and $closedIssues.Count -gt 0) {
    $closedIssues | ForEach-Object {
        Write-Output "  • #$($_.number) - $($_.title)"
        Write-Output "    Closed: $(Get-Date $_.closedAt -Format 'yyyy-MM-dd')"
    }
}
Write-Output ""

# Summary
Write-Output "==================================="
Write-Output "VERIFICATION SUMMARY"
Write-Output "==================================="
Write-Output "Repository: $repo"
Write-Output "Merged PRs: $($mergedPrs.Count)"
Write-Output "Open PRs: $($openPrs.Count)"
Write-Output "Latest run: $($latestRun.conclusion) (run #$($latestRun.databaseId))"
Write-Output "Critical files present: $($present.Count)/$($criticalFiles.Count)"
if ($missing.Count -gt 0) {
    Write-Output "⚠ Missing files: $($missing.Count)"
    $missing | ForEach-Object { Write-Output "  - $_" }
}
Write-Output "Frontend pages: $($frontendFiles.Count)"
Write-Output "Test files: $($testFiles.Count)"
Write-Output "Open issues: $($openIssues.Count)"
Write-Output ""

Write-Output "Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output "========================================`n"

# Save summary to file
$summaryFile = ".\artifacts\verification-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$summaryContent = @"
PokemonParty Verification Summary
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Repository: $repo

METRICS:
- Merged PRs: $($mergedPrs.Count)
- Open PRs: $($openPrs.Count)
- Latest CI Run: $($latestRun.conclusion) (#$($latestRun.databaseId))
- Critical Files: $($present.Count)/$($criticalFiles.Count) present
- Frontend Pages: $($frontendFiles.Count)
- Test Files: $($testFiles.Count)
- Open Issues: $($openIssues.Count)

MISSING FILES:
$($missing -join "`n")

LATEST RUN URL:
$($latestRun.url)

Logs saved to: .\artifacts\run-logs\run-$($latestRun.databaseId).log
Artifacts: .\artifacts\playwright-report
"@
$summaryContent | Out-File -FilePath $summaryFile -Encoding utf8
Write-Output "✓ Summary saved to: $summaryFile"
