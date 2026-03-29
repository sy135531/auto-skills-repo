import sys
import json
import requests
import os
import re
from datetime import datetime, timedelta

# 预编译正则表达式，提升性能
DATE_RANGE_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}to\d{4}-\d{2}-\d{2}')


def baidu_search(api_key, requestBody: dict):
    url = "https://qianfan.baidubce.com/v2/ai_search/web_search"

    headers = {
        "Authorization": f"Bearer {api_key}",
        "X-Appbuilder-From": "openclaw",
        "Content-Type": "application/json"
    }

    # 使用POST方法发送JSON数据
    response = requests.post(url, json=requestBody, headers=headers)
    response.raise_for_status()
    results = response.json()
    if "code" in results:
        raise Exception(results["message"])
    datas = results["references"]
    # 在循环外定义要删除的键，避免重复创建集合
    keys_to_remove = ("snippet",)
    for item in datas:
        for key in keys_to_remove:
            item.pop(key, None)
    return datas


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python baidu_search.py <Json>")
        sys.exit(1)

    query = sys.argv[1]
    parse_data = {}
    try:
        parse_data = json.loads(query)
        print(f"success parse request body: {parse_data}")
    except json.JSONDecodeError as e:
        print(f"JSON parse error: {e}")

    if "query" not in parse_data:
        print("Error: query must be present in request body.")
        sys.exit(1)
    count = 10
    search_filter = {}
    if "count" in parse_data:
        count = int(parse_data["count"])
        if count <= 0:
            count = 10
        elif count > 50:
            count = 50
    current_time = datetime.now()
    end_date = (current_time + timedelta(days=1)).strftime("%Y-%m-%d")
    if "freshness" in parse_data:
        freshness = parse_data["freshness"]
        if freshness in ("pd", "pw", "pm", "py"):
            if freshness == "pd":
                start_date = (current_time - timedelta(days=1)).strftime("%Y-%m-%d")
            elif freshness == "pw":
                start_date = (current_time - timedelta(days=6)).strftime("%Y-%m-%d")
            elif freshness == "pm":
                start_date = (current_time - timedelta(days=30)).strftime("%Y-%m-%d")
            else:  # freshness == "py"
                start_date = (current_time - timedelta(days=364)).strftime("%Y-%m-%d")
            search_filter = {"range": {"page_time": {"gte": start_date, "lt": end_date}}}
        elif DATE_RANGE_PATTERN.match(freshness):
            start_date = freshness.split("to")[0]
            end_date = freshness.split("to")[1]
            search_filter = {"range": {"page_time": {"gte": start_date, "lt": end_date}}}
        else:
            print(f"Error: freshness ({freshness}) must be pd, pw, pm, py, or match YYYY-MM-DDtoYYYY-MM-DD.")
            sys.exit(1)

    # We will pass these via env vars for security
    api_key = os.getenv("BAIDU_API_KEY")

    if not api_key:
        print("Error: BAIDU_API_KEY must be set in environment.")
        sys.exit(1)

    request_body = {
        "messages": [
            {
                "content": parse_data["query"],
                "role": "user"
            }
        ],
        "search_source": "baidu_search_v2",
        "resource_type_filter": [{"type": "web", "top_k": count}],
        "search_filter": search_filter
    }
    try:
        results = baidu_search(api_key, request_body)
        print(json.dumps(results, indent=2, ensure_ascii=False))
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)
