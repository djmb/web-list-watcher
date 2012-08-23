require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/seen_items_file"
require "set"

module WebListWatcher
  class TestSeenItemsFile < MiniTest::Unit::TestCase
    def setup
      @seen_items_file = SeenItemsFile.new("data_dir", "id")
    end

    def test_load_no_items
      File.stub :exists?, create_exists_stub(false) do
        assert_equal nil, @seen_items_file.load
      end
    end

    def test_load_items
      lines = %w(line1 line2 line3 line4)

      File.stub :exists?, create_exists_stub(true) do
        IO.stub :readlines, create_readlines_stub(lines) do
          assert_equal Set.new(lines), @seen_items_file.load
        end
      end
    end


    def test_save_items
      open_stub = lambda do |file_name, mode|
        assert_file_name(file_name)
        assert_equal mode, "w"
      end
      File.stub :open, open_stub do
        @seen_items_file.save(%w(line1 line2 line3 line4))
      end
    end

    def create_readlines_stub(lines)
      lambda do |file_name|
        assert_file_name(file_name)
        lines
      end
    end

    def assert_file_name(file_name)
      assert_equal "data_dir/id.seen", file_name
    end

    def create_exists_stub(exists)
      lambda do |file_name|
        assert_equal "data_dir/id.seen", file_name
        exists
      end
    end
  end
end
