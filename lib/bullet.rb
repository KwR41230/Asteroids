class Bullet
  attr_reader :x, :y, :radius

  def initialize(image, x, y, angle = 0)
    @image = image
    @x = x
    @y = y
    @radius = 5
    @speed = 10
    
    # Calculate velocity based on angle (0 is straight up)
    # Convert degrees to radians for Math functions
    @vel_x = Math.sin(angle * Math::PI / 180.0) * @speed
    @vel_y = -Math.cos(angle * Math::PI / 180.0) * @speed
  end

  def update
    @x += @vel_x
    @y += @vel_y
  end

  def draw
    @image.draw_rot(@x, @y, 1, 0)
  end
end
