require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/page_walker"
require 'ostruct'

module WebListWatcher
  class TestPageWalker < MiniTest::Unit::TestCase

    def setup
      @page_walker = PageWalker.new(
          "my_user_agent",
          "http://www.example.com/page?a=b",
          {
              "item"=>'//div[@class="item"]/a/@href',
              "next_page"=>'//div[@class="next"]/a/@href',
          },
          nil
      )
    end

    REMOVE_QUERY_STRING_REGEXP = "([^?]*)\\??.*"

    def test_clean_uri_remove_qs
      page_walker = PageWalker.new(nil, nil, nil, REMOVE_QUERY_STRING_REGEXP)
      assert_equal "http://www.example.com/page", page_walker.clean_uri("http://www.example.com/page?a=b")
    end

    def test_clean_uri_no_match
      page_walker = PageWalker.new(nil, nil, nil, ".*/abc")
      assert_equal "http://www.example.com/page?a=b", page_walker.clean_uri("http://www.example.com/page?a=b")
    end

    def test_clean_uri_multi_match
      page_walker = PageWalker.new(nil, nil, nil, "(.*/)p(.*)")
      assert_equal "http://www.example.com/age?a=b", page_walker.clean_uri("http://www.example.com/page?a=b")
    end

    def test_clean_uri_no_regexp
      page_walker = PageWalker.new(nil, nil, nil, nil)
      assert_equal "http://www.example.com/page?a=b", page_walker.clean_uri("http://www.example.com/page?a=b")
    end

    def test_build_uri_relative
      run_build_uri_test "http://www.example.com/abc", "/abc"
    end

    def test_build_uri_full
      run_build_uri_test "http://www.example.com/abc", "http://www.example.com/abc"
    end

    def test_build_uri_other_domain
      run_build_uri_test "http://www.example2.com/abc", "http://www.example2.com/abc"
    end

    def test_build_uri_clean
      page_walker = PageWalker.new(nil, "http://www.example.com/page?a=b", nil, REMOVE_QUERY_STRING_REGEXP)
      assert_equal "http://www.example.com/abc", page_walker.build_uri("/abc?abc=123", true)
    end

    def test_build_uri_dont_clean
      page_walker = PageWalker.new(nil, "http://www.example.com/page?a=b", nil, REMOVE_QUERY_STRING_REGEXP)
      assert_equal "http://www.example.com/abc?abc=123", page_walker.build_uri("/abc?abc=123", false)
    end

    def run_build_uri_test(expected, uri)
      page_walker = PageWalker.new(nil, "http://www.example.com/page?a=b", nil, nil)
      assert_equal expected, page_walker.build_uri(uri, false)
    end

    def test_next_uri_single_match
      run_next_uri_test ["/123"], "http://www.example.com/123"
    end

    def test_next_uri_multi_match
      run_next_uri_test ["/123", "/456"], "http://www.example.com/123"
    end

    def test_next_uri_no_uri
      run_next_uri_test [], nil
    end

    def dummy_xpath_results(contents)
      contents.collect { |content| OpenStruct.new(:content => content)}
    end

    def run_next_uri_test(xpath_result, expected)
      doc = MiniTest::Mock.new
      doc.expect :xpath, dummy_xpath_results(xpath_result), ['//div[@class="next"]/a/@href']
      assert_equal expected, @page_walker.next_uri(doc)
      doc.verify
    end

    def test_load_page_items_single
      run_load_page_items_uri_test ["/123"], ["http://www.example.com/123"]
    end

    def test_load_page_items_none
      run_load_page_items_uri_test [], []
    end

    def test_load_page_items_multi
      run_load_page_items_uri_test ["/123", "456"], ["http://www.example.com/123", "http://www.example.com/456"]
    end

    def run_load_page_items_uri_test(xpath_result, expected)
      doc = MiniTest::Mock.new
      doc.expect :xpath, dummy_xpath_results(xpath_result), ['//div[@class="item"]/a/@href']
      assert_equal expected, @page_walker.load_page_items(doc)
      doc.verify
    end

    def test_next_page_404
      open_stub = lambda do |uri, user_agent|
        raise OpenURI::HTTPError.new("404 Page not found", nil)
      end
      @page_walker.stub :open, open_stub do
        assert_raises(OpenURI::HTTPError) do
          @page_walker.next_page
        end
      end
    end

    def test_next_page_two_pages
      @page_walker.stub :open, "<html><body><div class='next'><a href='/123'>next</a></div></body></html>" do
        assert_equal ["http://www.example.com/page?a=b", []], @page_walker.next_page
      end

      @page_walker.stub :open, "<html><body><div class='next'></body></html>" do
        assert_equal ["http://www.example.com/123", []], @page_walker.next_page
      end

      assert_equal [nil, []], @page_walker.next_page
    end

    def test_next_page_items
      @page_walker.stub :open, "<html><body><div class='item'><a href='/123'>item1</a></div><div class='item'><a href='/456'>item2</a></div></body></html>" do
        assert_equal ["http://www.example.com/page?a=b", ["http://www.example.com/123", "http://www.example.com/456"]], @page_walker.next_page
      end

      assert_equal [nil, []], @page_walker.next_page
    end

    def test_next_page_two_page_items
      @page_walker.stub :open, "<html><body><div class='next'><a href='/xyz'>next</a></div><div class='item'><a href='/123'>item1</a></div><div class='item'><a href='/456'>item2</a></div></body></html>" do
        assert_equal ["http://www.example.com/page?a=b", ["http://www.example.com/123", "http://www.example.com/456"]], @page_walker.next_page
      end

      @page_walker.stub :open, "<html><body><div class='item'><a href='/789'>item1</a></div><div class='item'><a href='/012'>item2</a></div></body></html>" do
        assert_equal ["http://www.example.com/xyz", ["http://www.example.com/789", "http://www.example.com/012"]], @page_walker.next_page
      end

      assert_equal [nil, []], @page_walker.next_page
    end

  end
end