require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/email_generator"

module WebListWatcher
  class TestEmailGenerator < MiniTest::Unit::TestCase

    def test_items
      items = [
          ["myid", ["http://www.example.com/123", "http://www.example.com/456"]],
          ["myid2", ["http://www.example.com/789"]]
      ]
      now = Time.now
      email = Time.stub :now, now do
         EmailGenerator.generate(items, "from@example.com", "to@example.com")
      end
      expected = <<EXPECTED
From: from@example.com
To: to@example.com
Subject: New items found for myid, myid2
Date: #{now.rfc2822}
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

<html>
  <head></head>
  <body>
    <h1>New Items Found</h1>
    <div>
      <div>
        <h2>myid</h2>
        <ul>
          <li><a href=\"http://www.example.com/123\">http://www.example.com/123</a></li>
          <li><a href=\"http://www.example.com/456\">http://www.example.com/456</a></li>
        </ul>
      </div>
      <div>
        <h2>myid2</h2>
        <ul>
          <li><a href=\"http://www.example.com/789\">http://www.example.com/789</a></li>
        </ul>
      </div>
    </div>
  </body>
</html>

EXPECTED
      assert_equal expected, email
    end
  end
end