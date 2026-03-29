[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$env:HTTP_PROXY = "http://root:135565@192.168.10.119:7893"
$env:HTTPS_PROXY = "http://root:135565@192.168.10.119:7893"

Write-Host "=== 启动 Ollama 服务 ==="
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe'
$psi.Arguments = 'serve'
$psi.UseShellExecute = $false
$psi.EnvironmentVariables['HTTP_PROXY'] = 'http://root:135565@192.168.10.119:7893'
$psi.EnvironmentVariables['HTTPS_PROXY'] = 'http://root:135565@192.168.10.119:7893'
$psi.EnvironmentVariables['NO_PROXY'] = 'localhost,127.0.0.1'

$process = [System.Diagnostics.Process]::Start($psi)
Write-Host "Ollama 服务已启动 (PID: $($process.Id))"

Write-Host "等待服务就绪..."
Start-Sleep 5

Write-Host ""
Write-Host "=== 下载 qwen2.5:0.5b ==="
& 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe' pull llama3.2:1b

Write-Host ""
Write-Host "=== 下载完成 ==="
