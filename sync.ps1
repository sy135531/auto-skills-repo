# sync.ps1 - Git Auto Commit Script
# git add . -> AI commit message -> git commit -> git push

param(
    [string]$Message = "",
    [switch]$NoPush,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Info { param($text) Write-Host "[INFO] $text" -ForegroundColor Cyan }
function Write-Success { param($text) Write-Host "[OK] $text" -ForegroundColor Green }
function Write-Warn { param($text) Write-Host "[WARN] $text" -ForegroundColor Yellow }
function Write-Err { param($text) Write-Host "[ERR] $text" -ForegroundColor Red }

function Test-GitRepo {
    try { git rev-parse --git-dir 2>$null | Out-Null; return $true }
    catch { return $false }
}

function Get-CurrentBranch {
    return (git branch --show-current).Trim()
}

function Test-UnstagedChanges {
    $status = git status --porcelain
    return $status.Count -gt 0
}

function Get-GitDiffSummary {
    return git diff --cached --stat 2>$null | Out-String
}

function Get-GitDiffDetails {
    $diff = git diff --cached 2>$null
    if ($diff) { return ($diff -split "`n" | Select-Object -First 150) -join "`n" }
    return ""
}

function Invoke-AIGenerateCommitMessage {
    param([string]$DiffSummary, [string]$DiffDetails)

    Write-Info "Generating commit message with AI..."

    $prompt = "Generate a concise git commit message (max 50 chars) for these changes:`n`nStats:`n$DiffSummary`n`nDetails:`n$DiffDetails`n`nFormat: type: description. Types: feat/fix/docs/style/refactor/test/chore. Return only the message."

    try {
        $body = @{
            model = "qclaw/modelroute"
            messages = @(@{ role = "user"; content = $prompt })
            max_tokens = 100
            temperature = 0.3
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "http://127.0.0.1:19000/proxy/llm/v1/chat/completions" `
            -Method Post -ContentType "application/json" `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 30

        return $response.choices[0].message.content.Trim() -replace '"', ""
    } catch {
        Write-Warn "AI failed, using default message"
        return "chore: auto commit $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    }
}

# Main
Write-Host ""
Write-Host "=== Git Sync ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-GitRepo)) { Write-Err "Not a git repo"; exit 1 }

$branch = Get-CurrentBranch
Write-Info "Branch: $branch"
Write-Host ""

if (-not (Test-UnstagedChanges)) { Write-Warn "No changes detected"; exit 0 }

# git add
Write-Info "Running: git add ."
if (-not $DryRun) { git add . }
Write-Success "Staged"
Write-Host ""

# commit message
if ($Message) {
    $commitMsg = $Message
} else {
    $commitMsg = Invoke-AIGenerateCommitMessage -DiffSummary (Get-GitDiffSummary) -DiffDetails (Get-GitDiffDetails)
}
Write-Info "Message: $commitMsg"
Write-Host ""

# git commit
Write-Info "Running: git commit"
if (-not $DryRun) { git commit -m $commitMsg }
Write-Success "Committed"
Write-Host ""

# git push
if ($NoPush) {
    Write-Warn "Skipped push (-NoPush)"
} else {
    Write-Info "Running: git push"
    if (-not $DryRun) {
        git push
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Trying: git push -u origin $branch"
            git push -u origin $branch
        }
    }
    Write-Success "Pushed"
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
