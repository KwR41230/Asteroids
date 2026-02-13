require 'json'

class HighScores
  FILE_PATH = "high_scores.json"

  def self.load
    if File.exist?(FILE_PATH)
      file = File.read(FILE_PATH)
      JSON.parse(file)
    else
      # Default scores if no file exists
      [
        {"name" => "ACE", "score" => 500},
        {"name" => "BOB", "score" => 400},
        {"name" => "CAT", "score" => 300},
        {"name" => "DOG", "score" => 200},
        {"name" => "EGG", "score" => 100}
      ]
    end
  rescue
    []
  end

  def self.save(scores)
    File.write(FILE_PATH, JSON.pretty_generate(scores.first(10)))
  end

  def self.add_score(name, score)
    scores = load
    scores << {"name" => name, "score" => score}
    # Sort by score descending
    scores = scores.sort_by { |s| -s["score"] }
    save(scores.first(10))
  end

  def self.high_enough?(score)
    scores = load
    return true if scores.size < 10
    score > scores.last["score"]
  end
end
