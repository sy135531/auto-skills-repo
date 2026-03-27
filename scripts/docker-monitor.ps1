# Docker Status Monitor
$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Docker Status Monitor" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker service
Write-Host "[1/5] Checking Docker service..."
try {
    $service = Get-Service -Name "com.docker.service" -ErrorAction Stop
    Write-Host "  Service: $($service.Status)" -ForegroundColor $(if ($service.Status -eq 'Running') { 'Green' } else { 'Red' })
} catch {
    Write-Host "  Service: Not found" -ForegroundColor Yellow
}

# Check Docker version
Write-Host "[2/5] Checking Docker version..."
try {
    $version = docker --version 2>&1
    Write-Host "  $version"
} catch {
    Write-Host "  Docker CLI not accessible" -ForegroundColor Red
}

# Check running containers
Write-Host "[3/5] Checking containers..."
try {
    $containers = docker ps --format "{{.Names}}" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $count = ($containers | Measure-Object -Line).Lines
        Write-Host "  Running: $count containers"
    }
} catch {
    Write-Host "  Cannot connect to Docker" -ForegroundColor Red
}

# Check images
Write-Host "[4/5] Checking images..."
try {
    $images = docker images --format "{{.Repository}}:{{.Tag}}" 2>&1 | Select-Object -First 5
    Write-Host "  Top images:"
    foreach ($img in $images) {
        Write-Host "    - $img"
    }
} catch {}

# System info
Write-Host "[5/5] System info..."
$mem = Get-CimInstance Win32_OperatingSystem
$memUsed = [Math]::Round(($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / 1MB, 1)
$memTotal = [Math]::Round($mem.TotalVisibleMemorySize / 1MB, 1)
Write-Host "  Memory: $memUsed / $memTotal GB"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
