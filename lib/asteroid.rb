class Asteroid
  attr_reader :x, :y, :radius, :speed, :vel_x, :vel_y

  def initialize(image, speed, radius, x = nil, y = nil, vel_x = 0)
    @image = image
    @radius = radius
    @speed = speed
    
    # If x and y are provided (from a split), use them. 
    # Otherwise, spawn at the top.
    @x = x || rand(@radius..(GameWindow::WIDTH - @radius))
    @y = y || -@radius
    
    # Add random chaos drift if it's a new asteroid (vel_x is 0)
    # Drift increases slightly with speed
    drift_max = 1.0 + (@speed * 0.2)
    @vel_x = (vel_x == 0) ? rand(-drift_max..drift_max) : vel_x
    
    @vel_y = @speed # Primary downward movement
  end

  def update
    @x += @vel_x
    @y += @vel_y
    
    # Wrap around X just like the player
    @x %= GameWindow::WIDTH
  end

  def draw
    @image.draw_rot(@x, @y, 1, 0, 0.5, 0.5)
  end
end
