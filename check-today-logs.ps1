$logDir = "C:\Users\test\AppData\Local\Docker\log\host"
Get-ChildItem $logDir -Filter "*.log" | ForEach-Object {
    $lastWrite = $_.LastWriteTime
    $size = $_.Length
    Write-Host "$($lastWrite)  $($size) bytes  $($_.Name)"
}
