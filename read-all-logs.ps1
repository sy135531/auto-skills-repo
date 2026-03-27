$logDir = "C:\Users\test\AppData\Local\Docker\log\host"
Get-ChildItem $logDir -Filter "*.log" | ForEach-Object {
    Write-Host "========== $($_.Name) =========="
    Get-Content $_.FullName -Tail 30 | ForEach-Object { Write-Host $_ }
    Write-Host ""
}
