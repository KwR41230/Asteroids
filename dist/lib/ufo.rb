class UFO
  attr_reader :x, :y, :radius, :dead

  def initialize(image, bullet_image, side)
    @image = image
    @bullet_image = bullet_image
    @radius = 24
    @dead = false
    
    # side: 0 for left, 1 for right
    if side == 0
      @x = -@radius
      @vel_x = rand(2.0..4.0)
    else
      @x = GameWindow::WIDTH + @radius
      @vel_x = -rand(2.0..4.0)
    end
    
    @y = rand(50..200) # UFOs stay in the upper half
    @wobble_speed = rand(0.05..0.1)
    @shoot_interval = rand(1500..3000) # Shoot every 1.5 to 3 seconds
    @last_shot_time = Gosu.milliseconds
  end

  def update(player_x, player_y, bullets)
    @x += @vel_x
    # Vertical "wobble"
    @y += Math.sin(Gosu.milliseconds * @wobble_speed / 100.0) * 2
    
    shot_fired = false
    if Gosu.milliseconds - @last_shot_time > @shoot_interval
      shoot(player_x, player_y, bullets)
      @last_shot_time = Gosu.milliseconds
      shot_fired = true
    end

    # Mark dead if it leaves the screen
    if (@vel_x > 0 && @x > GameWindow::WIDTH + @radius) || (@vel_x < 0 && @x < -@radius)
      @dead = true
    end
    shot_fired
  end

  def shoot(player_x, player_y, bullets)
    # Use Gosu.angle for reliable aiming
    angle = Gosu.angle(@x, @y, player_x, player_y)
    
    # Calculate velocity vectors
    vx = Gosu.offset_x(angle, 7) # Speed 7
    vy = Gosu.offset_y(angle, 7)
    
    # Use AlienBullet class (requires: image, x, y, vx, vy)
    bullets << AlienBullet.new(@bullet_image, @x, @y, vx, vy)
  end

  def draw
    # Scale 0.05 makes a 1000px image ~50px
    @image.draw_rot(@x, @y, 4, 0, 0.5, 0.5, 0.05, 0.05)
  end

  def kill
    @dead = true
  end
end
