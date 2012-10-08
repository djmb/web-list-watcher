require 'open-uri'

module WebListWatcher
  class OpenPageLoader
    def start
    end

    def load(uri, user_agent)
      open(uri, "User-agent" => user_agent)
    end

    def finish
    end
  end
end