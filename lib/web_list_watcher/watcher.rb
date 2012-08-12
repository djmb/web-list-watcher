require 'set'
require_relative 'watcher_config'
require_relative 'email_generator'

module WebListWatcher
  class Watcher
    def initialize(config_filename, data_directory)
      @config = WebListWatcher::WatcherConfig.create_config(config_filename)
      @data_directory = data_directory
    end

    def check
      new_items = @config.web_pages.collect { |web_page| check_page(web_page) }.select { |x| x }
      count = new_items.inject(0) { |sum, site_items| sum + site_items[1].length }
      send_email(new_items) if count > 0
      puts "#{count} items found"
    end

    def send_email(new_items)
      from = @config.from_email
      to = @config.to_email
      content = EmailGenerator.generate(new_items, from, to)
      @config.email_sender.send(from, @config.password, to, content)
    end

    def check_page(web_page)
      id = web_page.id
      seen_file_name = "#@data_directory/#{id}.seen"
      seen = load_seen_items(seen_file_name)
      found = find_items(web_page.page_walker)
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

    def find_items(page_walker)
      items, pages_seen = Set.new, Set.new
      uri = page_walker.next_page

      while uri && !pages_seen.include?(uri) do
        items.merge(page_walker.items)
        pages_seen << uri
        sleep(2)
        uri = page_walker.next_page
      end

      items
    end

    def load_seen_items(seen_file_name)
      File.exists?(seen_file_name) ? Set.new(IO.readlines(seen_file_name).collect {|x| x.strip}) : nil
    end
  end
end