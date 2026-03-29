$env:HTTP_PROXY = "http://root:135565@192.168.10.119:7893"
$env:HTTPS_PROXY = "http://root:135565@192.168.10.119:7893"
$env:http_proxy = "http://root:135565@192.168.10.119:7893"
$env:https_proxy = "http://root:135565@192.168.10.119:7893"

Write-Host "=== 启动 Ollama 服务 ==="
$ollamaPath = 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe'
$ollamaArgs = @('serve')

# 使用 Start-Process 启动服务，继承当前进程的环境变量
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $ollamaPath
$psi.Arguments = [string]::Join(' ', $ollamaArgs)
$psi.UseShellExecute = $false
$psi.EnvironmentVariables['HTTP_PROXY'] = 'http://root:135565@192.168.10.119:7893'
$psi.EnvironmentVariables['HTTPS_PROXY'] = 'http://root:135565@192.168.10.119:7893'
$psi.EnvironmentVariables['http_proxy'] = 'http://root:135565@192.168.10.119:7893'
$psi.EnvironmentVariables['https_proxy'] = 'http://root:135565@192.168.10.119:7893'

$process = [System.Diagnostics.Process]::Start($psi)

Write-Host "等待服务启动..."
Start-Sleep 5

Write-Host ""
Write-Host "=== 下载 qwen2:0.5b 模型 ==="

# 在当前进程中运行 pull 命令
& $ollamaPath pull qwen2:0.5b

Write-Host ""
Write-Host "下载完成!"
