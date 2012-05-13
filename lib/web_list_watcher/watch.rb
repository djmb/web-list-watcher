require_relative 'watcher'

raise "Usage: ruby #{__FILE__} <config filename> <data directory> <email address>" unless ARGV.length == 3
WebListWatcher::Watcher.new(ARGV[0], ARGV[1], ARGV[2]).check
