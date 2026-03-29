[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== 测试直播源 ===" -ForegroundColor Green
Write-Host ""

$sources = @{
    "fanmingming/live" = @(
        "https://raw.githubusercontent.com/fanmingming/live/main/live.m3u",
        "https://raw.githubusercontent.com/fanmingming/live/master/live.m3u"
    )
    "iptv-org/iptv" = @(
        "https://raw.githubusercontent.com/iptv-org/iptv/master/streams/cn.m3u",
        "https://raw.githubusercontent.com/iptv-org/iptv/master/streams/tw.m3u"
    )
}

$workingSources = @()

foreach($repo in $sources.Keys) {
    Write-Host "检查: $repo" -ForegroundColor Cyan
    foreach($url in $sources[$repo]) {
        Write-Host "  测试: $url" -ForegroundColor Gray
        try {
            $response = Invoke-WebRequest -Uri $url -Method HEAD -TimeoutSec 8 -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                $size = $response.Headers["Content-Length"]
                if ($size) {
                    $sizeMB = [math]::Round([int]$size/1MB, 2)
                    Write-Host "  OK - $sizeMB MB" -ForegroundColor Green
                } else {
                    Write-Host "  OK" -ForegroundColor Green
                }
                $workingSources += [PSCustomObject]@{
                    Repo = $repo
                    URL = $url
                    Size = if($size){"$sizeMB MB"}else{"Unknown"}
                }
                break
            }
        } catch {
            Write-Host "  失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=== 有效直播源 ===" -ForegroundColor Green
foreach($s in $workingSources) {
    Write-Host ""
    Write-Host "仓库: $($s.Repo)" -ForegroundColor Yellow
    Write-Host "链接: $($s.URL)" -ForegroundColor Cyan
    Write-Host "大小: $($s.Size)" -ForegroundColor Gray
}
