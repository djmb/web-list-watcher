require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/watcher"
require_relative "../../lib/web_list_watcher/watcher_config"
require 'ostruct'

module WebListWatcher
  class TestWatcher < MiniTest::Unit::TestCase

    def setup
      @config = OpenStruct.new(
          :from_email=>'me@here.com',
          :password=>'mypass',
          :to_email=>'you@there.com',
          :user_agent=>'my user agent',
          :web_pages=> [
              OpenStruct.new(
                  :id=>'myid',
                  :uri=>'http://example.com/page?param=value',
                  :xpaths=>{
                      :item=>'//div[@class="item"]/a/@href',
                      :next=>'//div[@class="next"]/a/@href',
                  }
              )
          ]
      )
    end

  end
end