import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

print("Hello COMP7510 Project!")
import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv() # 加载 .env
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_KEY")

if not url or not key:
    print("❌ 找不到 URL 或 KEY，请检查 .env 文件")
else:
    supabase = create_client(url, key)
    print("✅ Supabase 连接成功！")
    
    # 试着拉取一下分类表的数据
    try:
        response = supabase.table('categories').select("*").execute()
        print("📦 成功读取分类数据：", response.data)
    except Exception as e:
        print("❌ 读取失败：", e)