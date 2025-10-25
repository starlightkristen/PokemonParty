<#
PowerShell "prompt pack" for gh CLI (copy-pasteable).
Run this in a PowerShell session where gh is installed and authenticated (gh auth status).
Save as prompt_pack.ps1 and dot-source it, or copy individual functions/lines into your terminal.

Usage examples:
. .\prompt_pack.ps1           # dot-source to load helper functions into session
Get-RepoSummary              # quick status
Push-And-Create-PR -Branch "chore/add-playwright-tests-ci"    # push & open PR (interactive)
Enable-AutoMerge -Branch "chore/add-playwright-tests-ci"      # request auto-merge
Wait-And-Merge -PR (Get-PRNumberByBranch -Branch "chore/add-playwright-tests-ci") -Branch "chore/add-playwright-tests-ci"
Download-PlaywrightArtifact -Branch "chore/add-playwright-tests-ci" -Destination ".\artifacts"

If you prefer one-off commands, see the "One-liners" section at the bottom.
#>

function Ensure-GhAuth {
    gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "gh is not authenticated. Launching web login..."
        gh auth login --web
    } else {
        Write-Output "gh authenticated."
    }
}

function Get-RepoSummary {
    Write-Output "Current branch: $(git branch --show-current)"
    Write-Output "Latest commit:"
    git log -1 --oneline --decorate
    Write-Output "`nFiles in last commit:"
    git show --name-only HEAD
    Write-Output "`nWorking tree status:"
    git status --porcelain
}

function Get-PRNumberByBranch {
    param(
        [Parameter(Mandatory=$true)][string]$Branch
    )
    $pr = gh pr list --head $Branch --state open --json number -q '.[0].number' 2>$null
    if (-not $pr) { Write-Error "No open PR found for branch $Branch"; return $null }
    return $pr.Trim()
}

function Push-And-Create-PR {
    param(
        [Parameter(Mandatory=$true)][string]$Branch,
        [string]$Base = "main",
        [string]$Title = "chore(test): add Playwright Phase1 tests + CI workflow",
        [string]$Body = $null
    )
    Ensure-GhAuth
    Write-Output "Pushing branch $Branch to origin..."
    git push --set-upstream origin $Branch
    if (-not $Body) {
        $Body = @'
Adds Playwright Phase 1 integration tests, a local run script, and a GitHub Actions workflow.

Run locally:
1) Start backend: uvicorn server.app.main:app --host 127.0.0.1 --port 8000
2) (Optional) Generate placeholder audio: python scripts/generate_placeholder_audio.py
3) Run tests: bash scripts/run_playwright.sh

Playwright HTML report: playwright-report/
'@
    }
    Write-Output "Creating PR from $Branch into $Base..."
    gh pr create --base $Base --head $Branch --title $Title --body $Body
}

function Enable-AutoMerge {
    param(
        [Parameter(Mandatory=$true)][string]$Branch,
        [string]$MergeMethod = "squash"  # options: squash, merge, rebase
    )
    Ensure-GhAuth
    $pr = Get-PRNumberByBranch -Branch $Branch
    if (-not $pr) { return }
    Write-Output "Enabling auto-merge for PR #$pr (method: $MergeMethod)..."
    gh pr merge $pr --auto --squash --delete-branch
}

function Wait-And-Merge {
    param(
        [Parameter(Mandatory=$true)][string]$PR,
        [Parameter(Mandatory=$true)][string]$Branch,
        [int]$PollIntervalSec = 15,
        [int]$TimeoutSec = 3600,
        [string]$MergeMethod = "squash"
    )
    Ensure-GhAuth
    $start = Get-Date
    Write-Output "Waiting for checks on PR #$PR (branch: $Branch). Timeout ${TimeoutSec}s."
    while ($true) {
        $sha = (gh pr view $PR --json headRefOid -q .headRefOid)
        if (-not $sha) { Write-Error "Could not obtain PR head SHA"; return }
        # get check runs summary for the commit
        $checkJson = gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/commits/$sha/check-runs --jq '.'
        $total = ($checkJson | ConvertFrom-Json).total_count
        $failed = (($checkJson | ConvertFrom-Json).check_runs | Where-Object { $_.conclusion -in @('failure','cancelled','timed_out') }).Count
        $pending = (($checkJson | ConvertFrom-Json).check_runs | Where-Object { $_.status -ne 'completed' }).Count
        Write-Output "Commit $sha — total checks: $total — failed: $failed — pending: $pending"
        if ($failed -gt 0) {
            Write-Output "Some checks failed. Options:"
            Write-Output "  1) Re-run workflows"
            Write-Output "  2) Open PR in browser"
            Write-Output "  3) Abort"
            $choice = Read-Host "Select 1,2 or 3"
            if ($choice -eq '1') {
                # Re-run all recent runs on the branch
                $runs = gh run list --branch $Branch --json databaseId -q '.[].databaseId'
                foreach ($r in $runs) {
                    Write-Output "Re-running run id $r ..."
                    gh run rerun $r
                }
                Write-Output "Requests to re-run workflows submitted. Continuing to poll..."
            } elseif ($choice -eq '2') {
                gh pr view $PR --web
                return
            } else {
                Write-Output "Aborting wait-and-merge."
                return
            }
        }
        if (($pending -eq 0) -and ($failed -eq 0)) {
            Write-Output "Checks passed — merging PR #$PR using method $MergeMethod..."
            $mergeFlag = if ($MergeMethod -eq "squash") { "--squash" } elseif ($MergeMethod -eq "rebase") { "--rebase" } else { "--merge" }
            gh pr merge $PR $mergeFlag --delete-branch
            Write-Output "Merged PR #$PR"
            break
        }
        $elapsed = (Get-Date) - $start
        if ($elapsed.TotalSeconds -ge $TimeoutSec) {
            Write-Error "Timeout waiting for checks (elapsed $($elapsed.TotalSeconds) seconds)."
            return
        }
        Start-Sleep -Seconds $PollIntervalSec
    }
}

function Download-PlaywrightArtifact {
    param(
        [Parameter(Mandatory=$true)][string]$Branch,
        [string]$ArtifactName = "playwright-report",
        [string]$Destination = ".\artifacts"
    )
    Ensure-GhAuth
    $runId = gh run list --branch $Branch --limit 10 --json databaseId -q '.[0].databaseId' 2>$null
    if (-not $runId) { Write-Error "No recent run found for branch $Branch"; return }
    Write-Output "Downloading artifact '$ArtifactName' from run $runId to $Destination..."
    gh run download $runId --name $ArtifactName -D $Destination
}

function Rerun-LatestWorkflows {
    param(
        [Parameter(Mandatory=$true)][string]$Branch
    )
    Ensure-GhAuth
    $ids = gh run list --branch $Branch --limit 10 --json databaseId -q '.[].databaseId'
    if (-not $ids) { Write-Output "No runs found to rerun."; return }
    foreach ($id in $ids) {
        Write-Output "Re-running run $id ..."
        gh run rerun $id
    }
}

function Add-ReviewersAndAssignees {
    param(
        [Parameter(Mandatory=$true)][string]$PR,
        [string[]]$Reviewers = @(),
        [string[]]$Assignees = @()
    )
    if ($Reviewers.Count -gt 0) {
        gh pr edit $PR --add-reviewer ($Reviewers -join ",")
    }
    if ($Assignees.Count -gt 0) {
        gh pr edit $PR --add-assignee ($Assignees -join ",")
    }
}

function Create-FailingTestIssue {
    param(
        [Parameter(Mandatory=$true)][string]$TestName,
        [string]$RunId = "",
        [string]$LogsUrl = ""
    )
    $title = "test: failing Playwright test on main — $TestName"
    $body = @"
Failing test: $TestName
Run: $RunId
Logs: $LogsUrl

Steps to reproduce:
1) Start backend: uvicorn server.app.main:app --host 127.0.0.1 --port 8000
2) (Optional) Generate placeholder audio: python scripts/generate_placeholder_audio.py
3) Run tests: bash scripts/run_playwright.sh

Expected:
- Test passes.

Actual:
- Test failed with assertion / error (attach details below).

"@
    gh issue create --title $title --body $body
}

function Create-Fix-Branch-PR {
    param(
        [Parameter(Mandatory=$true)][string]$BranchName,
        [Parameter(Mandatory=$true)][string]$CommitMessage,
        [string]$FilesToEdit = ""
    )
    # Create branch, open editor to make changes (user must edit), commit and create PR
    git checkout -b $BranchName
    Write-Output "Make your fixes now (edit files). Press Enter when ready to commit."
    Read-Host
    git add $FilesToEdit
    git commit -m $CommitMessage
    git push --set-upstream origin $BranchName
    gh pr create --base main --head $BranchName --title $CommitMessage --body "Fixes: $CommitMessage"
}

function Revert-MergedPR {
    param(
        [Parameter(Mandatory=$true)][string]$MergeCommitSha,
        [string]$RevertBranch = "revert-branch"
    )
    git checkout main
    git pull origin main
    git checkout -b $RevertBranch
    git revert -m 1 $MergeCommitSha
    git push --set-upstream origin $RevertBranch
    gh pr create --base main --head $RevertBranch --title "revert: revert $MergeCommitSha" --body "Reverting merge commit $MergeCommitSha"
}

function Add-CODEOWNERS-PR {
    param(
        [string]$Owner = "@your-username",
        [string]$Branch = "add-codeowners"
    )
    mkdir -Force ".github" 2>$null | Out-Null
    $path = ".github/CODEOWNERS"
    "@$($Owner) *" | Out-File -FilePath $path -Encoding utf8
    git add $path
    git commit -m "chore: add CODEOWNERS"
    git push --set-upstream origin $Branch
    gh pr create --base main --head $Branch --title "chore: add CODEOWNERS" --body "Adds CODEOWNERS to request reviews from $Owner"
}

function Protect-Branch-RequireCheck {
    param(
        [Parameter(Mandatory=$true)][string]$Branch = "main",
        [Parameter(Mandatory=$true)][string[]]$Contexts
    )
    # This uses gh api to set branch protection. Replace OWNER/REPO with the repo from gh repo view.
    $ownerRepo = gh repo view --json nameWithOwner -q .nameWithOwner
    $payload = @{
        required_status_checks = @{
            strict = $true
            contexts = $Contexts
        }
        enforce_admins = $true
        required_pull_request_reviews = @{
            dismiss_stale_reviews = $true
            require_code_owner_reviews = $false
        }
        restrictions = $null
    } | ConvertTo-Json -Depth 10
    gh api --method PUT "repos/$ownerRepo/branches/$Branch/protection" -f body="$payload"
    Write-Output "Protection request sent for $ownerRepo branch $Branch (contexts: $($Contexts -join ','))"
}

# ---------- One-liners / Quick copy-paste commands (PowerShell friendly) ----------
Set-Alias gp Get-PRNumberByBranch

# Quick push & create PR example:
# $body = @'
# PR body lines...
# '@
# git push --set-upstream origin chore/add-playwright-tests-ci
# gh pr create --base main --head chore/add-playwright-tests-ci --title "chore(test): add Playwright Phase1 tests + CI workflow" --body $body

# Quick enable auto-merge (one-liner)
# $pr = (gh pr list --head "chore/add-playwright-tests-ci" --state open --json number -q '.[0].number').Trim(); gh pr merge $pr --auto --squash --delete-branch

# Quick download artifact example:
# $run = gh run list --branch "chore/add-playwright-tests-ci" --limit 1 --json databaseId -q '.[0].databaseId'; gh run download $run --name playwright-report -D .\artifacts

# Quick run Playwright locally (one-liner)
# Start backend in background (PowerShell):
# Start-Process -NoNewWindow -FilePath pwsh -ArgumentList '-Command "python -m uvicorn server.app.main:app --host 127.0.0.1 --port 8000"' 
# Then:
# python scripts/generate_placeholder_audio.py
# bash scripts/run_playwright.sh
# npx playwright show-report

# End of prompt pack
Write-Output "Prompt pack loaded. Use the functions above or copy the one-liners. Run Ensure-GhAuth to check auth state first."
