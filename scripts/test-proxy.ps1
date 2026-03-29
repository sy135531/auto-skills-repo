$ports = @(7890, 7891, 7892, 8080, 1080, 8443)
foreach($port in $ports) {
    Write-Host "Testing port $port..."
    try {
        $result = curl.exe -x "http://192.168.10.119:$port" -I https://registry.ollama.ai --connect-timeout 3 2>&1
        if ($result -match "200|403") {
            Write-Host "  Result: $result"
        }
    } catch {
        Write-Host "  Failed: $_"
    }
}
