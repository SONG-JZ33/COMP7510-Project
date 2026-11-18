import sys
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(BASE_DIR, 'core'))
sys.path.insert(0, os.path.join(BASE_DIR, 'handlers'))

from BrowsePageHandler import BrowsePageHandler
from ItemDetailPageHandler import ItemDetailPageHandler
from AuthHandler import AuthHandler

from PySide6.QtGui import QGuiApplication
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
QQuickStyle.setStyle("Basic")
engine = QQmlApplicationEngine()

#### Handler 注册（必须在 engine.load 之前）
authHandler = AuthHandler()
engine.rootContext().setContextProperty("authHandler", authHandler)

browsePageHandler = BrowsePageHandler(engine)
itemDetailPageHandler = ItemDetailPageHandler(engine)

engine.load(os.path.join(BASE_DIR, 'qml', 'Main.qml'))

### app.exec() is always the last line
app.exec()
