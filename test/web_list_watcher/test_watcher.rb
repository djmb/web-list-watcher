require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/watcher"
require "fileutils"

module WebListWatcher
  class TestWatcher < MiniTest::Unit::TestCase
    def setup
      FileUtils.rmtree("data_dir")
      FileUtils.makedirs("data_dir")
    end

    def teardown
      FileUtils.rmtree("data_dir")
    end

    def test_two_runs_same
      run_watcher(
          make_config("two_runs_same"),
          create_no_send_stub,
          create_open_stub([[[1, 2, 3], "/123"], [[4, 5], "/456"]]),
          make_items([1, 2, 3, 4, 5]),
          0
      )
      run_watcher(
          make_config("two_runs_same"),
          create_no_send_stub,
          create_open_stub([[[1, 2, 3], "/123"], [[4, 5], "/456"]]),
          make_items([1, 2, 3, 4, 5]),
          0
      )
    end

    def test_two_runs_lose_one
      run_watcher(
          make_config("two_runs_lose_one"),
          create_no_send_stub,
          create_open_stub([[[1, 2, 3], "/123"], [[4, 5], "/456"]]),
          make_items([1, 2, 3, 4, 5]),
          0
      )
      run_watcher(
          make_config("two_runs_lose_one"),
          create_no_send_stub,
          create_open_stub([[[1, 3], "/123"], [[4, 5], "/456"]]),
          make_items([1, 2, 3, 4, 5]),
          0
      )
    end

    def test_two_runs_add_one
      run_watcher(
          make_config("two_runs_add_one"),
          create_no_send_stub,
          create_open_stub([[[1, 2, 3], "/123"], [[4, 5], "/456"]]),
          make_items([1, 2, 3, 4, 5]),
          0
      )
      email_time = Time.now
      run_watcher(
          make_config("two_runs_add_one"),
          create_send_stub(create_email(email_time, [6])),
          create_open_stub([[[1, 2, 3], "/123"], [[4, 5, 6], "/456"]]),
          make_items([1, 2, 3, 4, 5, 6]),
          1,
          email_time
      )
    end

    def create_email(time, items)
      <<EMAIL
From: from@yahoo.com
To: to@example.com
Subject: New items found for two_runs_add_one
Date: #{time.rfc2822}
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

<html>
  <head></head>
  <body>
    <h1>New Items Found</h1>
    <div>
      <div>
        <h2>two_runs_add_one</h2>
        <ul>
#{items.collect { |x| "          <li><a href=\"http://example.com/item#{x}\">http://example.com/item#{x}</a></li>\n"}.join }        </ul>
      </div>
    </div>
  </body>
</html>

EMAIL
    end

    def make_items(numbers)
      numbers.collect { |x| "http://example.com/item#{x}" }.join("\n")
    end

    def run_watcher(config, send_stub, open_stub, seen_contents, items_found, time = Time.now)
      stdout, = capture_io do
        Time.stub :now, time do
          YahooEmailSender.stub :send, send_stub do
            watcher = Watcher.new(config, "data_dir")
            watcher.stub :sleep, nil do
              web_page_config = config.web_pages[0]
              web_page_config.page_walker.page_loader.stub :open, open_stub do
                watcher.check
                assert_equal seen_contents, File.open("data_dir/#{web_page_config.id}.seen", "r").read
              end
            end
          end
        end
      end
      assert_equal "#{items_found} items found\n", stdout
    end

    def make_config(id)
      web_page_config = WatcherPageConfig.new(id, "http://example.com/123", nil, {
          "item" => "//a[@class='item']/@href", "next_page" => "//a[@class='next']/@href"
      }, OpenPageLoader.new, "useragent 1.0")

      WatcherConfig.new("from@yahoo.com", "password", "to@example.com", [web_page_config])
    end

    def create_open_stub(pages)
      open_counter = 0
      lambda do |uri, user_agent|
        page = pages[open_counter]
        next_page = pages[open_counter + 1]
        assert page
        assert_equal "useragent 1.0", user_agent["User-agent"]
        open_counter = open_counter + 1
        assert_equal "http://example.com#{page[1]}", uri
        <<PAGE
<html>
  <body>
    <div>#{page[0].collect { |x| "<a class='item' href='/item#{x}'>#{x}</a>"}.join }</div>
    #{next_page ? "<div><a class='next' href='#{next_page[1]}'></a>" : ""}
  </body>
</html>
PAGE
      end
    end

    def create_no_send_stub
      lambda do |from_email, from_password, to_email, content|
        assert false, "No email should be sent"
      end
    end

    def create_send_stub(expected)
      lambda do |from_email, from_password, to_email, content|
        assert_equal ["from@yahoo.com", "password", "to@example.com"], [from_email, from_password, to_email]
        assert_equal expected, content
      end
    end

  end
end