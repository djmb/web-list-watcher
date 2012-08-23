require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/yahoo_email_sender"
require "net/smtp"

module WebListWatcher
  class TestYahooEmailSender < MiniTest::Unit::TestCase
    def test_send_email
      start_stub = lambda do |smtp_server, smtp_port, domain, from_email, from_password, operation|
        assert_equal 'smtp.mail.yahoo.com', smtp_server
        assert_equal 25, smtp_port
        assert_equal 'yahoo.com', domain
        assert_equal 'from@example.com', from_email
        assert_equal 'password', from_password
        assert_equal :login, operation
      end
      Net::SMTP.stub :start, start_stub do
        YahooEmailSender.send('from@example.com', 'password', 'to@example.com', '...')
      end
    end
  end
end