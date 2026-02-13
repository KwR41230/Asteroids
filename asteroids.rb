require 'gosu'

class Player
  attr_reader :x, :y
  attr_accessor :recovery_until

  def initialize(image)
    @image = image
    @x = 320
    @y = 440
    @recovery_until = 0
  end

  def recovering?
    Gosu.milliseconds < @recovery_until
  end

  def draw
    if recovering?
      if (Gosu.milliseconds / 100) % 2 == 0
        @image.draw_rot(@x, @y, 1, 0)
      end
    else
      @image.draw_rot(@x, @y, 1, 0)
    end
  end

  def move_left
    @x -= 5
    @x = 640 if @x < 0
  end

  def move_right
    @x += 5
    @x = 0 if @x > 640
  end
end

class Asteroid
  attr_reader :x, :y

  def initialize(image, speed)
    @image = image
    @x = rand(40..600)
    @y = -50
    @speed = speed
  end

  def update
    @y += @speed
  end

  def draw
    @image.draw_rot(@x, @y, 1, 0, 0.5, 0.5)
  end
end

class Bullet
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x = x
    @y = y
  end

  def update
    @y -= 10
  end

  def draw
    @image.draw_rot(@x, @y, 1, 0)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Ruby Asteroids"
    
    # Load all images ONCE
    @background_image = Gosu::Image.new("media/IngameBackground.png", tileable: true)
    @ship_image = Gosu::Image.new("media/Spaceship.png")
    @bullet_image = Gosu::Image.new("media/Bullet.png")
    @asteroid_small_image = Gosu::Image.new("media/AsteroidSmall.png")
    @asteroid_medium_image = Gosu::Image.new("media/AsteroidMedium.png")

    @bg_music = Gosu::Song.new("media/media_backmusic.m4a")
    @shoot_sound = Gosu::Sample.new("media/media_Beep.wav")
    @fire_sound = Gosu::Sample.new("media/media_fire.ogg")
    @explosion_sound = Gosu::Sample.new("media/media_explosion.ogg")

    @bg_music.play(true)
    
    @state = :menu 
    @font_large = Gosu::Font.new(60)
    @font_small = Gosu::Font.new(25)
    @font = Gosu::Font.new(20)
    
    @player = Player.new(@ship_image)
    @asteroids = []
    @bullets = []
    @score = 0
    @lives = 3
  end

  def start_game
    @bg_music.volume = 0.5
    @player = Player.new(@ship_image)
    @asteroids = []
    @bullets = []
    @score = 0
    @lives = 3
    @level = 1
    @asteroids_cleared = 0
    @state = :playing
  end

  def button_down(id)
    if @state == :menu
      start_game if id == Gosu::KB_SPACE
    elsif @state == :playing
      if id == Gosu::KB_SPACE
        @bullets << Bullet.new(@bullet_image, @player.x, @player.y)
        @shoot_sound.play(0.3)
      end
    end
  end

  def draw
    @background_image.draw(0, 0, 0)

    if @state == :menu
      @font_large.draw_text("ASTEROIDS", 160, 150, 2, 1.0, 1.0, Gosu::Color::WHITE)
      
      # Blinking effect for the start text
      if (Gosu.milliseconds / 500) % 2 == 0
        @font_small.draw_text("Press SPACE to start", 210, 240, 2, 1.0, 1.0, Gosu::Color::YELLOW)
      end
    elsif @state == :playing
      @player.draw
      @asteroids.each(&:draw)
      @bullets.each(&:draw)
      @font.draw_text("Score: #{@score}", 10, 10, 2, 1.0, 1.0, Gosu::Color::YELLOW)
      @font.draw_text("Level: #{@level}", 10, 30, 2, 1.0, 1.0, Gosu::Color::YELLOW)

      # Draw Lives (bottom left corner)
      @lives.times do |i|
        @ship_image.draw_rot(30 + (i * 35), 450, 2, 0, 0.5, 0.5, 0.5, 0.5) 
      end
    end
  end

  def update
    return unless @state == :playing

    # 1. Player Input
    @player.move_left if Gosu.button_down?(Gosu::KB_LEFT)
    @player.move_right if Gosu.button_down?(Gosu::KB_RIGHT)

    # 2. Bullet Movement & Cleanup
    @bullets.each(&:update)
    @bullets.reject! { |b| b.y < 0 }

    # 3. Asteroid Movement & Cleanup
    @asteroids.each(&:update)
    @asteroids.reject! { |a| a.y > height }

    # 4. Bullet vs Asteroid Collision
    @bullets.reject! do |bullet|
      hit_asteroid = @asteroids.find { |a| Gosu.distance(bullet.x, bullet.y, a.x, a.y) < 30 }
      if hit_asteroid
        @asteroids.delete(hit_asteroid)
        @score += 10
        @asteroids_cleared += 1

        if @asteroids_cleared >= 10
          @level += 1
          @asteroids_cleared = 0
        end
        
        @fire_sound.play(0.3)
        true # Return true to remove the bullet
      else
        false # Return false to keep the bullet
      end
    end

    # 5. Player vs Asteroid Collision
    unless @player.recovering?
      crashing_asteroid = @asteroids.find { |a| Gosu.distance(@player.x, @player.y, a.x, a.y) < 30 }
      if crashing_asteroid
        @asteroids.delete(crashing_asteroid)
        @lives -= 1
        @explosion_sound.play # Ship hit sound
        @player.recovery_until = Gosu.milliseconds + 2000 # 2 seconds of safety
        if @lives <= 0
          puts "GAME OVER! Final Score: #{@score}"
          @state = :menu
        end
      end
    end

    # 6. Random Spawning
    spawn_chance = 1 + (@level * 1)

    if rand(100) < spawn_chance
      img = rand < 0.5 ? @asteroid_small_image : @asteroid_medium_image
      speed = 3 + (@level * 0.5)
      @asteroids << Asteroid.new(img, speed)
    end
  end
end

window = GameWindow.new
window.show