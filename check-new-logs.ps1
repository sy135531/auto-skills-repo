$logFile = "C:\Users\test\AppData\Local\Docker\log\host\com.docker.backend.exe.log"
if (Test-Path $logFile) {
    $lines = Get-Content $logFile -Tail 20
    foreach ($line in $lines) {
        Write-Host $line
    }
} else {
    Write-Host "Log file not found"
}
