class Toast
  def initialize(font, title, desc)
    @font = font
    @title = title
    @desc = desc
    @x = 1024 # Start off-screen right
    @y = 100
    @timer = Gosu.milliseconds + 5000 # Show for 5 seconds
    @state = :sliding_in
  end

  def update
    case @state
    when :sliding_in
      @x -= 10
      @state = :visible if @x <= 1024 - 250
    when :visible
      @state = :sliding_out if Gosu.milliseconds > @timer - 500
    when :sliding_out
      @x += 10
    end
  end

  def draw
    # Draw Background box
    Gosu.draw_rect(@x, @y, 240, 60, Gosu::Color.rgba(50, 50, 50, 200), 100)
    Gosu.draw_rect(@x, @y, 5, 60, Gosu::Color::YELLOW, 101) # Side accent
    
    # Draw Text
    @font.draw_text(@title, @x + 15, @y + 10, 101, 1, 1, Gosu::Color::YELLOW)
    # Using a smaller scale for the description
    @font.draw_text(@desc, @x + 15, @y + 35, 101, 0.6, 0.6, Gosu::Color::WHITE)
  end

  def dead?
    Gosu.milliseconds > @timer && @x >= 1024
  end
end
