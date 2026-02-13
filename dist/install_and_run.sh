#!/bin/bash
# Move to the directory where the script is located
cd "$(dirname "$0")"

echo "=========================================="
echo "   Ruby Asteroids: Robust Installer      "
echo "=========================================="

# 1. Detect Debian/Ubuntu/Pop!_OS and install ALL required headers
if [ -f /etc/debian_version ]; then
    echo "[1/3] Linux (Debian-based) detected. Installing development headers..."
    sudo apt update
    # ruby-dev is CRITICAL for gosu to compile
    # libgl1-mesa-dev is required for the graphics engine
    sudo apt install -y ruby-full ruby-dev build-essential \
        libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev \
        libgl1-mesa-dev libfontconfig1-dev
else
    echo "This script is optimized for Pop!_OS/Ubuntu/Debian."
fi

# 2. Check for the Gosu gem
echo "[2/3] Checking for game engine (Gosu)..."
# We use sudo here because on a fresh Pop!_OS install, 
# gems usually go into a system directory unless a manager like rbenv is used.
sudo gem install gosu

# 3. Launch
echo "[3/3] Launching game..."
ruby asteroids.rb
