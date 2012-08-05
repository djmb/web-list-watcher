require "json"

module WebListWatcher
  class WatcherConfig
    attr_reader :from_email, :password, :to_email, :user_agent, :web_pages

    def initialize(from_email, password, to_email, user_agent, web_pages)
      @from_email, @password, @to_email, @user_agent, @web_pages =
          from_email, password, to_email, user_agent, web_pages
      check_values_exist(:from_email, :password, :to_email, :web_pages)
    end

    def check_values_exist(*names)
      names.each do |name|
        raise StandardError, "'#{name}' specified" unless send(name)
      end
    end

    def self.create_config(filename)
      json = JSON.parse(File.open(filename).read)
      new(
          json["from_email"],
          json["password"],
          json["to_email"],
          json["user_agent"] || "WebListWatcher",
          create_pages_config(json["web_pages"]),
      )
    end

    def self.create_pages_config(web_pages_json)
      return nil unless web_pages_json

      web_pages_json.collect do |web_page_json|
        WatcherPageConfig.new(
            web_page_json["id"],
            web_page_json["uri"],
            web_page_json["clean_uri_regexp"],
            web_page_json["xpaths"]
        )
      end
    end

    class WatcherPageConfig
      attr_reader :id, :uri, :clean_uri_regexp, :xpaths

      def initialize(id, uri, clean_uri_regexp, xpaths)
        @id = id
        @uri = uri
        @clean_uri_regexp = clean_uri_regexp
        @xpaths = xpaths
        validate
      end

      def validate
        raise StandardError, "Web page without id" unless @id
        raise StandardError, "No uri for web page:#{id}" unless @uri
        raise StandardError, "No item xpath for web page:#{id}" unless @xpaths["item"]
        raise StandardError, "No next page xpath for web page:#{id}" unless @xpaths["next_page"]
      end
    end
  end
end