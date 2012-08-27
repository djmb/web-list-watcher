require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/seen_items_file"
require "set"
require "fileutils"

module WebListWatcher
  class TestSeenItemsFile < MiniTest::Unit::TestCase
    def setup
      FileUtils.makedirs("data_dir")
    end

    def teardown
      FileUtils.rmtree("data_dir")
    end

    def test_load_no_items
      assert_equal nil, SeenItemsFile.new("data_dir", "nodata").load
    end

    def test_load_items
      File.open("data_dir/toload.seen", 'w') {|f| f.write("line1\nline2\nline3\nline4") }

      lines = %w(line1 line2 line3 line4)

      assert_equal Set.new(lines), SeenItemsFile.new("data_dir", "toload").load
    end

    def test_save_items
      SeenItemsFile.new("data_dir", "save").save(%w(line1 line2 line3 line4))
      assert_equal "line1\nline2\nline3\nline4", File.open("data_dir/save.seen", "r").read
    end
  end
end
