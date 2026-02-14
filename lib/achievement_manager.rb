require 'json'

class AchievementManager
  FILE_PATH = "achievements.json"
  
  ACHIEVEMENTS = {
    first_kill: { name: "First Blood", desc: "Destroy your first asteroid", goal: 1 },
    ten_kills: { name: "Asteroid Hunter", desc: "Destroy 10 asteroids", goal: 10 },
    fifty_kills: { name: "Star Sweeper", desc: "Destroy 50 asteroids", goal: 50 },
    boss_slayer: { name: "Regicide", desc: "Defeat a Boss", goal: 1 },
    boss_hunter: { name: "Titan Killer", desc: "Defeat 3 Bosses", goal: 3 },
    level_ten: { name: "Veteran Pilot", desc: "Reach Level 10", goal: 10 },
    level_twenty: { name: "Legend of Space", desc: "Reach Level 20", goal: 20 },
    millionaire: { name: "High Roller", desc: "Reach a score of 10,000", goal: 10000 },
    billionaire: { name: "Galactic Elite", desc: "Reach a score of 50,000", goal: 50000 },
    combo_master: { name: "Untouchable", desc: "Unlock 5 Shields in one game", goal: 5 }
  }

  attr_reader :stats, :unlocked, :newly_unlocked

  def initialize
    @stats = { kills: 0, bosses: 0, total_score: 0, level: 1, combos: 0 }
    @unlocked = []
    @newly_unlocked = []
    load_data
  end

  def notify(event, value = 1)
    case event
    when :kill then @stats[:kills] += value
    when :boss_defeat then @stats[:bosses] += value
    when :score_update then @stats[:total_score] = [@stats[:total_score], value].max
    when :level_reach then @stats[:level] = [@stats[:level], value].max
    when :combo_triggered then @stats[:combos] += value
    end
    
    check_achievements
  end

  def check_achievements
    ACHIEVEMENTS.each do |key, data|
      next if @unlocked.include?(key.to_s)
      
      met = case key
            when :first_kill then @stats[:kills] >= 1
            when :ten_kills then @stats[:kills] >= 10
            when :fifty_kills then @stats[:kills] >= 50
            when :boss_slayer then @stats[:bosses] >= 1
            when :boss_hunter then @stats[:bosses] >= 3
            when :level_ten then @stats[:level] >= 10
            when :level_twenty then @stats[:level] >= 20
            when :millionaire then @stats[:total_score] >= 10000
            when :billionaire then @stats[:total_score] >= 50000
            when :combo_master then @stats[:combos] >= 5
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
      # Merging keys carefully
      if data["stats"]
        data["stats"].each { |k, v| @stats[k.to_sym] = v }
      end
      @unlocked = data["unlocked"] || []
    end
  rescue
    # If JSON is corrupted, start fresh
  end

  def save_data
    File.write(FILE_PATH, JSON.pretty_generate({ stats: @stats, unlocked: @unlocked }))
  end
end
