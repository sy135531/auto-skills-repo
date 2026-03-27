$dockerPath = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
Write-Host "Path: $dockerPath"
Write-Host "Exists: $(Test-Path $dockerPath)"
if (Test-Path $dockerPath) {
    Start-Process $dockerPath
    Write-Host "Started!"
} else {
    Write-Host "File not found"
}
