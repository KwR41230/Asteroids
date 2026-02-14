class Boss
  attr_reader :x, :y, :health, :max_health, :radius

  def initialize(image, bullet_image, level)
    @image = image
    @bullet_image = bullet_image
    @x = 512
    @y = -100
    @target_y = 150
    
    # Scaling Difficulty
    @max_health = 50 + (level * 10)
    @health = @max_health
    @vel_x = 3 + (level * 0.2)
    @fire_rate_multiplier = [0.4, 1.0 - (level * 0.05)].max # Shoots up to 60% faster, cap at 0.4
    
    @cooldown = 0
    @radius = 80
    
    # Attack State Machine
    @attack_state = :spread
    @state_timer = Gosu.milliseconds + 5000
    @spiral_angle = 0
  end

  def update(player_x, player_y, alien_bullets)
    if @y < @target_y
      @y += 2
      return 10
    end

    @x += @vel_x
    if @x > 1024 - 100 || @x < 100
      @vel_x *= -1
    end

    if Gosu.milliseconds > @state_timer
      states = [:spread, :spiral, :burst]
      @attack_state = states.sample
      @state_timer = Gosu.milliseconds + 5000
    end

    execute_attack(player_x, player_y, alien_bullets)
    return 0
  end

  def execute_attack(px, py, bullets)
    return unless Gosu.milliseconds > @cooldown

    case @attack_state
    when :spread
      angle_to_player = Gosu.angle(@x, @y, px, py)
      [-20, 0, 20].each do |off|
        vx = Gosu.offset_x(angle_to_player + off, 5)
        vy = Gosu.offset_y(angle_to_player + off, 5)
        bullets << AlienBullet.new(@bullet_image, @x, @y, vx, vy)
      end
      @cooldown = Gosu.milliseconds + (1200 * @fire_rate_multiplier).to_i

    when :spiral
      @spiral_angle = (@spiral_angle + 20) % 360
      vx = Gosu.offset_x(@spiral_angle, 4)
      vy = Gosu.offset_y(@spiral_angle, 4)
      bullets << AlienBullet.new(@bullet_image, @x, @y, vx, vy)
      @cooldown = Gosu.milliseconds + (100 * @fire_rate_multiplier).to_i

    when :burst
      angle = Gosu.angle(@x, @y, px, py)
      vx = Gosu.offset_x(angle, 7)
      vy = Gosu.offset_y(angle, 7)
      bullets << AlienBullet.new(@bullet_image, @x, @y, vx, vy)
      @cooldown = Gosu.milliseconds + (300 * @fire_rate_multiplier).to_i
    end
  end

  def draw
    color = Gosu::Color::WHITE
    if @health < @max_health * 0.3
      red_pulse = 150 + Math.sin(Gosu.milliseconds / 100.0) * 100
      color = Gosu::Color.rgba(255, (255 - red_pulse).to_i, (255 - red_pulse).to_i, 255)
    end
    
    @image.draw_rot(@x, @y, 2, 0, 0.5, 0.5, 0.5, 0.5, color)
    
    # Health Bar
    bar_width = 300
    fill_width = (@health.to_f / @max_health) * bar_width
    Gosu.draw_rect(512 - 150, 20, bar_width, 15, Gosu::Color::RED, 100)
    Gosu.draw_rect(512 - 150, 20, fill_width, 15, Gosu::Color::GREEN, 101)
    
    @name_font ||= Gosu::Font.new(20)
    @name_font.draw_text("VOID REAVER - PHASE: #{@attack_state.upcase}", 512 - 100, 40, 101, 1, 1, Gosu::Color::WHITE)
  end

  def take_damage(amount)
    old_health_percentage = (@health.to_f / @max_health * 100).to_i
    @health -= amount
    new_health_percentage = (@health.to_f / @max_health * 100).to_i
    
    # Check if we passed a 25% milestone (75, 50, 25)
    [75, 50, 25].each do |milestone|
      if old_health_percentage >= milestone && new_health_percentage < milestone
        return :drop_powerup
      end
    end
    false
  end

  def dead?
    @health <= 0
  end
end

class AlienBullet
  attr_reader :x, :y, :radius
  def initialize(image, x, y, vx, vy)
    @image = image
    @x, @y = x, y
    @vx, @vy = vx, vy
    @radius = 8
  end

  def update
    @x += @vx
    @y += @vy
  end

  def draw
    @image.draw_rot(@x, @y, 1, 0)
  end
end
