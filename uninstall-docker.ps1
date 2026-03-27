$installerPath = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
if (Test-Path $installerPath) {
    Write-Host "Found: $installerPath"
    Write-Host "Running uninstall..."
    Start-Process $installerPath -ArgumentList "uninstall" -Verb RunAs
    Write-Host "Uninstall started!"
} else {
    Write-Host "Installer not found at: $installerPath"
}
