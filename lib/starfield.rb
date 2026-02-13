class Starfield
  class Star
    attr_reader :y
    def initialize(speed, layer)
      @x = rand(0..640)
      @y = rand(0..480)
      @speed = speed
      @layer = layer # To determine size/brightness
    end

    def update
      @y += @speed
      @y = 0 if @y > 480
    end

    def draw
      color = Gosu::Color.rgba(255, 255, 255, 100 + (@layer * 50))
      size = 1 + @layer
      Gosu.draw_rect(@x, @y, size, size, color, 0)
    end
  end

  def initialize
    @stars = []
    # Layer 1: Slow, small, dim (distant)
    40.times { @stars << Star.new(0.5, 0) }
    # Layer 2: Medium
    20.times { @stars << Star.new(1.0, 1) }
    # Layer 3: Fast, large, bright (close)
    10.times { @stars << Star.new(2.0, 2) }
  end

  def update
    @stars.each(&:update)
  end

  def draw
    @stars.each(&:draw)
  end
end
