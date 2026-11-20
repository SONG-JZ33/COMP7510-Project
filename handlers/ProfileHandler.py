from PySide6.QtCore import QObject, Signal, Slot
from core.DataManager import DataManager

class ProfileHandler(QObject):
    profileLoaded = Signal(str, str) # 用于把 (email, nickname) 传给 QML
    updateSuccess = Signal(str)
    updateFailed = Signal(str)

    @Slot()
    def loadProfile(self):
        user = DataManager.get_current_user()
        if not user: 
            return
        
        db = DataManager.get_db()
        try:
            # 从 users 表里查询当前用户
            res = db.table('users').select('*').eq('email', user.email).execute()
            if res.data:
                nickname = res.data[0].get('nickname', '')
                self.profileLoaded.emit(user.email, nickname)
            else:
                self.profileLoaded.emit(user.email, "")
        except Exception as e:
            print("❌ Failed to retrieve profile information:", e)

    @Slot(str)
    def updateNickname(self, new_nickname):
        user = DataManager.get_current_user()
        if not user: 
            return
        
        db = DataManager.get_db()
        try:
            # 更新 users 表里的 nickname
            db.table('users').update({'nickname': new_nickname}).eq('email', user.email).execute()
            self.updateSuccess.emit("✅ Nickname updated successfully！")
        except Exception as e:
            self.updateFailed.emit(f"❌ Update failed: {str(e)}")