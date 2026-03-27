# Daily GitHub Auto Sync
# Auto commit and push to GitHub
$ErrorActionPreference = "Stop"

$workspace = "C:\Users\test\.qclaw\workspace"
Set-Location $workspace

Write-Host "[1/4] Checking git status..."
$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to commit"
    exit 0
}

Write-Host "[2/4] Staging files..."
git add .

Write-Host "[3/4] Generating commit message..."
$prompt = @"
Generate a short git commit message (max 50 chars).
Based on these changed files:
$($status | Select-Object -First 10)

Format: type: description
Types: feat/fix/docs/style/refactor/chore
Return only the commit message.
"@

try {
    $body = @{
        model = "qclaw/modelroute"
        messages = @(@{ role = "user"; content = $prompt })
        max_tokens = 50
        temperature = 0.3
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "http://127.0.0.1:19000/proxy/llm/v1/chat/completions" `
        -Method Post -ContentType "application/json" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 30
    
    $commitMsg = $response.choices[0].message.content.Trim() -replace '"', ''
} catch {
    $commitMsg = "chore: auto sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

Write-Host "[4/4] Committing and pushing..."
git commit -m $commitMsg
git push

Write-Host "Done: $commitMsg"
