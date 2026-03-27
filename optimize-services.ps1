# Windows System Services Optimization
Write-Host "=== System Services Optimization ===" -ForegroundColor Cyan
Write-Host ""

# SysMain (Superfetch) - Disable for SSD users
Write-Host "[1] Disabling SysMain (Superfetch)..." -ForegroundColor Yellow
try {
    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# DiagTrack (Connected User Experiences)
Write-Host "[2] Disabling DiagTrack..." -ForegroundColor Yellow
try {
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# dmwappushservice
Write-Host "[3] Disabling dmwappushservice..." -ForegroundColor Yellow
try {
    Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# Fax Service
Write-Host "[4] Disabling Fax..." -ForegroundColor Yellow
try {
    Stop-Service -Name "Fax" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "Fax" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# PrintNotify
Write-Host "[5] Disabling PrintNotify..." -ForegroundColor Yellow
try {
    Stop-Service -Name "PrintNotify" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "PrintNotify" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# RemoteRegistry
Write-Host "[6] Disabling RemoteRegistry..." -ForegroundColor Yellow
try {
    Stop-Service -Name "RemoteRegistry" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "RemoteRegistry" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "   Done" -ForegroundColor Green
} catch {
    Write-Host "   Skipped" -ForegroundColor Gray
}

# Xbox Services (if not using Xbox)
Write-Host "[7] Disabling Xbox services..." -ForegroundColor Yellow
$xboxServices = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc")
foreach ($svc in $xboxServices) {
    try {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    } catch {}
}
Write-Host "   Done" -ForegroundColor Green

Write-Host ""
Write-Host "=== Complete ===" -ForegroundColor Green
Write-Host "Services optimized for best performance." -ForegroundColor Cyan
