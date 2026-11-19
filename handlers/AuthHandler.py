from PySide6.QtCore import QObject, Signal, Slot
from core.DataManager import DataManager

class AuthHandler(QObject):
    # Define signals to notify the QML UI about login results
    loginSuccess = Signal()
    loginFailed = Signal(str) # Pass error message to QML
    signUpSuccess = Signal(str)
    signUpFailed = Signal(str)
    logoutSuccess = Signal()
    @Slot(str, str)
    def handleLogin(self, email, password):
        if not email or not password:
            self.loginFailed.emit("Email and password cannot be empty!")
            return

        db = DataManager.get_db()
        try:
            # Call Supabase Auth to sign in
            response = db.auth.sign_in_with_password({"email": email, "password": password})
            
            # Login successful, save current user state
            DataManager.set_current_user(response.user)
            self.loginSuccess.emit()
            
        except Exception as e:
            # Login failed (wrong password, user doesn't exist, etc.)
            error_msg = str(e)
            if "Invalid login credentials" in error_msg:
                self.loginFailed.emit("Invalid email or password!")
            else:
                self.loginFailed.emit(f"Login failed: {error_msg}")

    @Slot()
    def handleLogout(self):
        db = DataManager.get_db()
        db.auth.sign_out()
        DataManager.set_current_user(None)
        print("🚪 User logged out")
        self.logoutSuccess.emit()
    @Slot(str, str)
    def handleSignUp(self, email, password):
        if not email or not password:
            self.signUpFailed.emit("Email and password cannot be empty!")
            return

        db = DataManager.get_db()
        try:
            # 调用 Supabase 的注册接口
            res = db.auth.sign_up({"email": email, "password": password})
            
            # 如果开启了邮箱验证，res.user 会有数据，但 session 可能是空的
            self.signUpSuccess.emit("Registration successful! You can now sign in.")
        except Exception as e:
            error_msg = str(e)
            if "already registered" in error_msg:
                self.signUpFailed.emit("This email is already registered!")
            else:
                self.signUpFailed.emit(f"Sign up failed: {error_msg}")