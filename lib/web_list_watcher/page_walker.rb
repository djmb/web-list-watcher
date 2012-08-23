require 'open-uri'
require 'nokogiri'

module WebListWatcher
  class PageWalker
    def initialize(user_agent, uri, xpaths, clean_uri_regexp)
      @user_agent = user_agent
      @uri = uri
      @xpaths = xpaths
      @clean_uri_regexp = clean_uri_regexp
    end

    def next_page
      if @uri
        current_uri = @uri
        begin
          doc = Nokogiri::HTML(open(@uri, "User-agent" => @user_agent))
        rescue OpenURI::HTTPError => e
          $stderr.puts "Got '#{e.message}' opening #@uri"
          raise e
        end
        items = load_page_items(doc)
        @uri = next_uri(doc)
        [current_uri, items]
      else
        [nil, []]
      end

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
      uri = URI.join(@uri, raw_uri).to_s
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