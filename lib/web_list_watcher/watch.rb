require_relative 'watcher'

raise "Usage: ruby #{__FILE__} <config filename> <data directory>" unless ARGV.length == 2
WebListWatcher::Watcher.new(ARGV[0], ARGV[1]).check
