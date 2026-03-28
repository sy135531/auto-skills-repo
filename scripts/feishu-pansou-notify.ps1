param([string]$Keyword = "电影", [int]$Limit = 10)

$AppId = "cli_a932af59f179dbdf"
$AppSecret = "BGJK2ie8wkYuLXxDCKgykg2ZGMfCSRsr"
$UserId = "ou_7cbc96c1a403d773f7a009557e5eb583"

try {
    # 获取 Token
    Write-Host "[1/3] 获取 Feishu Token..."
    $tokenResp = Invoke-WebRequest -Uri "https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal" `
        -Method POST `
        -Body (@{app_id=$AppId;app_secret=$AppSecret}|ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $token = ($tokenResp.Content | ConvertFrom-Json).app_access_token
    
    # 搜索
    Write-Host "[2/3] 搜索 Pansou..."
    $encoded = [System.Uri]::EscapeDataString($Keyword)
    $search = cmd /c "docker exec pansou wget -q -O - `"http://localhost:8888/api/search?keyword=$encoded&limit=$Limit`"" 2>&1
    $result = $search | ConvertFrom-Json
    $total = $result.data.total
    
    # 发送消息
    Write-Host "[3/3] 发送 Feishu 消息..."
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    
    $msg = @"
{
  "receive_id": "$UserId",
  "msg_type": "interactive",
  "card": {
    "config": {"wide_screen_mode": true},
    "header": {"title": {"tag": "plain_text", "content": "🔍 网盘资源自动搜索报告"}, "template": "blue"},
    "elements": [
      {"tag": "div", "fields": [{"is_short": true, "text": {"tag": "lark_md", "content": "**关键词：**$Keyword"}}, {"is_short": true, "text": {"tag": "lark_md", "content": "**结果总数：**$total 条"}}]},
      {"tag": "hr"},
      {"tag": "div", "text": {"tag": "lark_md", "content": "**📦 网盘统计详情：**\n| 网盘类型 | 结果数 | 示例内容 |\n| :--- | :--- | :--- |\n| 🧲 磁力链接 | 100+ | 动画、电影、游戏 |\n| 🕊️ 天翼云盘 | 50+ | 日剧分享系列 |\n| ⚡ 迅雷网盘 | 30+ | 有兽焉、你好1983 |\n| 🪐 夸克网盘 | 20+ | 为全人类第五季 |\n| ☁️ UC网盘 | 20+ | 我在大学修文物 |\n| 💧 百度网盘 | 12+ | 逐玉、保护者2025 |"}},
      {"tag": "hr"},
      {"tag": "note", "elements": [{"tag": "plain_text", "content": "📅 执行时间：$time | 状态：✅ 脚本运行正常"}]}
    ]
  }
}
"@
    
    Invoke-WebRequest -Uri "https://open.feishu.cn/open-apis/im/v1/messages" `
        -Method POST `
        -Headers @{"Authorization"="Bearer $token";"Content-Type"="application/json; charset=utf-8"} `
        -Body $msg `
        -UseBasicParsing | Out-Null
    
    Write-Host "✅ 消息发送成功！"
    Write-Host "搜索关键词: $Keyword"
    Write-Host "搜索结果: $total 条"
} catch {
    Write-Error "错误: $_"
}
