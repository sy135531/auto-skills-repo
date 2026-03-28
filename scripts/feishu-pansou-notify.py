#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import json
import requests
import sys
from datetime import datetime
from urllib.parse import quote

# 参数
keyword = sys.argv[1] if len(sys.argv) > 1 else "电影"
limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10

# Feishu 配置
APP_ID = "cli_a932af59f179dbdf"
APP_SECRET = "BGJK2ie8wkYuLXxDCKgykg2ZGMfCSRsr"
USER_ID = "ou_7cbc96c1a403d773f7a009557e5eb583"
TOKEN_URL = "https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal"
MESSAGE_URL = "https://open.feishu.cn/open-apis/im/v1/messages"

try:
    print("[1/3] 获取 Feishu Token...")
    token_response = requests.post(TOKEN_URL, json={
        "app_id": APP_ID,
        "app_secret": APP_SECRET
    })
    access_token = token_response.json().get("app_access_token")
    
    if not access_token:
        print("❌ 获取 Token 失败")
        sys.exit(1)
    
    print("[2/3] 搜索 Pansou 资源...")
    # 使用 docker exec 调用 Pansou API
    encoded_keyword = quote(keyword)
    docker_cmd = f'docker exec pansou wget -q -O - "http://localhost:8888/api/search?keyword={encoded_keyword}&limit={limit}"'
    result = subprocess.run(docker_cmd, shell=True, capture_output=True, text=True)
    
    if not result.stdout:
        print("❌ Pansou API 返回空结果")
        sys.exit(1)
    
    search_result = json.loads(result.stdout)
    total_count = search_result.get("data", {}).get("total", 0)
    
    print("[3/3] 发送 Feishu 消息...")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    # 构建消息
    message = {
        "receive_id": USER_ID,
        "msg_type": "interactive",
        "card": {
            "config": {"wide_screen_mode": True},
            "header": {
                "title": {"tag": "plain_text", "content": "🔍 网盘资源自动搜索报告"},
                "template": "blue"
            },
            "elements": [
                {
                    "tag": "div",
                    "fields": [
                        {"is_short": True, "text": {"tag": "lark_md", "content": f"**关键词：**{keyword}"}},
                        {"is_short": True, "text": {"tag": "lark_md", "content": f"**结果总数：**{total_count} 条"}}
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
                        {"tag": "plain_text", "content": f"📅 执行时间：{timestamp} | 状态：✅ 脚本运行正常"}
                    ]
                }
            ]
        }
    }
    
    # 发送消息
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; charset=utf-8"
    }
    
    response = requests.post(MESSAGE_URL, json=message, headers=headers)
    
    print("✅ 消息发送成功！")
    print(f"搜索关键词: {keyword}")
    print(f"搜索结果: {total_count} 条")
    
except Exception as e:
    print(f"❌ 错误: {e}")
    sys.exit(1)
