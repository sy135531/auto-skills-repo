# Daily AI Briefing Generator
$ErrorActionPreference = "Stop"

$workspace = "C:\Users\test\.qclaw\workspace"
Set-Location $workspace

Write-Host "[1/5] Searching AI news..."

$searchTerms = @(
    "AI 编程助手 最新动态",
    "AI 工具 最新资讯"
)

$allResults = @()

foreach ($term in $searchTerms) {
    try {
        $body = "{\"keyword\":\"$term\"}"
        $result = Invoke-RestMethod -Uri "http://localhost:19000/proxy/prosearch/search" `
            -Method Post -ContentType "application/json" `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 30
        $allResults += $result.data.docs
    } catch {}
}

Write-Host "[2/5] Generating report..."

$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$topNews = $allResults | Select-Object -First 10

$report = "# AI 每日简报`n`n"
$report += "> 生成时间：$date`n`n"
$report += "## 今日热点`n`n"

$count = 1
foreach ($item in $topNews) {
    $title = $item.title -replace '"', ''
    $url = $item.url
    $site = $item.site
    $report += "$count. [$title]($url)`n"
    $report += "   - 来源：$site`n"
    $count++
}

$report += "`n---`n*由 AI 数字员工自动生成*"

Write-Host "[3/5] Saving report..."
$reportFile = Join-Path $workspace "AI-Daily-Briefing-$(Get-Date -Format 'yyyy-MM-dd').md"
$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "[4/5] Committing to Git..."
git add $reportFile
git commit -m "docs: AI daily briefing $(Get-Date -Format 'yyyy-MM-dd')"

Write-Host "[5/5] Pushing to GitHub..."
git push

Write-Host "Done!"
