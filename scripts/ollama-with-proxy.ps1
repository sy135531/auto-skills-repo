$env:HTTP_PROXY = "http://root:135565@192.168.10.119:7893"
$env:HTTPS_PROXY = "http://root:135565@192.168.10.119:7893"

Write-Host "启动 Ollama 服务..."
$process = Start-Process -FilePath 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe' -ArgumentList 'serve' -WindowStyle Hidden -PassThru

Write-Host "等待服务启动..."
Start-Sleep 5

Write-Host "测试 Ollama 连接..."
$response = Invoke-WebRequest -Uri 'http://127.0.0.1:11434' -Method GET -UseBasicParsing
Write-Host $response.Content

Write-Host ""
Write-Host "开始下载 qwen2:0.5b 模型..."
& 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe' pull qwen2:0.5b
