import os
from supabase import *
from datetime import datetime
from types import SimpleNamespace
from dotenv import load_dotenv

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load_dotenv(os.path.join(BASE_DIR, '.env'))  # 从根目录 .env 读取 SUPABASE_URL 和 SUPABASE_KEY


class _DataManager:
    _instance = None

    user = SimpleNamespace()
    user.email = 'demo@demo.com'
    user.name = 'Demo Demo'

    supabase: Client = None
    url = os.environ.get('SUPABASE_URL')      # 从 .env 读取
    api_key = os.environ.get('SUPABASE_KEY')

    _current_user = None

    def __new__(cls, *args, **kwargs):
        # 保证无论 DataManager() 还是 dataManager 都拿到同一个实例
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        # 已初始化过就不再重建客户端
        if self.supabase is not None:
            return
        self.supabase = create_client(self.url, self.api_key)

    def toLocalTime(self, utc_time: str):
        utc_time = datetime.fromisoformat(utc_time)
        # 使用系统本地时区
        return utc_time.astimezone().strftime('%Y-%m-%d %I:%M %p')

    # 登录注册模块使用的类方法入口
    @classmethod
    def get_db(cls):
        return dataManager.supabase

    @classmethod
    def set_current_user(cls, user_data):
        cls._current_user = user_data
        if user_data is None:
            guest = SimpleNamespace()
            guest.email = 'demo@demo.com'
            guest.name = 'Demo Demo'
            dataManager.user = guest
        else:
            dataManager.user = user_data
        print('Current user:', getattr(user_data, 'email', None) or 'None')

    @classmethod
    def get_current_user(cls):
        return cls._current_user


dataManager = _DataManager()
DataManager = _DataManager
