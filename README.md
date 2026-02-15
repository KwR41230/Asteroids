# Ruby Asteroids: Arcade Edition

A fast-paced, "juice"-heavy hybrid of classic **Asteroids** and **Space Invaders**. Battle through endless waves of asteroids, dodge deadly UFO lasers, and collect power-up crystals to survive.

## Features
- **Dynamic Hybrid Gameplay:** Left/Right movement mixed with splitting asteroids and Boss battles.
- **Boss Fights:** Encounter the "Void Reaver" every 5 levels with unique attack patterns and themes.
- **Power-up System:** 
  - **Shields:** Earned via combos.
  - **Crystals:** Repair your armor (Cyan), fire Rapidly (Green), or use the 6-bullet Spread (Red).
- **Ship Upgrades:** Defeat bosses to earn permanent speed, armor, and weapon evolutions.
- **Arcade Polish:** Chromatic aberration title, dynamic smoke/fire damage effects, and parallax starfields.
- **Persistence:** Local High Score leaderboard and Save/Load system.

---

## Installation & Running (For Players)

### Linux (Pop!_OS, Ubuntu, Debian)
If you have received the `dist` folder, follow these steps:

#### 1. One-Time Setup
Open your terminal inside the `dist` folder and run the installer script. This will automatically install Ruby and the necessary game libraries:
```bash
chmod +x install_and_run.sh
./install_and_run.sh
```

#### 2. Add to App Menu (Optional)
To launch the game from your Applications menu with a custom icon:
1. Open the terminal in your `dist` folder.
2. Run:
   ```bash
   mkdir -p ~/.local/share/applications/
   cp ruby-asteroids.desktop ~/.local/share/applications/
   ```
3. *Note: You may need to right-click the desktop file and select "Allow Launching" depending on your system.*

### Windows
If you have received the `dist` folder:

#### 1. One-Time Setup
1. **Install Ruby:** Download and install **RubyInstaller (with Devkit)** from [rubyinstaller.org](https://rubyinstaller.org/). (Standard settings are fine).
2. **Install Game Libraries:** Double-click `install_on_windows.bat` in the `dist` folder. This will automatically set up the required game engine.

#### 2. Launch the Game
- Double-click `run_on_windows.bat` in the `dist` folder.

---

## Development (For Creators)

### Requirements
- **Ruby 3.0+**
- **Gosu Gem:** `gem install gosu`
- **SDL2 Libraries (Linux Only):** `sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev` (Windows users get these automatically via the gem).

### How to Run Source
```bash
ruby asteroids.rb
```

### Controls & Cheats
- **Arrows:** Move Left/Right
- **Space:** Fire Weapon / Select in Menu
- **P / Esc:** Pause Game
- **L (Cheat):** Skip to next Level
- **G (Cheat):** Toggle God Mode (Invincibility)

---
*Developed as a playground project in Ruby.*
