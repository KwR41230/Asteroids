class Explosion
  attr_reader :dead

  def initialize(animation, x, y)
    @animation = animation
    @x = x
    @y = y
    @current_frame = 0
    @dead = false
  end

  def update
    # Advance the frame. 
    # We can use a counter to slow down the animation if it's too fast
    @current_frame += 1
    @dead = true if @current_frame >= @animation.size
  end

  def draw
    return if @dead
    image = @animation[@current_frame]
    # Draw centered on x,y
    image.draw_rot(@x, @y, 3, 0)
  end
end
