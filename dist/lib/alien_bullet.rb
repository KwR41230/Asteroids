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
