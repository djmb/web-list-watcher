require 'open-uri'
require 'nokogiri'
require 'set'
require 'net/smtp'
require 'tlsmail'
require_relative '../web_list_watcher'
require_relative 'email_generator'

module WebListWatcher
  class Watcher
    def initialize(config_filename, data_directory, email_address)
      @config = WebListWatcher.read_config(config_filename)
      @data_directory = data_directory
      @email_address = email_address
    end

    def check
      new_items = @config["web_pages"].collect { |web_page| check_page(web_page) }.select { |x| x }
      email(new_items) if new_items.length > 0
    end

    def email(new_items)
      from = @config["from_email"]
      to = @config["to_email"]
      email_content = EmailGenerator.generate(new_items, from, to)
      puts email_content

      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', from, @config["password"], :login) do |smtp|
        smtp.send_message(email_content, from, to)
      end
    end

    def check_page(web_page)
      id = web_page["id"]
      seen_file_name = "#@data_directory/#{id}.seen"
      seen = load_seen_items(seen_file_name)
      found = find_items(web_page)
      new = nil
      if seen
        new = found.difference(seen)
      end
      save_seen_items(seen_file_name, found)
      new.length > 1 ? [id, new.to_a] : nil
    end

    def save_seen_items(seen_file_name, found)
      File.open(seen_file_name, 'w') {|f| f.write(found.to_a.join("\n")) }
    end

    def find_items(web_page)
      items = Set.new
      uri = web_page["uri"]
      pages_seen = Set.new

      while uri && !pages_seen.include?(uri) do
        doc = Nokogiri::HTML(open(uri, "User-agent" => @config["user_agent"]))
        items.merge(load_page_items(doc, uri, web_page))
        pages_seen << uri
        uri = next_uri(doc, web_page)
      end

      items
    end

    def load_page_items(doc, uri, web_page)
      doc.xpath(web_page["xpaths"]["item"]).collect do |item|
        URI.join(uri, item.content).to_s
      end
    end

    def next_uri(doc, web_page)
      next_node = doc.xpath(web_page["xpaths"]["next_page"]).first
      next_node && next_node.content
    end

    def load_seen_items(seen_file_name)
      File.exists?(seen_file_name) ? Set.new(IO.readlines(seen_file_name).collect {|x| x.strip}) : nil
    end
  end
end