$path = "C:\Users\test\.docker\daemon.json"
$bytes = [System.IO.File]::ReadAllBytes($path)
Write-Host "File size: $($bytes.Length) bytes"
Write-Host "First 5 bytes (hex):"
for ($i = 0; $i -lt 5; $i++) {
    Write-Host ("{0:X2} " -f $bytes[$i]) -NoNewline
}
Write-Host ""
Write-Host "JSON validation:"
try {
    $content = Get-Content $path -Raw
    $json = $content | ConvertFrom-Json
    Write-Host "OK - mirrors: $($json.'registry-mirrors' -join ', ')"
} catch {
    Write-Host "ERROR: $_"
}
