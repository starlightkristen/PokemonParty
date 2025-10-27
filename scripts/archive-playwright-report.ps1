# Archive Playwright report directory into a timestamped zip for upload or local archiving
# Usage: .\scripts\archive-playwright-report.ps1
param(
  [string]$ReportDir = ".\playwright-report",
  [string]$OutDir = ".\artifacts\reports"
)

if (-not (Test-Path $ReportDir)) {
  Write-Error "Playwright report directory not found: $ReportDir"
  exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outZip = Join-Path $OutDir "playwright-report-$timestamp.zip"
if (Test-Path $outZip) { Remove-Item $outZip -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory((Resolve-Path $ReportDir).Path, (Resolve-Path $outZip).Path)
Write-Output "Archived Playwright report to $outZip"