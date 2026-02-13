class Powerup
  attr_reader :x, :y, :radius, :type, :dead

  def initialize(x, y, type, animation)
    @x = x
    @y = y
    @type = type # :spread or :rapid
    @animation = animation
    @radius = 15
    @speed = 2
    @dead = false
    @current_frame = 0
  end

  def update
    @y += @speed
    # Simple animation loop
    if Gosu.milliseconds % 100 < 20
        @current_frame = (@current_frame + 1) % @animation.size
    end
    @dead = true if @y > GameWindow::HEIGHT + @radius
  end

  def draw
    image = @animation[@current_frame]
    image.draw_rot(@x, @y, 2, 0)
  end

  def collect
    @dead = true
  end
end
