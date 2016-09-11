require 'pry'
require 'andand'
require 'bunny'
require 'common/messaging/reddit/comment'
require 'common/messaging/reddit/modmail'
require 'common/messaging/reddit/submission'
require 'common/messaging/message'
require 'common/irc/color'
require 'common/lita/temp_storage'

# TODO: restructure this to suck less

module Lita
  module Handlers
    # The Spam Partial for GamedevSpam
    # rubocop:disable ClassVars
    class GamedevSpam < Handler
      extend Handler::EventRouter
      # TODO: Use the LITA configuration system instead of environment variables
      # config :rabbitmq_url, default: ENV['rabbitmq_url']
      @@temp_storage ||= ::Lemtzas::Common::Lita::TempStorage.new

      @@conn = Bunny.new(ENV['rabbitmq_url'])
      @@conn.start
      @@ch = @@conn.create_channel
      @@topic = @@ch.topic('reddit-monitor-live')

      private

      # Retrieve the per-channel/user routing storage
      def route_storage(room_name, user_name)
        raise Error, 'no room or name' unless room_name || user_name
        @@temp_storage[room_name, user_name].routing_keys ||= {}
      end

      # Spam a user/channel
      def spam(room_name, user_name, routing_key)
        raise Error, 'bad routing key' unless routing_key.andand.is_a? String
        user = User.find_by_name(user_name) if user_name
        source = Lita::Source.new(room: room_name, user: user)
        storage = route_storage(room_name, user_name)
        raise Error, "'#{room_name || user_name}' already watching '#{routing_key}'" if storage[routing_key]
        storage[routing_key] = watch_queue(routing_key, source)
        log.info "registered '#{room_name || user_name}' << '#{routing_key}'"
      end

      # Remove a routing key from the spam list for a user/channel
      def unspam(room_name, user_name, routing_key)
        raise Error, "bad routing key '#{routing_key}'" unless routing_key.andand.is_a? String
        storage = route_storage(room_name, user_name)
        q = storage[routing_key]
        raise Error, 'unknown routing key. Try `list follow` or `list watch`' unless q
        q.delete
        storage.delete routing_key
        log.info "unregistered '#{room_name || user_name}' << '#{routing_key}'"
      end

      def list_spam(room_name, user_name)
        storage = route_storage(room_name, user_name)
        return 'none found' unless storage.any?
        storage.keys.join(', ')
      end

      def watch_queue(routing_key, source)
        q = @@ch.queue('', exclusive: true)
                .bind(@@topic, routing_key: routing_key)
        q.subscribe(block: false) do |_delivery_info, _properties, body|
          forward_to_room(body, source)
        end
        q
      end

      def forward_to_room(body, source)
        target = source.room || source.user.andand.name
        message = ::Lemtzas::Common::Messaging::Message.deserialize(body)
        log.info "'#{target}' << #{message}"
        robot.send_messages(source, pretty_print(message))
      rescue
        log.info $ERROR_INFO
        log.info $ERROR_POSITION
        raise
      end

      def pretty_print(message)
        m = message
        fulltext = nil
        case m
        when ::Lemtzas::Common::Messaging::Reddit::Comment
          fulltext = "#{Color.grey}#{Color.bold}/u/#{m.author} -> /r/#{m.subreddit}:#{Color.clear} "\
            "#{Color.grey}#{m.shorttext(100)} - #{m.shortlink}?context=9"
        when ::Lemtzas::Common::Messaging::Reddit::Submission
          fulltext = "#{Color.bold}#{Color.light_green}#{m.subreddit}:#{Color.clear} "\
            "#{Color.italic}#{m.title}#{Color.clear} - /u/#{m.author} - #{m.shortlink}"
        when ::Lemtzas::Common::Messaging::Reddit::Modmail
          fulltext = format_modmail(message)
        end
        trim_text(fulltext, 400)
      end

      def format_modmail(message)
        m = message
        linear_body = m.body.tr("\n", ' ')
        linear_body = shortlink_filter(linear_body)
        case m.author.downcase
        when 'automoderator'
          "#{Color.light_blue}#{m.subreddit} AutoMod:#{Color.clear} #{linear_body}"
        else
          "#{Color.red}#{m.subreddit} modmail:#{Color.clear} "\
            "(#{m.shortlink}) #{m.author} -> #{m.subreddit} "\
            "<#{Color.italic}#{m.subject}#{Color.clear}> #{linear_body}"
        end
      end

      def shortlink_filter(text)
        text.gsub( # short-link what we can in the body
          %r{(?:https?:\/\/(?:www\.)?reddit\.com\/r\/.+\/comments\/)(\w+)(?!\/(.+)\/[^\s]+)(?=[\s\/])(\/([^\s]+)(?!\/[^\s]+)|(\/|\/(.+)\/(?![^\s]+)))?}i,
          'http://redd.it/\1')
      end

      def trim_text(text, length)
        return nil unless text
        trimmed = text[0..length]
        trimmed += ' [...]' if text.length > trimmed.length
        trimmed
      end
    end # class GamedevSpam
  end # module Handlers
end # module Lita
