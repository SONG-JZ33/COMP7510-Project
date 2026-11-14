import sys
import os

# 让 core / handlers 目录里的模块可以像课堂一样直接 import
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(BASE_DIR, 'core'))
sys.path.insert(0, os.path.join(BASE_DIR, 'handlers'))

from PySide6.QtGui import QGuiApplication
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtQml import QQmlApplicationEngine

app = QGuiApplication()
QQuickStyle.setStyle("Basic")
engine = QQmlApplicationEngine()
engine.load(os.path.join(BASE_DIR, 'qml', 'Window.qml'))

#### Handler 注册位置（页面写好后在这里实例化，和课堂一致）
# browsePageHandler = BrowsePageHandler(engine)
# itemDetailPageHandler = ItemDetailPageHandler(engine)

### app.exec() is always the last line
app.exec()
