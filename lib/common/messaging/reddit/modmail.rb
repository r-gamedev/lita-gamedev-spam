require 'common/messaging/message'
require 'htmlentities'

module Lemtzas
  module Common
    module Messaging
      module Reddit
        # Represents a modmail message
        class Modmail < Message
          attr_accessor :body,
                        :name,
                        :id,
                        :author,
                        :created_utc,
                        :subreddit,
                        :subject,
                        :distinguished,
                        :first_message_name

          def shortlink
            "http://reddit.com/message/messages/#{id}"
          end

          def shorttext(length = 40, strip_newlines = true)
            text = body
            text = text.gsub(/\r|\n/, '') if strip_newlines
            text[0..length]
          end

          def to_s
            "Modmail /r/#{subreddit} /u/#{author} - #{shorttext} - #{shortlink}"
          end

          # Constructs a modmail from listing data
          def self.from_data(data)
            modmail = Modmail.new
            html_entities = HTMLEntities.new
            modmail.uuid = SecureRandom.uuid
            modmail.body = html_entities.decode(data.body)
            modmail.name = data.name
            modmail.id = data.id
            modmail.author = data.author
            modmail.created_utc = data.created_utc
            modmail.subreddit = data.subreddit
            modmail.subject = html_entities.decode(data.subject)
            modmail.distinguished = data.distinguished
            modmail.first_message_name = data.first_message_name
            modmail
          end
        end # class Modmail
      end # module Reddit
    end # module Messaging
  end # module Common
end # module Lemtzas
