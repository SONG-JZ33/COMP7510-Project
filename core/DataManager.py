import os
from supabase import *
from datetime import datetime
from types import SimpleNamespace
from dotenv import load_dotenv

load_dotenv()  # 从根目录 .env 读取 SUPABASE_URL 和 SUPABASE_KEY


class _DataManager:
    user = SimpleNamespace()
    user.email = 'demo@demo.com'
    user.name = 'Demo Demo'

    supabase: Client = None
    url = os.environ.get('SUPABASE_URL')      # 从 .env 读取
    api_key = os.environ.get('SUPABASE_KEY')

    def __init__(self):
        self.supabase = create_client(self.url, self.api_key)

    def toLocalTime(self, utc_time: str):
        utc_time = datetime.fromisoformat(utc_time)
        # 使用系统本地时区
        return utc_time.astimezone().strftime('%Y-%m-%d %I:%M %p')


dataManager = _DataManager()
