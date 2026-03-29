[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== IPTV" -NoNewline
Write-Host " - " -NoNewline
Write-Host "stable" -ForegroundColor Green
Write-Host ""

# Read m3u file
$m3uContent = Get-Content "C:\Users\test\.qclaw\workspace\iptv-cn.m3u" -Raw

# Parse channels
$channels = @()
$lines = $m3uContent -split "`n"
$currentChannel = $null

foreach($line in $lines) {
    $line = $line.Trim()
    
    if ($line -match "^#EXTINF:(-?\d+)\s+(.*),(.*)$") {
        $props = $matches[2]
        $name = $matches[3]
        
        $tvgId = ""
        if ($props -match 'tvg-id="([^"]*)"') {
            $tvgId = $matches[1]
        }
        
        $currentChannel = [PSCustomObject]@{
            Name = $name
            URL = ""
            TvgId = $tvgId
        }
    }
    elseif ($line -and $line.StartsWith("http") -and $currentChannel) {
        $currentChannel.URL = $line
        $channels += $currentChannel
        $currentChannel = $null
    }
}

Write-Host ("Found " + $channels.Count + " channels, testing...")
Write-Host ""

# Priority channels
$priorityNames = @("CCTV-1", "CCTV-2", "CCTV-3", "CCTV-4", "CCTV-5", 
    "CCTV-6", "CCTV-7", "CCTV-8", "CCTV-9", "CCTV-10",
    "CCTV-11", "CCTV-12", "CCTV-13", "CCTV-14", "CCTV-15", "CCTV-16", "CCTV-17",
    "Beijing", "BRTV", "东方", "浙江", "江苏", "湖南", "安徽", "山东", "广东", "深圳",
    "Phoenix", "Hunan", "Anhui", "Shandong", "Guangdong", "Jiangsu", "Zhejiang")

$priorityChannels = $channels | Where-Object {
    $name = $_.Name
    foreach($p in $priorityNames) {
        if ($name -match [regex]::Escape($p)) {
            return $true
        }
    }
    return $false
}

$stableChannels = @()
$totalTested = 0

foreach($ch in $priorityChannels) {
    if (-not $ch.URL) { continue }
    
    $totalTested++
    Write-Host ("[" + $totalTested + "] " + $ch.Name + "...") -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $ch.URL -Method HEAD -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host " OK" -ForegroundColor Green
            $stableChannels += $ch
        } else {
            Write-Host " FAIL" -ForegroundColor Red
        }
    } catch {
        Write-Host " FAIL" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host ("Tested: " + $totalTested + " | Stable: " + $stableChannels.Count)
Write-Host ""

# Generate m3u file
$m3uOutput = "#EXTM3X`n`n"
foreach($ch in $stableChannels) {
    $m3uOutput += "#EXTINF:-1 tvg-id=`"$($ch.TvgId)`" tvg-name=`"$($ch.Name)`",$($ch.Name)`n"
    $m3uOutput += "$($ch.URL)`n`n"
}

$outputPath = "C:\Users\test\.qclaw\workspace\iptv-stable.m3u"
$m3uOutput | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "=== Stable Channels ===" -ForegroundColor Green
Write-Host ""

foreach($ch in $stableChannels) {
    Write-Host $ch.Name -ForegroundColor Yellow
    Write-Host "  " + $ch.URL -ForegroundColor Cyan
}

Write-Host ""
Write-Host ("Saved to: " + $outputPath) -ForegroundColor Green
Write-Host ("Total stable channels: " + $stableChannels.Count) -ForegroundColor Green
