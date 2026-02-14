require 'json'

class AchievementManager
  FILE_PATH = "achievements.json"
  
  ACHIEVEMENTS = {
    first_kill: { name: "First Blood", desc: "Destroy your first asteroid", goal: 1 },
    ten_kills: { name: "Asteroid Hunter", desc: "Destroy 10 asteroids", goal: 10 },
    boss_slayer: { name: "Regicide", desc: "Defeat a Boss", goal: 1 },
    millionaire: { name: "High Roller", desc: "Reach a score of 10,000", goal: 10000 },
    survivor: { name: "Untouchable", desc: "Complete a level without losing a life", goal: 1 }
  }

  attr_reader :stats, :unlocked, :newly_unlocked

  def initialize
    @stats = { kills: 0, bosses: 0, total_score: 0 }
    @unlocked = []
    @newly_unlocked = []
    load_data
  end

  def notify(event, value = 1)
    case event
    when :kill then @stats[:kills] += value
    when :boss_defeat then @stats[:bosses] += 1
    when :score_update then @stats[:total_score] = [@stats[:total_score], value].max
    end
    
    check_achievements
  end

  def check_achievements
    ACHIEVEMENTS.each do |key, data|
      next if @unlocked.include?(key.to_s)
      
      met = case key
            when :first_kill then @stats[:kills] >= 1
            when :ten_kills then @stats[:kills] >= 10
            when :boss_slayer then @stats[:bosses] >= 1
            when :millionaire then @stats[:total_score] >= 10000
            end
            
      if met
        @unlocked << key.to_s
        @newly_unlocked << data
        save_data
      end
    end
  end

  def load_data
    if File.exist?(FILE_PATH)
      data = JSON.parse(File.read(FILE_PATH))
      @stats = data["stats"].transform_keys(&:to_sym) if data["stats"]
      @unlocked = data["unlocked"] || []
    end
  end

  def save_data
    File.write(FILE_PATH, JSON.generate({ stats: @stats, unlocked: @unlocked }))
  end
end
