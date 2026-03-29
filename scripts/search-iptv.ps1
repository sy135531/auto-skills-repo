# GitHub IPTV 直播源搜索器
Add-Type -AssemblyName System.Net.Http

function Search-GitHubIPTV {
    $headers = @{
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "IPTV-Searcher"
    }
    
    $searchQueries = @(
        "iptv m3u8 live tv china",
        "tvbox live source m3u",
        "直播源 m3u8 国内",
        "fanmingming m3u8"
    )
    
    $results = @()
    
    foreach($query in $searchQueries) {
        Write-Host "搜索: $query ..." -ForegroundColor Cyan
        
        try {
            $url = "https://api.github.com/search/code?q=$([System.Uri]::EscapeDataString($query))+extension:m3u&per_page=5&sort=indexed"
            $response = Invoke-RestMethod -Uri $url -Headers $headers -TimeoutSec 10
            
            foreach($item in $response.items) {
                $results += [PSCustomObject]@{
                    Name = $item.name
                    Repo = $item.repository.full_name
                    URL = $item.html_url
                    Path = $item.path
                }
            }
        } catch {
            Write-Host "  搜索失败: $_" -ForegroundColor Yellow
        }
    }
    
    # 去重
    $results = $results | Sort-Object -Property Repo -Unique
    
    return $results
}

function Get-IPTVSources {
    Write-Host "=== GitHub IPTV 直播源搜索 ===" -ForegroundColor Green
    Write-Host ""
    
    # 常见的高质量 IPTV 仓库
    $repos = @(
        "fanmingming/live",
        "iptv-org/iptv",
        "CaoZ/CCTV-Resources",
        "zhangboheng/IPTV"
    )
    
    $workingSources = @()
    
    foreach($repo in $repos) {
        Write-Host "检查: $repo ..." -ForegroundColor Cyan
        
        # 尝试获取 raw 文件
        $urls = @(
            "https://raw.githubusercontent.com/$repo/main/live.m3u",
            "https://raw.githubusercontent.com/$repo/master/live.m3u",
            "https://raw.githubusercontent.com/$repo/main/CCTV.m3u",
            "https://raw.githubusercontent.com/$repo/master/CCTV.m3u",
            "https://raw.githubusercontent.com/$repo/main/TV.m3u",
            "https://raw.githubusercontent.com/$repo/master/TV.m3u"
        )
        
        foreach($url in $urls) {
            try {
                Write-Host "  测试: $url" -ForegroundColor Gray
                $response = Invoke-WebRequest -Uri $url -Method HEAD -TimeoutSec 5 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Host "  ✅ 找到有效源!" -ForegroundColor Green
                    $workingSources += [PSCustomObject]@{
                        Repo = $repo
                        URL = $url
                        Size = $response.Headers["Content-Length"]
                    }
                    break
                }
            } catch {
                # 继续尝试下一个
            }
        }
    }
    
    return $workingSources
}

# 运行搜索
Write-Host ""
$results = Get-IPTVSources

Write-Host ""
Write-Host "=== 搜索结果 ===" -ForegroundColor Green

if ($results.Count -gt 0) {
    foreach($r in $results) {
        Write-Host ""
        Write-Host "📺 仓库: $($r.Repo)" -ForegroundColor Yellow
        Write-Host "🔗 地址: $($r.URL)" -ForegroundColor Cyan
        Write-Host "📦 大小: $([math]::Round([int]$r.Size/1MB, 2)) MB" -ForegroundColor Gray
    }
} else {
    Write-Host "未找到有效的直播源" -ForegroundColor Red
}
