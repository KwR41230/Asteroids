class Player
  attr_reader :x, :y, :radius
  attr_accessor :recovery_until, :shield_until, :weapon_type, :weapon_until, :base_speed

  def initialize(image)
    @image = image
    @x = GameWindow::WIDTH / 2
    @y = GameWindow::HEIGHT - 40
    @radius = 20
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
        @image.draw_rot(@x, @y, 1, 0)
      end
    else
      @image.draw_rot(@x, @y, 1, 0)
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
end
