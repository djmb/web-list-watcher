require_relative 'watcher'

if ARGV.length == 2
  WebListWatcher::Watcher.new(WebListWatcher::WatcherConfig.create_config(config_filename), ARGV[1]).check
else
  $stderr.puts "Usage: ruby #{__FILE__} <config filename> <data directory>"
end

