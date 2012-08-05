require 'open-uri'
require 'nokogiri'
require 'set'
require_relative 'watcher_config'
require_relative 'email_generator'
require_relative 'yahoo_email_sender'

module WebListWatcher
  class Watcher
    def initialize(config_filename, data_directory)
      @config = WebListWatcher::WatcherConfig.create_config(config_filename)
      @data_directory = data_directory
    end

    def check
      new_items = @config.web_pages.collect { |web_page| check_page(web_page) }.select { |x| x }
      count = new_items.length
      send_email(new_items) if count > 0
      puts "#{count} items found"
    end

    def send_email(new_items)
      from = @config.from_email
      to = @config.to_email
      content = EmailGenerator.generate(new_items, from, to)
      YahooEmailSender.send(from, @config.password, to, content)
    end

    def check_page(web_page)
      id = web_page.id
      seen_file_name = "#@data_directory/#{id}.seen"
      seen = load_seen_items(seen_file_name)
      found = find_items(web_page)
      new = nil
      if seen
        new = found.difference(seen)
      end
      save_seen_items(seen_file_name, found)
      new && new.length > 1 ? [id, new.to_a] : nil
    end

    def save_seen_items(seen_file_name, found)
      File.open(seen_file_name, 'w') {|f| f.write(found.to_a.join("\n")) }
    end

    def find_items(web_page)
      items = Set.new
      uri = web_page.uri
      pages_seen = Set.new

      while uri && !pages_seen.include?(uri) do
        doc = Nokogiri::HTML(open(uri, "User-agent" => @config.user_agent))
        items.merge(load_page_items(doc, uri, web_page))
        pages_seen << uri
        uri = next_uri(doc, web_page, uri)
      end

      items
    end

    def load_page_items(doc, uri, web_page)
      doc.xpath(web_page.xpaths["item"]).collect do |item|
        build_uri(uri, web_page.clean_uri_regexp, item.content)
      end
    end

    def next_uri(doc, web_page, uri)
      next_node = doc.xpath(web_page.xpaths["next_page"]).first
      next_node && build_uri(uri, web_page.clean_uri_regexp, next_node.content)
    end

    def build_uri(previous_uri, clean_uri_regexp, raw_uri)
      uri = URI.join(previous_uri, raw_uri).to_s
      clean_uri(clean_uri_regexp, uri)
    end

    def clean_uri(clean_uri_regexp, uri)
      if clean_uri_regexp && uri =~ /#{clean_uri_regexp}/
        uri = $~[1..-1].join
      end
      uri
    end

    def load_seen_items(seen_file_name)
      File.exists?(seen_file_name) ? Set.new(IO.readlines(seen_file_name).collect {|x| x.strip}) : nil
    end
  end
end