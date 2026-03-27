# Weekly System Cleanup
$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Weekly System Cleanup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$totalCleaned = 0

# 1. Temp files
Write-Host "[1/6] Cleaning temp files..."
$tempPaths = @(
    "$env:TEMP",
    "$env:USERPROFILE\AppData\Local\Temp",
    "$env:windir\Temp"
)
foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        $totalCleaned += $size
    }
}
Write-Host "  Done" -ForegroundColor Green

# 2. Windows temp
Write-Host "[2/6] Cleaning Windows temp..."
$winTemp = "$env:windir\Temp"
if (Test-Path $winTemp) {
    $size = (Get-ChildItem -Path $winTemp -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Property Length -Sum).Sum
    Remove-Item -Path "$winTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
    $totalCleaned += $size
}
Write-Host "  Done" -ForegroundColor Green

# 3. Prefetch
Write-Host "[3/6] Cleaning Prefetch..."
$prefetch = "$env:windir\Prefetch"
if (Test-Path $prefetch) {
    Remove-Item -Path "$prefetch\*" -Force -ErrorAction SilentlyContinue
}
Write-Host "  Done" -ForegroundColor Green

# 4. Thumbnail cache
Write-Host "[4/6] Cleaning thumbnail cache..."
$thumbCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
Get-ChildItem -Path $thumbCache -Filter "thumbcache*.db" -ErrorAction SilentlyContinue | 
    ForEach-Object { 
        $totalCleaned += $_.Length
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue 
    }
Write-Host "  Done" -ForegroundColor Green

# 5. Downloads old files (30+ days)
Write-Host "[5/6] Checking old downloads..."
$downloads = "$env:USERPROFILE\Downloads"
if (Test-Path $downloads) {
    $oldFiles = Get-ChildItem -Path $downloads -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }
    $oldCount = ($oldFiles | Measure-Object).Count
    Write-Host "  Found $oldCount files older than 30 days"
    Write-Host "  (Not auto-deleting, review manually)" -ForegroundColor Yellow
}
Write-Host "  Done" -ForegroundColor Green

# 6. Docker system prune
Write-Host "[6/6] Docker cleanup..."
try {
    docker system prune -f 2>&1 | Out-Null
    Write-Host "  Docker cleaned" -ForegroundColor Green
} catch {
    Write-Host "  Skipped (Docker not accessible)" -ForegroundColor Gray
}

$totalMB = [Math]::Round($totalCleaned / 1MB, 2)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Cleanup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Space analyzed. Temp files cleared." -ForegroundColor Cyan
Write-Host ""
