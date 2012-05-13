require 'time'

module WebListWatcher
  module EmailGenerator
    def self.generate(items, from_address, to_address)
      <<EOF
From: #{from_address}
To: #{to_address}
Subject: #{email_subject(items)}
Date: #{Time.now.rfc2822}
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

#{email_content(items)}
EOF
    end

    def self.email_subject(new_items)
      "New items found for #{new_items.collect { |site_items| site_items[0]}.join(", ")}"
    end

    def self.email_content(new_items)
      <<EMAIL_CONTENT
<html>
  <head></head>
  <body>
    <h1>New Items Found</h1>
    <div>
      #{email_items_content(new_items)}
    </div>
  </body>
</html>
EMAIL_CONTENT
    end

    def self.email_items_content(new_items)
      new_items.collect do |site_items|
        email_site_items_content(site_items)
      end.join
    end

    def self.email_site_items_content(site_items)
      <<SITE_CONTENT
      <div>
        <h2>#{site_items[0]}</h2>
        <ul>#{email_items_list_content(site_items[1])}</ul>
      </div>
SITE_CONTENT
    end

    def self.email_items_list_content(items)
      items.collect do |item|
        <<ITEM_CONTENT
          <li><a href="#{item}">#{item}</a></li>
ITEM_CONTENT
      end.join
    end

  end
end