@echo off
set RUBY_BIN=ruby_portable\binuby.exe

if not exist %RUBY_BIN% (
    echo [ERROR] Portable Ruby not found!
    echo Please right-click 'setup_portable.ps1' and select 'Run with PowerShell' first.
    pause
    exit /b
)

echo Starting Ruby Asteroids (Portable Mode)...
%RUBY_BIN% asteroids.rb
if %errorlevel% neq 0 (
    echo.
    echo Game crashed.
    pause
)
