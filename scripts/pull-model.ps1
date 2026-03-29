[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:HTTP_PROXY = "http://root:135565@192.168.10.119:7893"
$env:HTTPS_PROXY = "http://root:135565@192.168.10.119:7893"

Write-Host "HTTP_PROXY: $($env:HTTP_PROXY)"
Write-Host "开始下载 qwen2:0.5b..."

& 'C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe' pull qwen2:0.5b
