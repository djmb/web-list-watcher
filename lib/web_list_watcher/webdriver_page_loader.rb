require 'open-uri'
require "selenium-webdriver"

module WebListWatcher
  class WebdriverPageLoader
    def initialize(start_script)
      @start_script = start_script
    end

    def start
      @driver = Selenium::WebDriver.for :firefox
      @driver.manage.timeouts.implicit_wait = 240
      eval(@start_script)
    end

    def load(uri, user_agent)
      @driver.get(uri)
      @driver.page_source
    end

    def finish
      @driver.quit
    end
  end
end