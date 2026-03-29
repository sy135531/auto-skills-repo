@echo off
set HTTP_PROXY=http://root:135565@192.168.10.119:7893
set HTTPS_PROXY=http://root:135565@192.168.10.119:7893

echo 启动 Ollama 服务...
start /B "C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe" serve

echo 等待服务启动...
timeout /t 5 /nobreak >nul

echo 测试 Ollama 连接...
curl -s http://127.0.0.1:11434

echo.
echo 开始下载 qwen2:0.5b 模型...
call "C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe" pull qwen2:0.5b

pause
