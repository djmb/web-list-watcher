require "json"
require_relative "yahoo_email_sender"
require_relative "gmail_email_sender"
require_relative "page_walker"
require_relative "open_page_loader"
require_relative "webdriver_page_loader"

module WebListWatcher
  class WatcherConfig
    attr_reader :from_email, :password, :to_email, :web_pages, :email_sender

    EmailSenders = {
        "yahoo.com".to_sym => YahooEmailSender,
        "gmail.com".to_sym => GmailEmailSender
    }

    def initialize(from_email, password, to_email, web_pages)
      @from_email, @password, @to_email, @web_pages =
          from_email, password, to_email, web_pages
      check_values_exist(:from_email, :password, :to_email, :web_pages)
      raise "no page configs supplied" if @web_pages.size == 0
      setup_email_sender
    end

    def setup_email_sender
      from_email_domain = @from_email.split("@")[1].to_sym
      @email_sender = EmailSenders[from_email_domain]
      raise "Don't know how to send email from #{from_email_domain} accounts" unless @email_sender
    end

    def check_values_exist(*names)
      names.each do |name|
        raise "'#{name}' specified" unless send(name)
      end
    end

    def self.create_config(filename)
      json = JSON.parse(File.open(filename).read)
      user_agent = json["user_agent"] || "WebListWatcher"
      new(
          json["from_email"],
          json["password"],
          json["to_email"],
          create_pages_config(json["web_pages"], user_agent),
      )
    end

    def self.create_pages_config(web_pages_json, user_agent)
      return nil unless web_pages_json

      web_pages_json.collect do |web_page_json|
        WatcherPageConfig.new(
            web_page_json["id"],
            web_page_json["uri"],
            web_page_json["clean_uri_regexp"],
            web_page_json["xpaths"],
            create_loader(web_page_json),
            user_agent
        )
      end
    end

    def self.create_loader(json)
      loader_name = json["loader"] || "open"
      case loader_name
        when "open"
          OpenPageLoader.new
        when "webdriver"
          WebdriverPageLoader.new(json["start_script"].join("\n"))
      end
    end
  end

  class WatcherPageConfig
    attr_reader :id, :page_walker

    def initialize(id, uri, clean_uri_regexp, xpaths, loader, user_agent)
      validate(id, uri, xpaths)
      @id = id
      @page_walker = PageWalker.new(user_agent, uri, xpaths, clean_uri_regexp, loader)
    end

    def validate(id, uri, xpaths)
      raise "Web page without id" unless id
      raise "No uri for web page:#{id}" unless uri
      raise "No item xpath for web page:#{id}" unless xpaths["item"]
      raise "No next page xpath for web page:#{id}" unless xpaths["next_page"]
    end
  end
end