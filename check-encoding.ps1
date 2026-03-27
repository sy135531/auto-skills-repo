$path = "C:\Users\test\.docker\daemon.json"
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "File size: $($bytes.Length) bytes"
Write-Host "First 20 bytes (hex):"
for ($i = 0; $i -lt [Math]::Min(20, $bytes.Length); $i++) {
    Write-Host ("{0:X2} " -f $bytes[$i]) -NoNewline
}
Write-Host ""
Write-Host "Last 20 bytes (hex):"
for ($i = [Math]::Max(0, $bytes.Length - 20); $i -lt $bytes.Length; $i++) {
    Write-Host ("{0:X2} " -f $bytes[$i]) -NoNewline
}
Write-Host ""
Write-Host "Content:"
Get-Content $path | ForEach-Object { Write-Host "LINE: $_" }
