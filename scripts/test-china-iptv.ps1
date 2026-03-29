[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== Testing China IPTV Sources ===" -ForegroundColor Green
Write-Host ""

$testUrls = @(
    @{Name="CCTV-1"; Url="http://ivi.bupt.edu.cn/hls/btv1.m3u8"},
    @{Name="CCTV-2"; Url="http://ivi.bupt.edu.cn/hls/btv2.m3u8"},
    @{Name="CCTV-3"; Url="http://ivi.bupt.edu.cn/hls/btv3.m3u8"},
    @{Name="CCTV-4"; Url="http://ivi.bupt.edu.cn/hls/btv4.m3u8"},
    @{Name="CCTV-5"; Url="http://ivi.bupt.edu.cn/hls/btv5.m3u8"},
    @{Name="CCTV-6"; Url="http://ivi.bupt.edu.cn/hls/btv6.m3u8"},
    @{Name="CCTV-7"; Url="http://ivi.bupt.edu.cn/hls/btv7.m3u8"},
    @{Name="CCTV-8"; Url="http://ivi.bupt.edu.cn/hls/btv8.m3u8"},
    @{Name="CCTV-9"; Url="http://ivi.bupt.edu.cn/hls/btv9.m3u8"},
    @{Name="CCTV-10"; Url="http://ivi.bupt.edu.cn/hls/btv10.m3u8"},
    @{Name="CCTV-11"; Url="http://ivi.bupt.edu.cn/hls/btv11.m3u8"},
    @{Name="CCTV-12"; Url="http://ivi.bupt.edu.cn/hls/btv12.m3u8"},
    @{Name="CCTV-13"; Url="http://ivi.bupt.edu.cn/hls/btv13.m3u8"},
    @{Name="CCTV-14"; Url="http://ivi.bupt.edu.cn/hls/btv14.m3u8"},
    @{Name="CCTV-15"; Url="http://ivi.bupt.edu.cn/hls/btv15.m3u8"},
    @{Name="CETV-1"; Url="http://117.161.133.51:81/gitv_live/G_CETV-1/G_CETV-1.m3u8"},
    @{Name="BRTV-BJ"; Url="http://ivi.bupt.edu.cn/hls/btv1.m3u8"},
    @{Name="DF-WS"; Url="http://ivi.bupt.edu.cn/hls/dfws.m3u8"},
    @{Name="ZJ-WS"; Url="http://evi.bupt.edu.cn/hls/zjws.m3u8"},
    @{Name="JS-WS"; Url="http://ivi.bupt.edu.cn/hls/jsws.m3u8"},
    @{Name="HN-WS"; Url="http://evi.bupt.edu.cn/hls/xnws.m3u8"},
    @{Name="AH-WS"; Url="http://evi.bupt.edu.cn/hls/ahws.m3u8"},
    @{Name="SD-WS"; Url="http://evi.bupt.edu.cn/hls/sdws.m3u8"},
    @{Name="GD-WS"; Url="http://evi.bupt.edu.cn/hls/gdws.m3u8"},
    @{Name="SZ-WS"; Url="http://evi.bupt.edu.cn/hls/szws.m3u8"}
)

$stable = @()

foreach($item in $testUrls) {
    Write-Host ("Testing " + $item.Name + "...") -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $item.Url -Method HEAD -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host " OK" -ForegroundColor Green
            $stable += $item
        } else {
            Write-Host " FAIL" -ForegroundColor Red
        }
    } catch {
        Write-Host " FAIL" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host ("=== Result ===") -ForegroundColor Green
Write-Host ("Stable: " + $stable.Count)
Write-Host ""

# Generate m3u
$m3u = "#EXTM3X`n`n"
foreach($ch in $stable) {
    $m3u += "#EXTINF:-1 tvg-name=`"" + $ch.Name + "`"," + $ch.Name + "`n"
    $m3u += $ch.Url + "`n`n"
}

$outputPath = "C:\Users\test\.qclaw\workspace\iptv-china.m3u"
$m3u | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host ("File saved: " + $outputPath) -ForegroundColor Green
