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
MESSAGE_URL = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=user_id"

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
    # 使用列表形式避免 shell=True 的安全风险和性能开销
    docker_cmd = [
        "docker", "exec", "pansou", "wget", "-q", "-O", "-",
        f"http://localhost:8888/api/search?keyword={encoded_keyword}&limit={limit}"
    ]
    result = subprocess.run(docker_cmd, capture_output=True, text=True)
    
    if not result.stdout:
        print("❌ Pansou API 返回空结果")
        sys.exit(1)
    
    search_result = json.loads(result.stdout)
    total_count = search_result.get("data", {}).get("total", 0)
    results_data = search_result.get("data", {}).get("results", [])
    
    print("[3/3] 发送 Feishu 消息...")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    # 动态构建网盘统计表格
    pan_stats = {}
    for item in results_data[:limit]:
        pan_type = item.get("pan_type", "未知")
        pan_stats[pan_type] = pan_stats.get(pan_type, 0) + 1
    
    table_rows = []
    pan_icons = {
        "magnet": "🧲 磁力链接",
        "tianyi": "🕊️ 天翼云盘",
        "xunlei": "⚡ 迅雷网盘",
        "quark": "🪐 夸克网盘",
        "uc": "☁️ UC网盘",
        "baidu": "💧 百度网盘"
    }
    
    for pan_type, count in sorted(pan_stats.items(), key=lambda x: -x[1]):
        icon_name = pan_icons.get(pan_type, f"📁 {pan_type}")
        table_rows.append(f"| {icon_name} | {count} 条 | 资源分享 |")
    
    table_content = "\n".join(table_rows) if table_rows else "| 暂无数据 | - | - |"
    
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
                        "content": f"**📦 网盘统计详情：**\n| 网盘类型 | 结果数 | 备注 |\n| :--- | :--- | :--- |\n{table_content}"
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
