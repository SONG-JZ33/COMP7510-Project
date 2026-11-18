@echo off
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Cannot find .venv\Scripts\python.exe
    echo Please run setup first.
    pause
    exit /b 1
)

echo Starting Campus Second-hand Market ...
".venv\Scripts\python.exe" main.py

if errorlevel 1 (
    echo.
    echo [ERROR] Program exited with an error. See the message above.
    pause
)
