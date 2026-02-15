@echo off
echo ========================================
echo   Ruby Asteroids: Dependency Installer
echo ========================================
echo.
echo Checking for Ruby...
ruby -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ruby is not installed! 
    echo Please install Ruby from https://rubyinstaller.org/ first.
    echo Make sure to check "Add Ruby executables to your PATH".
    pause
    exit /b
)

echo [INFO] Ruby found. Installing Gosu game library...
call gem install gosu --no-document

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Dependencies installed!
    echo You can now run 'run_on_windows.bat' to play.
) else (
    echo.
    echo [ERROR] Failed to install dependencies. 
    echo Try right-clicking this file and selecting "Run as Administrator".
)
pause
