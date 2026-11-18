import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
load_dotenv()

class DataManager:
    _instance = None
    _client = None
    _current_user = None # Store the currently logged-in user

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DataManager, cls).__new__(cls)
            url = os.environ.get("SUPABASE_URL")
            key = os.environ.get("SUPABASE_KEY")
            if url and key:
                cls._client = create_client(url, key)
            else:
                print("❌ SUPABASE_URL or SUPABASE_KEY not found")
        return cls._instance

    @classmethod
    def get_db(cls) -> Client:
        if cls._client is None:
            cls()
        return cls._client

    @classmethod
    def set_current_user(cls, user_data):
        cls._current_user = user_data
        print(f"👤 Current user: {cls._current_user.email if cls._current_user else 'None'}")

    @classmethod
    def get_current_user(cls):
        return cls._current_user