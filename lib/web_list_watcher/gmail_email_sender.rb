require 'net/smtp'
require 'tlsmail'

module WebListWatcher
  module GmailEmailSender
    def self.send(gmail_from_email, gmail_password, to_email, content)
      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', gmail_from_email, gmail_password, :login) do |smtp|
        smtp.send_message(content, gmail_from_email, to_email)
      end
    end
  end
end
