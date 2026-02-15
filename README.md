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

If you have received the `dist` folder, follow these steps to get playing on Linux (Pop!_OS, Ubuntu, Debian):

### 1. One-Time Setup
Open your terminal inside the `dist` folder and run the installer script. This will automatically install Ruby and the necessary game libraries:
```bash
chmod +x install_and_run.sh
./install_and_run.sh
```

### 2. Add to App Menu (Optional)
To launch the game from your Applications menu with a custom icon:
1. Open the terminal in your `dist` folder.
2. Run:
   ```bash
   mkdir -p ~/.local/share/applications/
   cp ruby-asteroids.desktop ~/.local/share/applications/
   ```
3. *Note: You may need to right-click the desktop file and select "Allow Launching" depending on your system.*

---

## Development (For Creators)

### Requirements
- **Ruby 3.0+**
- **Gosu Gem:** `gem install gosu`
- **SDL2 Libraries:** `sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev`

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
