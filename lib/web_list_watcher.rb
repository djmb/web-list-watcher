require 'json'

module WebListWatcher
  def self.read_config(filename)
    JSON.parse(File.open(filename).read)
  end

end