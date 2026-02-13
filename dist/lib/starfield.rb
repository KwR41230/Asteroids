class Starfield
  class Star
    attr_reader :y
    def initialize(speed, layer)
      @x = rand(0..GameWindow::WIDTH)
      @y = rand(0..GameWindow::HEIGHT)
      @speed = speed
      @layer = layer
    end

    def update
      @y += @speed
      @y = 0 if @y > GameWindow::HEIGHT
    end

    def draw
      color = Gosu::Color.rgba(255, 255, 255, 100 + (@layer * 50))
      size = 1 + @layer
      Gosu.draw_rect(@x, @y, size, size, color, 0)
    end
  end

  def initialize
    @stars = []
    40.times { @stars << Star.new(0.5, 0) }
    20.times { @stars << Star.new(1.0, 1) }
    10.times { @stars << Star.new(2.0, 2) }
  end

  def update
    @stars.each(&:update)
  end

  def draw
    @stars.each(&:draw)
  end
end
