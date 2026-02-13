# Ruby Asteroids: Arcade Edition

A fast-paced, "juice"-heavy hybrid of classic **Asteroids** and **Space Invaders**. Battle through endless waves of asteroids, dodge deadly UFO lasers, and collect power-up crystals to survive.

## Features
- **Dynamic Hybrid Gameplay:** Left/Right movement and vertical shooting mixed with splitting asteroids and multi-directional UFO threats.
- **Power-up System:** 
  - **Shields:** Earned via a 5-hit combo. Grants 10 seconds of invincibility with a 30-second cooldown.
  - **Weapon Crystals:** Collected from destroyed asteroids.
    - **Red (Spread):** Fires a massive 6-bullet shotgun blast.
    - **Green (Rapid):** High-speed automatic fire.
- **UFO Enemies:** Dangerous saucers that hunt you with aimed laser fire.
- **Arcade Polish:** Animated explosions, particle effects, screen shake on damage, and a 3-layer parallax starfield.
- **Persistence:** Local High Score leaderboard (JSON) and a Save/Load system to resume your progress.

## Requirements
To run this game, you need:
- **Ruby** (3.0 or higher recommended)
- **Gosu Gem:** The game engine.
- **SDL2 Libraries:** Required by Gosu for graphics and sound.

### Installation (Linux - Arch/Omarchy)
```bash
# Install system dependencies
sudo pacman -S sdl2 sdl2_ttf sdl2_image sdl2_mixer

# Install the Gosu gem
gem install gosu
```

## How to Run
Navigate to the project directory and run:
```bash
ruby asteroids.rb
```

## Controls
- **Arrows:** Move Left/Right
- **Space:** Fire Weapon / Select in Menu
- **P / Esc:** Pause Game
- **Enter:** Confirm (Menu/Name Entry)

## Creating a Standalone Executable (Windows/Linux)
You can bundle the game into a single file so others don't need Ruby installed.

### Using Ocra (Windows)
1. Install Ocra: `gem install ocra`
2. Run: `ocra asteroids.rb lib/*.rb media/* --output Asteroids.exe`

### Using AppImage (Linux)
It is recommended to use `ruby-appimage` or similar tools to bundle the Ruby environment and the Gosu shared libraries.

---
*Developed as a playground project in Ruby.*
