require_relative "../../lib/web_list_watcher/watcher"
require_relative "../../lib/web_list_watcher/watcher_config"
require_relative "initializer"
require 'minitest/autorun'

module WebListWatcher
  class TestWatcher < MiniTest::Unit::TestCase

    def setup
      @config = WebListWatcher.stub
    end

    def test_find_items
      Kernel.stub(:open, '<html><body><ul><li><a href="/abc">abd</a></li></ul></body></html>') do

      end
    end

  end
end