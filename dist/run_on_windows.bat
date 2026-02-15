@echo off
echo Starting Ruby Asteroids...
ruby asteroids.rb
if %errorlevel% neq 0 (
    echo.
    echo Error: The game crashed or Ruby is not installed correctly.
    echo Make sure you have Ruby installed and the 'gosu' gem installed.
    echo Run: gem install gosu
    pause
)
