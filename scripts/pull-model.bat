@echo off
set HTTP_PROXY=http://root:135565@192.168.10.119:7893
set HTTPS_PROXY=http://root:135565@192.168.10.119:7893

echo 开始下载 qwen2:0.5b 模型...
call "C:\Users\test\AppData\Local\Programs\Ollama\ollama.exe" pull qwen2:0.5b

pause
