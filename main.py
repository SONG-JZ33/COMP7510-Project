import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from handlers.AuthHandler import AuthHandler

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    
    # Initialize backend logic Handler
    auth_handler = AuthHandler()
    
    engine = QQmlApplicationEngine()
    
    # Register Python object to QML context so QML can call it
    engine.rootContext().setContextProperty("authHandler", auth_handler)
    
    # Load main interface
    engine.load("qml/Main.qml")
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())