require_relative "../../test/minitest_helper"
require_relative "../../lib/web_list_watcher/gmail_email_sender"
require "net/smtp"

module WebListWatcher
  class TestYahooEmailSender < MiniTest::Unit::TestCase
    def test_send_email
      start_stub = lambda do |smtp_server, smtp_port, domain, from_email, from_password, operation|
        assert_equal 'smtp.gmail.com', smtp_server
        assert_equal 587, smtp_port
        assert_equal 'gmail.com', domain
        assert_equal 'from@example.com', from_email
        assert_equal 'password', from_password
        assert_equal :login, operation
      end

      enable_tls_stub = lambda do |verify|
        assert_equal OpenSSL::SSL::VERIFY_NONE, verify
      end

      Net::SMTP.stub :start, start_stub do
        Net::SMTP.stub :enable_tls, enable_tls_stub do
          GmailEmailSender.send('from@example.com', 'password', 'to@example.com', '...')
        end
      end
    end
  end
end