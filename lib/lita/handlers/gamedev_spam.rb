require 'pry'
require 'andand'
require 'bunny'
require 'common/messaging/reddit/comment'
require 'common/messaging/reddit/modmail'
require 'common/messaging/reddit/submission'
require 'common/messaging/message'
require 'common/irc/color'

require 'lita/handlers/gamedev_spam/persistence'
require 'lita/handlers/gamedev_spam/watch_management'
require 'lita/handlers/gamedev_spam/spam'

# TODO: More thread safety.

module Lita
  module Handlers
    # GamedevSpam handler.
    class GamedevSpam < Handler
      class Error < RuntimeError; end
      include ::Lemtzas::Common::IRC

      def initialize(robot)
        puts 'CREATION'
        super(robot)
      end

      Lita.register_handler(self)

      private

      # Subscribes to a key
      def subscribe(room_name, user_name, routing_key)
        spam(room_name, user_name, routing_key)
        persist(room_name, user_name, routing_key)
      end

      # Unsubscribes from a key
      def unsubscribe(room_name, user_name, routing_key)
        unspam(room_name, user_name, routing_key)
        unpersist(room_name, user_name, routing_key)
      end
    end
  end
end
