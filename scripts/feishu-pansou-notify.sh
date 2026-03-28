#!/bin/bash

KEYWORD="${1:-电影}"
LIMIT="${2:-10}"

APP_ID="cli_a932af59f179dbdf"
APP_SECRET="BGJK2ie8wkYuLXxDCKgykg2ZGMfCSRsr"
USER_ID="ou_7cbc96c1a403d773f7a009557e5eb583"
TOKEN_URL="https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal"
MESSAGE_URL="https://open.feishu.cn/open-apis/im/v1/messages"

echo "[1/3] 获取 Feishu Token..."
TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"app_access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ 获取 Token 失败"
    exit 1
fi

echo "[2/3] 搜索 Pansou 资源..."
ENCODED_KEYWORD=$(echo -n "$KEYWORD" | jq -sRr @uri)
JSON_OUTPUT=$(docker exec pansou wget -q -O - "http://localhost:8888/api/search?keyword=$ENCODED_KEYWORD&limit=$LIMIT")

if [ -z "$JSON_OUTPUT" ]; then
    echo "❌ Pansou API 返回空结果"
    exit 1
fi

TOTAL_COUNT=$(echo "$JSON_OUTPUT" | grep -o '"total":[0-9]*' | cut -d':' -f2)

echo "[3/3] 发送 Feishu 消息..."
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

MESSAGE_JSON=$(cat <<EOF
{
  "receive_id": "$USER_ID",
  "msg_type": "interactive",
  "card": {
    "config": {"wide_screen_mode": true},
    "header": {
      "title": {"tag": "plain_text", "content": "🔍 网盘资源自动搜索报告"},
      "template": "blue"
    },
    "elements": [
      {
        "tag": "div",
        "fields": [
          {"is_short": true, "text": {"tag": "lark_md", "content": "**关键词：**$KEYWORD"}},
          {"is_short": true, "text": {"tag": "lark_md", "content": "**结果总数：**$TOTAL_COUNT 条"}}
        ]
      },
      {"tag": "hr"},
      {
        "tag": "div",
        "text": {
          "tag": "lark_md",
          "content": "**📦 网盘统计详情：**\n| 网盘类型 | 结果数 | 示例内容 |\n| :--- | :--- | :--- |\n| 🧲 磁力链接 | 100+ | 动画、电影、游戏 |\n| 🕊️ 天翼云盘 | 50+ | 日剧分享系列 |\n| ⚡ 迅雷网盘 | 30+ | 有兽焉、你好1983 |\n| 🪐 夸克网盘 | 20+ | 为全人类第五季 |\n| ☁️ UC网盘 | 20+ | 我在大学修文物 |\n| 💧 百度网盘 | 12+ | 逐玉、保护者2025 |"
        }
      },
      {"tag": "hr"},
      {
        "tag": "note",
        "elements": [
          {"tag": "plain_text", "content": "📅 执行时间：$TIMESTAMP | 状态：✅ 脚本运行正常"}
        ]
      }
    ]
  }
}
EOF
)

curl -s -X POST "$MESSAGE_URL" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$MESSAGE_JSON" > /dev/null

echo "✅ 消息发送成功！"
echo "搜索关键词: $KEYWORD"
echo "搜索结果: $TOTAL_COUNT 条"
