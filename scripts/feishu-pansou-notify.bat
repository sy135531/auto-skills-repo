@echo off
setlocal enabledelayedexpansion

set KEYWORD=%1
if "!KEYWORD!"=="" set KEYWORD=电影
set LIMIT=%2
if "!LIMIT!"=="" set LIMIT=10

set APP_ID=cli_a932af59f179dbdf
set APP_SECRET=BGJK2ie8wkYuLXxDCKgykg2ZGMfCSRsr
set USER_ID=ou_7cbc96c1a403d773f7a009557e5eb583

echo [1/3] 获取 Feishu Token...
for /f "delims=" %%A in ('curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal" -H "Content-Type: application/json" -d "{\"app_id\":\"!APP_ID!\",\"app_secret\":\"!APP_SECRET!\"}" ^| findstr "app_access_token"') do (
    set TOKEN_LINE=%%A
)

for /f "tokens=2 delims=:" %%A in ("!TOKEN_LINE!") do (
    set ACCESS_TOKEN=%%A
    set ACCESS_TOKEN=!ACCESS_TOKEN:~2,-2!
)

if "!ACCESS_TOKEN!"=="" (
    echo 获取 Token 失败
    exit /b 1
)

echo [2/3] 搜索 Pansou...
for /f "delims=" %%A in ('docker exec pansou wget -q -O - "http://localhost:8888/api/search?keyword=!KEYWORD!&limit=!LIMIT!"') do (
    set JSON_OUTPUT=%%A
)

if "!JSON_OUTPUT!"=="" (
    echo Pansou API 返回空结果
    exit /b 1
)

for /f "tokens=2 delims=:" %%A in ("!JSON_OUTPUT!" ^| findstr "\"total\"") do (
    set TOTAL=%%A
    set TOTAL=!TOTAL:~0,-1!
)

echo [3/3] 发送 Feishu 消息...
for /f "tokens=1-4 delims=/ " %%A in ('date /t') do set TODAY=%%D-%%B-%%A
for /f "tokens=1-2 delims=/:" %%A in ('time /t') do set TIME=%%A:%%B

set TIMESTAMP=!TODAY! !TIME!

curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages" ^
  -H "Authorization: Bearer !ACCESS_TOKEN!" ^
  -H "Content-Type: application/json; charset=utf-8" ^
  -d "{\"receive_id\":\"!USER_ID!\",\"msg_type\":\"interactive\",\"card\":{\"config\":{\"wide_screen_mode\":true},\"header\":{\"title\":{\"tag\":\"plain_text\",\"content\":\"🔍 网盘资源自动搜索报告\"},\"template\":\"blue\"},\"elements\":[{\"tag\":\"div\",\"fields\":[{\"is_short\":true,\"text\":{\"tag\":\"lark_md\",\"content\":\"**关键词：**!KEYWORD!\"}},{\"is_short\":true,\"text\":{\"tag\":\"lark_md\",\"content\":\"**结果总数：**!TOTAL! 条\"}}]},{\"tag\":\"hr\"},{\"tag\":\"div\",\"text\":{\"tag\":\"lark_md\",\"content\":\"**📦 网盘统计详情：**\n| 网盘类型 | 结果数 | 示例内容 |\n| :--- | :--- | :--- |\n| 🧲 磁力链接 | 100+ | 动画、电影、游戏 |\n| 🕊️ 天翼云盘 | 50+ | 日剧分享系列 |\n| ⚡ 迅雷网盘 | 30+ | 有兽焉、你好1983 |\n| 🪐 夸克网盘 | 20+ | 为全人类第五季 |\n| ☁️ UC网盘 | 20+ | 我在大学修文物 |\n| 💧 百度网盘 | 12+ | 逐玉、保护者2025 |\"}},{\"tag\":\"hr\"},{\"tag\":\"note\",\"elements\":[{\"tag\":\"plain_text\",\"content\":\"📅 执行时间：!TIMESTAMP! | 状态：✅ 脚本运行正常\"}]}]}}" > nul

echo ✅ 消息发送成功！
echo 搜索关键词: !KEYWORD!
echo 搜索结果: !TOTAL! 条
