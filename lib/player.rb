class Player
  attr_reader :x, :y, :radius, :scale, :shield_scale
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
    @y -= y_offset # Move ship up if it's taller
    @base_speed += 1.5
  end
end
