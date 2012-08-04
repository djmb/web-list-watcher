require "net/smtp"

module WebListWatcher
  module YahooEmailSender
    def self.send(from_email, from_password, to_email, content)
      Net::SMTP.start('smtp.mail.yahoo.com', 25, 'yahoo.com', from_email, from_password, :login) do |smtp|
        smtp.send_message(content, from_email, to_email)
      end
    end
  end
end