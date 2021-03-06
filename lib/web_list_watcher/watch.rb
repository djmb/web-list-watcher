require_relative 'watcher'
require_relative 'watcher_config'

if ARGV.length == 2
  WebListWatcher::Watcher.new(WebListWatcher::WatcherConfig.create_config(ARGV[0]), ARGV[1]).check
else
  $stderr.puts "Usage: ruby #{__FILE__} <config filename> <data directory>"
end

