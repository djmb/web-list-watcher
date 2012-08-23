require 'set'
require_relative 'watcher_config'
require_relative 'email_generator'
require_relative 'seen_items_file'

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
      begin
        id = web_page.id
        seen_items_file = SeenItemsFile.new(@data_directory, id)
        seen = seen_items_file.load
        found = find_items(web_page.page_walker)
        new = nil
        if seen
          new = found.difference(seen)
        end
        seen_items_file.save(found)
        new && new.length > 1 ? [id, new.to_a] : nil
      rescue OpenURI::HTTPError => e
        nil
      end
    end

    def find_items(page_walker)
      items, pages_seen = Set.new, Set.new
      uri, page_items = page_walker.next_page

      while uri && !pages_seen.include?(uri) do
        items.merge(page_items)
        pages_seen << uri
        sleep(2)
        uri, page_items = page_walker.next_page
      end

      items
    end
  end
end