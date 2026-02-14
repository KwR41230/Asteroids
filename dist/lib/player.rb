class Player
  attr_reader :x, :y, :radius, :scale, :shield_scale, :armor, :max_armor
  attr_accessor :recovery_until, :shield_until, :weapon_type, :weapon_until, :base_speed

  def initialize(image)
    @image = image
    @x = GameWindow::WIDTH / 2
    @y = GameWindow::HEIGHT - 40
    @radius = 20
    @scale = 1.0
    @shield_scale = 0.45
    @recovery_until = 0
    @shield_until = 0
    @weapon_type = :normal
    @weapon_until = 0
    @base_speed = 5
    
    # Armor system
    @max_armor = 1
    @armor = @max_armor
  end

  def recovering?
    Gosu.milliseconds < @recovery_until
  end

  def shielded?
    Gosu.milliseconds < @shield_until
  end

  def draw
    if recovering?
      if (Gosu.milliseconds / 100) % 2 == 0
        @image.draw_rot(@x, @y, 1, 0, 0.5, 0.5, @scale, @scale)
      end
    else
      @image.draw_rot(@x, @y, 1, 0, 0.5, 0.5, @scale, @scale)
    end
  end

  def move_left
    @x -= @base_speed
    @x %= GameWindow::WIDTH
  end

  def move_right
    @x += @base_speed
    @x %= GameWindow::WIDTH
  end

  def upgrade_image(new_image, new_scale = 1.0, new_shield_scale = 0.5, y_offset = 0)
    @image = new_image
    @scale = new_scale
    @shield_scale = new_shield_scale
    @y -= y_offset
    @base_speed += 1.5
    
    # Upgrade Armor
    @max_armor = 2
    @armor = @max_armor
  end

  def take_damage
    if @armor > 0
      @armor -= 1
      return :damaged
    else
      return :destroyed
    end
  end

  def repair
    @armor = @max_armor
  end
end
