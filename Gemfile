source "http://rubygems.org"
gem "nokogiri"
gem "tlsmail"
gem "json"
gem "mechanize"
group :test do
  if RUBY_PLATFORM =~ /(win32|w32)/
    gem "win32console", '1.3.0'
  elsif RUBY_PLATFORM =~ /darwin/
    gem "ruby-fsevent"
  end
  gem "minitest"
  gem "minitest-reporters", '>= 0.5.0'
  gem "watchr"
end

