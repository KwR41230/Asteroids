require 'gosu'
require_relative 'lib/player'
require_relative 'lib/asteroid'
require_relative 'lib/bullet'
require_relative 'lib/particle'
require_relative 'lib/explosion'
require_relative 'lib/high_scores'
require_relative 'lib/save_system'
require_relative 'lib/powerup'
require_relative 'lib/ufo'
require_relative 'lib/starfield'

class GameWindow < Gosu::Window
  WIDTH = 1024
  HEIGHT = 768

  def initialize
    super WIDTH, HEIGHT
    self.caption = "Ruby Asteroids"
    
    @background_image = Gosu::Image.new("media/background.jpg")
    @bg_scale_x = WIDTH.to_f / @background_image.width
    @bg_scale_y = HEIGHT.to_f / @background_image.height
    
    @starfield = Starfield.new

    @ship_image = Gosu::Image.new("media/Spaceship.png")
    @bullet_image = Gosu::Image.new("media/Bullet.png")
    @asteroid_small_image = Gosu::Image.new("media/AsteroidSmall.png")
    @asteroid_medium_image = Gosu::Image.new("media/AsteroidMedium.png")
    @shield_image = Gosu::Image.new("media/shield.png")
    @explosion_anim = Gosu::Image.load_tiles("media/explosion.png", 64, 64)
    
    @ufo_image = Gosu::Image.new("media/ufo.png")
    @alien_bullet_image = Gosu::Image.new("media/alien_bullet.png")
    
    all_crystals = Gosu::Image.load_tiles("media/crystals.png", 32, 32)
    @spread_anim = all_crystals[0..5]
    @rapid_anim = all_crystals[18..23]

    @bg_music = Gosu::Song.new("media/media_backmusic.ogg")
    @shoot_sound = Gosu::Sample.new("media/shoot.wav")
    @alien_laser_sound = Gosu::Sample.new("media/alien_laser.wav")
    @fire_sound = Gosu::Sample.new("media/media_fire.ogg")
    @explosion_sound = Gosu::Sample.new("media/media_explosion.ogg")
    @level_up_sound = Gosu::Sample.new("media/level-up.ogg")
    @menu_move_sound = Gosu::Sample.new("media/media_Beep.wav") 
    @powerup_sound = Gosu::Sample.new("media/level-up.ogg")

    @bg_music.play(true)
    
    @state = :menu 
    @menu_options = ["START NEW GAME", "LOAD GAME", "HIGH SCORES", "EXIT"]
    @menu_index = 0
    @pause_options = ["RESUME", "SAVE & EXIT", "QUIT TO MENU"]
    @pause_index = 0

    @font_large = Gosu::Font.new(80) # Increased font size for higher res
    @font_small = Gosu::Font.new(35) # Increased
    @font = Gosu::Font.new(25)       # Increased
    
    @player = Player.new(@ship_image)
    @asteroids, @bullets, @particles, @explosions, @powerups, @ufos, @alien_bullets = [], [], [], [], [], [], []
    @score, @lives, @level = 0, 3, 1
    @combo_count, @combo_timer, @shield_cooldown_until = 0, 0, 0
    @shake_amount = 0
    
    @alphabet = ("A".."Z").to_a + [" ", "."]
    @entry_chars, @entry_index = [0, 0, 0], 0
  end

  def start_game
    @bg_music.volume = 0.5
    @player = Player.new(@ship_image)
    @asteroids, @bullets, @particles, @explosions, @powerups, @ufos, @alien_bullets = [], [], [], [], [], [], []
    @score, @lives, @level, @asteroids_cleared = 0, 3, 1, 0
    @combo_count, @combo_timer, @shield_cooldown_until, @level_up_timer = 0, 0, 0, 0
    @shake_amount = 0
    @state = :playing
  end

  def save_game
    data = {
      score: @score, level: @level, lives: @lives, asteroids_cleared: @asteroids_cleared,
      shield_cooldown_until: @shield_cooldown_until,
      player: { x: @player.x, y: @player.y, shield_until: @player.shield_until, weapon_type: @player.weapon_type, weapon_until: @player.weapon_until, base_speed: @player.base_speed },
      asteroids: @asteroids.map { |a| { x: a.x, y: a.y, speed: a.speed, radius: a.radius, is_small: (a.radius < 20), vel_x: a.vel_x } }
    }
    SaveSystem.save(data)
  end

  def load_game
    data = SaveSystem.load
    return unless data
    @score, @level, @lives, @asteroids_cleared = data["score"], data["level"], data["lives"], data["asteroids_cleared"]
    @shield_cooldown_until = data["shield_cooldown_until"] || 0
    @player = Player.new(@ship_image)
    @player.instance_variable_set(:@x, data["player"]["x"])
    @player.instance_variable_set(:@y, data["player"]["y"])
    @player.shield_until = data["player"]["shield_until"] || 0
    @player.weapon_type = (data["player"]["weapon_type"] || "normal").to_sym
    @player.weapon_until = data["player"]["weapon_until"] || 0
    @player.base_speed = data["player"]["base_speed"] || 5
    @asteroids = data["asteroids"].map do |a|
      img = a["is_small"] ? @asteroid_small_image : @asteroid_medium_image
      Asteroid.new(img, a["speed"], a["radius"], a["x"], a["y"], a["vel_x"] || 0)
    end
    @bullets, @particles, @explosions, @powerups, @ufos, @alien_bullets = [], [], [], [], [], []
    @shake_amount = 0
    @state = :playing
  end

  def level_goal
    10 + (@level * 20)
  end

  def fire_bullet
    case @player.weapon_type
    when :spread
      [-25, -15, -5, 5, 15, 25].each { |ang| @bullets << Bullet.new(@bullet_image, @player.x, @player.y, ang) }
    else
      # Includes :normal and :rapid fire
      if @level >= 5
        @bullets << Bullet.new(@bullet_image, @player.x - 10, @player.y, 0)
        @bullets << Bullet.new(@bullet_image, @player.x + 10, @player.y, 0)
      else
        @bullets << Bullet.new(@bullet_image, @player.x, @player.y, 0)
      end
    end
    @shoot_sound.play(0.3)
  end

  def button_down(id)
    case @state
    when :menu then handle_menu_input(id)
    when :paused then handle_pause_input(id)
    when :high_scores then @state = :menu if [Gosu::KB_ESCAPE, Gosu::KB_RETURN, Gosu::KB_SPACE].include?(id)
    when :name_entry then handle_name_entry_input(id)
    when :game_over
      if id == Gosu::KB_SPACE || id == Gosu::KB_RETURN
        HighScores.high_enough?(@score) ? (@state = :name_entry; @entry_chars = [0,0,0]; @entry_index = 0) : @state = :menu
      end
    when :playing
      if id == Gosu::KB_SPACE && @player.weapon_type != :rapid then fire_bullet
      elsif [Gosu::KB_ESCAPE, Gosu::KB_P].include?(id) then @state = :paused; @pause_index = 0; end
    end
  end

  def handle_menu_input(id)
    case id
    when Gosu::KB_UP then @menu_index = (@menu_index - 1) % @menu_options.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_DOWN then @menu_index = (@menu_index + 1) % @menu_options.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_RETURN, Gosu::KB_SPACE then handle_menu_selection
    end
  end

  def handle_pause_input(id)
    case id
    when Gosu::KB_UP then @pause_index = (@pause_index - 1) % @pause_options.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_DOWN then @pause_index = (@pause_index + 1) % @pause_options.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_RETURN, Gosu::KB_SPACE then handle_pause_selection
    when Gosu::KB_ESCAPE, Gosu::KB_P then @state = :playing
    end
  end

  def handle_menu_selection
    case @menu_options[@menu_index]
    when "START NEW GAME" then start_game
    when "LOAD GAME" then load_game if SaveSystem.save_exists?
    when "HIGH SCORES" then @state = :high_scores
    when "EXIT" then close
    end
  end

  def handle_pause_selection
    case @pause_options[@pause_index]
    when "RESUME" then @state = :playing
    when "SAVE & EXIT" then save_game; @state = :menu
    when "QUIT TO MENU" then @state = :menu
    end
  end

  def handle_name_entry_input(id)
    case id
    when Gosu::KB_UP then @entry_chars[@entry_index] = (@entry_chars[@entry_index] - 1) % @alphabet.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_DOWN then @entry_chars[@entry_index] = (@entry_chars[@entry_index] + 1) % @alphabet.size; @menu_move_sound.play(0.5, 1.5)
    when Gosu::KB_LEFT then @entry_index = (@entry_index - 1) % 3; @menu_move_sound.play(0.5, 1.2)
    when Gosu::KB_RIGHT then @entry_index = (@entry_index + 1) % 3; @menu_move_sound.play(0.5, 1.2)
    when Gosu::KB_RETURN, Gosu::KB_SPACE
      if @entry_index < 2 then @entry_index += 1
      else
        name = @entry_chars.map { |i| @alphabet[i] }.join.strip
        HighScores.add_score(name.empty? ? "???" : name, @score); @state = :high_scores
      end
    end
  end

  def draw
    off_x = rand(-@shake_amount..@shake_amount)
    off_y = rand(-@shake_amount..@shake_amount)
    
    Gosu.translate(off_x, off_y) do
      hue = (@level * 40) % 360
      bg_color = Gosu::Color.from_ahsv(255, hue, 0.3, 1.0)
      @background_image.draw(0, 0, 0, @bg_scale_x, @bg_scale_y, bg_color)
      @starfield.draw
      
      case @state
      when :menu then draw_menu
      when :high_scores then draw_high_scores
      when :name_entry then draw_name_entry
      when :playing, :level_up, :paused then draw_gameplay; draw_pause_overlay if @state == :paused
      when :game_over then draw_game_over
      end
    end
  end

  def draw_menu
    @font_large.draw_text("ASTEROIDS", WIDTH/2 - (@font_large.text_width("ASTEROIDS")/2), HEIGHT/4, 2)
    @menu_options.each_with_index do |opt, i|
      active = (opt != "LOAD GAME" || SaveSystem.save_exists?)
      color = (i == @menu_index) ? Gosu::Color::YELLOW : (active ? Gosu::Color::WHITE : Gosu::Color::GRAY)
      scale = (i == @menu_index) ? 1.2 : 1.0
      @font_small.draw_text(opt, WIDTH/2 - (@font_small.text_width(opt)*scale/2), HEIGHT/2 + (i * 60), 2, scale, scale, color)
    end
  end

  def draw_pause_overlay
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, Gosu::Color.rgba(0, 0, 0, 150), 10)
    @font_large.draw_text("PAUSED", WIDTH/2 - (@font_large.text_width("PAUSED")/2), HEIGHT/4, 11, 1, 1, Gosu::Color::YELLOW)
    @pause_options.each_with_index do |opt, i|
      color = (i == @pause_index) ? Gosu::Color::YELLOW : Gosu::Color::WHITE
      scale = (i == @pause_index) ? 1.2 : 1.0
      @font_small.draw_text(opt, WIDTH/2 - (@font_small.text_width(opt)*scale/2), HEIGHT/2 + (i * 60), 11, scale, scale, color)
    end
  end

  def draw_high_scores
    @font_large.draw_text("HIGH SCORES", WIDTH/2 - (@font_large.text_width("HIGH SCORES")/2), 50, 2, 1, 1, Gosu::Color::YELLOW)
    HighScores.load.each_with_index do |s, i|
      y = 180 + (i * 40)
      @font_small.draw_text("#{i+1}. #{s['name']}", WIDTH/2 - 200, y, 2); @font_small.draw_text(s['score'].to_s.rjust(5), WIDTH/2 + 100, y, 2, 1, 1, Gosu::Color::CYAN)
    end
    @font.draw_text("Press ESC for Menu", WIDTH/2 - (@font.text_width("Press ESC for Menu")/2), HEIGHT - 60, 2, 1, 1, Gosu::Color::GRAY)
  end

  def draw_name_entry
    @font_large.draw_text("NEW HIGH SCORE!", WIDTH/2 - (@font_large.text_width("NEW HIGH SCORE!")*0.8/2), 100, 2, 0.8, 0.8, Gosu::Color::YELLOW)
    3.times do |i|
      char = @alphabet[@entry_chars[i]]; color = (i == @entry_index) ? Gosu::Color::CYAN : Gosu::Color::WHITE
      scale = (i == @entry_index) ? 1.5 + Math.sin(Gosu.milliseconds/100.0)*0.2 : 1.5
      @font_large.draw_text(char, WIDTH/2 - 75 + (i * 70), HEIGHT/2, 2, scale, scale, color)
    end
  end

  def draw_gameplay
    @player.draw; @asteroids.each(&:draw); @bullets.each(&:draw); @particles.each(&:draw); @explosions.each(&:draw); @powerups.each(&:draw); @ufos.each(&:draw); @alien_bullets.each(&:draw)
    
    # Progress bar
    bar_w = (@asteroids_cleared.to_f / level_goal) * 150
    Gosu.draw_rect(10, 75, 154, 14, Gosu::Color::WHITE, 2)
    Gosu.draw_rect(12, 77, bar_w, 10, Gosu::Color::YELLOW, 2)

    if @player.shielded?
      pulse = Math.sin(Gosu.milliseconds/200.0)*0.05
      @shield_image.draw_rot(@player.x, @player.y, 2, 0, 0.5, 0.5, 0.4 + pulse, 0.4 + pulse, Gosu::Color.rgba(0, 150, 255, 200))
      bar_w = ([0, @player.shield_until - Gosu.milliseconds].max / 10000.0) * 150
      Gosu.draw_rect(WIDTH-170, 20, 154, 18, Gosu::Color::WHITE, 2); Gosu.draw_rect(WIDTH-168, 22, bar_w, 14, Gosu::Color::CYAN, 2)
    elsif Gosu.milliseconds < @shield_cooldown_until
      bar_w = ((@shield_cooldown_until - Gosu.milliseconds) / 30000.0) * 150
      Gosu.draw_rect(WIDTH-170, 20, 154, 18, Gosu::Color.rgba(100,100,100,255), 2); Gosu.draw_rect(WIDTH-168, 22, bar_w, 14, Gosu::Color::RED, 2)
    elsif @combo_count > 0
      bar_w = (@combo_count / 5.0) * 150
      Gosu.draw_rect(WIDTH-170, 20, 154, 18, Gosu::Color::GRAY, 2); Gosu.draw_rect(WIDTH-168, 22, bar_w, 14, Gosu::Color::YELLOW, 2)
    end
    if @player.weapon_type != :normal
      bar_w = ([0, @player.weapon_until - Gosu.milliseconds].max / 10000.0) * 150
      color = @player.weapon_type == :spread ? Gosu::Color::RED : Gosu::Color::GREEN
      Gosu.draw_rect(WIDTH-170, 50, 154, 18, Gosu::Color::WHITE, 2); Gosu.draw_rect(WIDTH-168, 52, bar_w, 14, color, 2)
    end
    @font.draw_text("Score: #{@score}", 10, 10, 2, 1, 1, Gosu::Color::YELLOW); @font.draw_text("Level: #{@level}", 10, 40, 2, 1, 1, Gosu::Color::YELLOW)
    @lives.times { |i| @ship_image.draw_rot(40 + (i * 45), HEIGHT - 40, 2, 0, 0.5, 0.5, 0.7, 0.7) }
    if @state == :level_up
      @font_large.draw_text("LEVEL COMPLETE!", WIDTH/2 - (@font_large.text_width("LEVEL COMPLETE!")/2), HEIGHT/2 - 50, 2, 1, 1, Gosu::Color::YELLOW) if (Gosu.milliseconds/500)%2 == 0
      @font_small.draw_text("Get ready for Level #{@level+1}...", WIDTH/2 - (@font_small.text_width("Get ready for Level #{@level+1}...")/2), HEIGHT/2 + 50, 2)
      @font_small.draw_text("BONUS +#{500 * @level} POINTS!", WIDTH/2 - (@font_small.text_width("BONUS +#{1000 * @level} POINTS!")/2), HEIGHT/2 + 100, 2, 1, 1, Gosu::Color::CYAN) if (Gosu.milliseconds/500)%2 == 0
    end
  end

  def draw_game_over
    @font_large.draw_text("GAME OVER", WIDTH/2 - (@font_large.text_width("GAME OVER")/2), HEIGHT/2 - 50, 2, 1, 1, Gosu::Color::RED)
    @font_small.draw_text("Final Score: #{@score}", WIDTH/2 - (@font_small.text_width("Final Score: #{@score}")/2), HEIGHT/2 + 50, 2); @font_small.draw_text("Press SPACE to continue", WIDTH/2 - (@font_small.text_width("Press SPACE to continue")/2), HEIGHT/2 + 100, 2, 1, 1, Gosu::Color::YELLOW)
  end

  def create_explosion(x, y, count = 10)
    @explosions << Explosion.new(@explosion_anim, x, y); count.times { @particles << Particle.new(@bullet_image, x, y) }
  end

  def handle_asteroid_destruction(asteroid)
    create_explosion(asteroid.x, asteroid.y, 8)
    if asteroid.radius > 20
      @asteroids << Asteroid.new(@asteroid_small_image, asteroid.speed * 1.2, 12, asteroid.x, asteroid.y, -2)
      @asteroids << Asteroid.new(@asteroid_small_image, asteroid.speed * 1.2, 12, asteroid.x, asteroid.y, 2)
    end
    if rand < 0.05
      is_spread = rand < 0.5
      @powerups << Powerup.new(asteroid.x, asteroid.y, is_spread ? :spread : :rapid, is_spread ? @spread_anim : @rapid_anim)
    end
    @score += (10 * @level); @asteroids_cleared += 1
    if Gosu.milliseconds > @shield_cooldown_until && !@player.shielded?
      @combo_count += 1; @combo_timer = Gosu.milliseconds + 1500
      if @combo_count >= 5 then @player.shield_until = Gosu.milliseconds + 10000; @shield_cooldown_until = @player.shield_until + 30000; @combo_count = 0; @powerup_sound.play(0.6) end
    end
    (@state = :level_up; @level_up_timer = Gosu.milliseconds + 2500; @level_up_sound.play(0.5)) if @asteroids_cleared >= level_goal
  end

  def update
    return if @state == :paused
    @starfield.update
    @particles.each(&:update).reject!(&:dead); @explosions.each(&:update).reject!(&:dead); @powerups.each(&:update).reject!(&:dead); @alien_bullets.each(&:update).reject! { |b| b.y > HEIGHT || b.y < 0 || b.x < 0 || b.x > WIDTH }
    @ufos.each { |u| if u.update(@player.x, @player.y, @alien_bullets); @alien_laser_sound.play(0.4) end }.reject!(&:dead)

    @shake_amount *= 0.9 if @shake_amount > 0
    @player.weapon_type = :normal if @player.weapon_type != :normal && Gosu.milliseconds > @player.weapon_until
    (fire_bullet if Gosu.milliseconds % 150 < 20) if @player.weapon_type == :rapid && Gosu.button_down?(Gosu::KB_SPACE)
    @combo_count = 0 if @combo_count > 0 && Gosu.milliseconds > @combo_timer

    if @state == :level_up
      if Gosu.milliseconds > @level_up_timer
        @level += 1; @asteroids_cleared = 0; @asteroids, @bullets, @ufos, @alien_bullets = [], [], [], []
        @shield_cooldown_until = 0; @lives += 1 if @level % 3 == 0; @player.base_speed += 0.25; @state = :playing
      end
      return
    end
    return unless @state == :playing
    @player.move_left if Gosu.button_down?(Gosu::KB_LEFT); @player.move_right if Gosu.button_down?(Gosu::KB_RIGHT)
    @bullets.each(&:update).reject! { |b| b.x < 0 || b.x > WIDTH || b.y < 0 || b.y > HEIGHT }
    @asteroids.each(&:update).reject! { |a| a.y > HEIGHT + a.radius }
    
    @powerups.reject! do |p|
      if Gosu.distance(@player.x, @player.y, p.x, p.y) < (@player.radius + p.radius)
        @player.weapon_type = p.type; @player.weapon_until = Gosu.milliseconds + 10000; @powerup_sound.play(0.8); true
      else; false; end
    end

    @bullets.reject! do |bullet|
      hit_ast = @asteroids.find { |a| Gosu.distance(bullet.x, bullet.y, a.x, a.y) < (bullet.radius + a.radius) }
      hit_ufo = @ufos.find { |u| Gosu.distance(bullet.x, bullet.y, u.x, u.y) < (bullet.radius + u.radius) }
      if hit_ast
        handle_asteroid_destruction(hit_ast); @asteroids.delete(hit_ast); @fire_sound.play(0.3); true
      elsif hit_ufo
        create_explosion(hit_ufo.x, hit_ufo.y, 15); @ufos.delete(hit_ufo); @score += (50 * @level); @explosion_sound.play; true
      else; false; end
    end
    
    unless @player.recovering?
      hit_ast = @asteroids.find { |a| Gosu.distance(@player.x, @player.y, a.x, a.y) < (@player.radius + a.radius) }
      hit_ufo = @ufos.find { |u| Gosu.distance(@player.x, @player.y, u.x, u.y) < (@player.radius + u.radius) }
      hit_bul = @alien_bullets.find { |b| Gosu.distance(@player.x, @player.y, b.x, b.y) < (@player.radius + b.radius) }
      if hit_ast || hit_ufo || hit_bul
        if @player.shielded?
          if hit_ast then handle_asteroid_destruction(hit_ast); @asteroids.delete(hit_ast)
          elsif hit_ufo then create_explosion(hit_ufo.x, hit_ufo.y, 15); @ufos.delete(hit_ufo)
          elsif hit_bul then @alien_bullets.delete(hit_bul) end
          @explosion_sound.play(0.5)
        else
          create_explosion(@player.x, @player.y, 20); @asteroids.delete(hit_ast) if hit_ast; @ufos.delete(hit_ufo) if hit_ufo; @alien_bullets.delete(hit_bul) if hit_bul
          @lives -= 1; @explosion_sound.play; @player.recovery_until = Gosu.milliseconds + 2000
          @shake_amount = 15; @state = :game_over if @lives <= 0
        end
      end
    end
    
    if rand(100) < (1 + (@level * 1.5)) then img = rand < 0.5 ? @asteroid_small_image : @asteroid_medium_image; @asteroids << Asteroid.new(img, 2 + (@level * 0.5), (img == @asteroid_small_image ? 12 : 28)) end
    ufo_limit = [1, (@level / 2).to_i].max; ufo_limit = 3 if ufo_limit > 3
    if rand(1000) < (2 + (@level * 2)) && @ufos.size < ufo_limit then @ufos << UFO.new(@ufo_image, @alien_bullet_image, rand(0..1)) end
  end
end

window = GameWindow.new
window.show
