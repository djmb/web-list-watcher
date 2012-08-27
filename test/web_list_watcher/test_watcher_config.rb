require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/watcher_config"
require "ostruct"

module WebListWatcher
  class TestWatcherConfig < MiniTest::Unit::TestCase
    DUMMY_PAGE_CONFIG = OpenStruct.new(:id => 'id', :page_walker => nil)

    def test_yahoo_email
      assert_email_sender('abc@yahoo.com', YahooEmailSender)
    end

    def test_gmail_email
      assert_email_sender('abc@gmail.com', GmailEmailSender)
    end

    def test_invalid_from_email
      assert_raises(RuntimeError) do
        WatcherConfig.new('from@invalid.com', 'password', 'to@example.com', [DUMMY_PAGE_CONFIG])
      end
    end

    def test_missing_fields
      assert_raises(RuntimeError) { WatcherConfig.new(nil, 'password', 'to@example.com', [DUMMY_PAGE_CONFIG]) }
      assert_raises(RuntimeError) { WatcherConfig.new('from@invalid.com', nil, 'to@example.com', [DUMMY_PAGE_CONFIG]) }
      assert_raises(RuntimeError) { WatcherConfig.new('from@invalid.com', 'password', nil, [DUMMY_PAGE_CONFIG]) }
      assert_raises(RuntimeError) { WatcherConfig.new('from@invalid.com', 'password', 'to@example.com', nil) }
      assert_raises(RuntimeError) { WatcherConfig.new('from@invalid.com', 'password', 'to@example.com', []) }
    end

    def assert_email_sender(from_email, sender)
      config = WatcherConfig.new(from_email, 'password', 'to@example.com', [DUMMY_PAGE_CONFIG])
      assert_equal sender, config.email_sender
    end
  end

  class TestWatcherPageConfig < MiniTest::Unit::TestCase
    def test_missing_fields
      assert_raises(RuntimeError) { WatcherPageConfig.new(nil, nil, nil, nil, nil) }
    end
  end
end