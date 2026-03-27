# Windows Performance Optimization
Write-Host "=== Windows Performance Mode ===" -ForegroundColor Cyan

# Visual Effects - Best Performance
Write-Host "[1] Visual Effects..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

# Disable Animations
Write-Host "[2] Disable Animations..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

# Disable Transparency
Write-Host "[3] Disable Transparency..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

# Disable Services
Write-Host "[4] Optimize Services..." -ForegroundColor Yellow
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

# Memory Optimization
Write-Host "[5] Memory Optimization..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 0 -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

Write-Host ""
Write-Host "=== Complete ===" -ForegroundColor Green
Write-Host "Please restart your computer for all changes to take effect." -ForegroundColor Yellow
