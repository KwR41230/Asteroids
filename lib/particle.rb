class Particle
  attr_reader :dead

  def initialize(image, x, y)
    @image = image
    @x = x
    @y = y
    @vel_x = rand(-3.0..3.0)
    @vel_y = rand(-3.0..3.0)
    @angle = rand(0..360)
    @opacity = 255
    @dead = false
    @scale = rand(0.5..1.2)
  end

  def update
    @x += @vel_x
    @y += @vel_y
    @opacity -= 15
    @dead = true if @opacity <= 0
  end

  def draw
    color = Gosu::Color.rgba(255, 255, 255, @opacity)
    @image.draw_rot(@x, @y, 2, @angle, 0.5, 0.5, @scale, @scale, color)
  end
end
