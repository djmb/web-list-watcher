require 'open-uri'
require 'nokogiri'

module WebListWatcher
  class NokogiriPageWalker
    attr_reader :current_uri, :items

    def initialize(user_agent, uri, xpaths, clean_uri_regexp)
      @user_agent = user_agent
      @xpaths = xpaths
      @next_uri = uri
      @clean_uri_regexp = clean_uri_regexp
      @current_uri = nil
      @doc = nil
    end

    def next_page
      @current_uri = @next_uri

      if @current_uri
        doc = Nokogiri::HTML(open(@current_uri, "User-agent" => @user_agent))
        @next_uri = next_uri(doc)
        @items = load_page_items(doc)
      else
        @items = nil
      end

      @current_uri
    end

    def load_page_items(doc)
      doc.xpath(@xpaths["item"]).collect do |item|
        build_uri(item.content, true)
      end
    end

    def next_uri(doc)
      next_node = doc.xpath(@xpaths["next_page"]).first
      next_node && build_uri(next_node.content, false)
    end

    def build_uri(raw_uri, clean)
      uri = URI.join(@current_uri, raw_uri).to_s
      clean ? clean_uri(uri) : uri
    end

    def clean_uri(uri)
      if @clean_uri_regexp && uri =~ /#@clean_uri_regexp/
        uri = $~[1..-1].join
      end
      uri
    end
  end
end