require 'json'

class SaveSystem
  FILE_PATH = "savegame.json"

  def self.save(data)
    File.write(FILE_PATH, JSON.pretty_generate(data))
  end

  def self.load
    if File.exist?(FILE_PATH)
      JSON.parse(File.read(FILE_PATH))
    else
      nil
    end
  rescue
    nil
  end

  def self.save_exists?
    File.exist?(FILE_PATH)
  end

  def self.delete_save
    File.delete(FILE_PATH) if File.exist?(FILE_PATH)
  end
end
