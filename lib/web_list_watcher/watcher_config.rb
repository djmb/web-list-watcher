require "json"
require_relative "yahoo_email_sender"
require_relative "gmail_email_sender"
require_relative "nokogiri_page_walker"

module WebListWatcher
  class WatcherConfig
    attr_reader :from_email, :password, :to_email, :user_agent, :web_pages, :email_sender, :page_walker

    EmailSenders = {
        "yahoo.com".to_sym => YahooEmailSender,
        "gmail.com".to_sym => GmailEmailSender
    }

    def initialize(from_email, password, to_email, user_agent, web_pages)
      @from_email, @password, @to_email, @user_agent, @web_pages =
          from_email, password, to_email, user_agent, web_pages
      check_values_exist(:from_email, :password, :to_email, :web_pages)
      setup_email_sender
    end

    def setup_email_sender
      from_email_domain = @from_email.split("@")[1].to_sym
      @email_sender = EmailSenders[from_email_domain]
      raise "Don't know how to send email from #{from_email_domain} accounts" unless @email_sender
    end

    def check_values_exist(*names)
      names.each do |name|
        raise StandardError, "'#{name}' specified" unless send(name)
      end
    end

    def self.create_config(filename)
      json = JSON.parse(File.open(filename).read)
      user_agent = json["user_agent"] || "WebListWatcher"
      new(
          json["from_email"],
          json["password"],
          json["to_email"],
          user_agent,
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
            user_agent
        )
      end
    end

    class WatcherPageConfig
      attr_reader :id, :page_walker

      def initialize(id, uri, clean_uri_regexp, xpaths, user_agent)
        validate(id, uri, xpaths)
        @id = id
        @page_walker = NokogiriPageWalker.new(user_agent, uri, xpaths, clean_uri_regexp)
      end

      def validate(id, uri, xpaths)
        raise StandardError, "Web page without id" unless id
        raise StandardError, "No uri for web page:#{id}" unless uri
        raise StandardError, "No item xpath for web page:#{id}" unless xpaths["item"]
        raise StandardError, "No next page xpath for web page:#{id}" unless xpaths["next_page"]
      end
    end
  end
end