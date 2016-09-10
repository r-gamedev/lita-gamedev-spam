require 'pry'
require 'andand'
require 'bunny'
require 'common/messaging/reddit/comment'
require 'common/messaging/reddit/modmail'
require 'common/messaging/reddit/submission'
require 'common/messaging/message'
require 'common/irc/color'

module Lita
  module Handlers
    # Commands for GamedevSpam
    class GamedevSpam < Handler
      VALID_FOLLOW_ROUTING_REGEX = %r{
          submission\.([*#]|gamedev)
          |
          comment\.[#]
          |
          comment\.([*#]|gamedev)\.([*#]|[a-zA-Z0-9]+)
        }x

      VALID_FOLLOW_ROUTING_KEYS_HELPTEXT =
        'invalid key. help: submission.(gamedev|*|#) or comment.gamedev.(id|*|#)'.freeze

      route(/^watch$/, :see)

      route(/^watch\s+(.+)/, :watch,
            command: true, restrict_to: :admins,
            help: {
              'watch comment.gamedev' =>
                'subscribes the channel to comments from /r/gamedev',
              'watch comment.#' =>
                'subscribes the channel to all comments',
              'watch submission.gamedev' =>
                'subscribes the channel to submissions from /r/gamedev' })

      route(/^unwatch\s+(.+)/, :unwatch,
            command: true, restrict_to: :admins,
            help: {
              'unwatch comment.gamedev' =>
                'unsubscribes the channel to comments from /r/gamedev' })

      route(/^follow\s+(.+)/, :follow,
            command: true,
            help: {
              'follow comment.gamedev' =>
                'subscribes the channel to comments from /r/gamedev',
              'follow comment.#' =>
                'subscribes the channel to all comments',
              'follow submission.gamedev' =>
                'subscribes the channel to submissions from /r/gamedev' })

      route(/^unfollow\s+(.+)/, :unfollow,
            command: true,
            help: {
              'unfollow comment.gamedev' =>
                'unsubscribes the channel to comments from /r/gamedev' })

      route(/^list watch$/, :list_watch,
            command: true,
            help: {
              'list watch' =>
                'lists the current watches for the channel (or user if in PM)' })

      route(/^list follow$/, :list_follow,
            command: true,
            help: {
              'list follow' =>
                'lists the current watches for the user' })

      def see(response)
        response.reply "*sees #{response.user.name}*"
      end

      # Command for watching a topic ID
      def watch(response)
        room_name = response.room.andand.name
        user_name = response.user.andand.name
        routing_key = response.match_data[1]
        subscribe(room_name, user_name, routing_key)
        response.reply "#{response.user.name}, watching '#{routing_key}'"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e} (routing_key: '#{routing_key}')"
      end

      # Command for unwatching a topic ID
      def unwatch(response)
        room_name = response.room.andand.name
        user_name = response.user.andand.name
        routing_key = response.match_data[1]
        unsubscribe(room_name, user_name, routing_key)
        response.reply "#{response.user.name}, no longer watching '#{routing_key}'"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e} (routing_key: '#{routing_key}')"
      end

      # Command for requestor-only watching a topic ID
      def list_watch(response)
        room_name = response.room.andand.name
        user_name = response.user.andand.name
        response.reply "#{response.user.name}, list for '#{room_name || user_name}': "\
          "#{list_spam(room_name, user_name)}"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e}"
      end

      # Command for requestor-only watching a topic ID
      def follow(response)
        user_name = response.user.andand.name
        routing_key = response.match_data[1]
        validate_follow_routing_key(routing_key)
        subscribe(nil, user_name, routing_key)
        response.reply "#{response.user.name}, following '#{routing_key}'"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e} (routing_key: '#{routing_key}')"
      end

      # Command for requestor-only watching a topic ID
      def unfollow(response)
        user_name = response.user.andand.name
        routing_key = response.match_data[1]
        unsubscribe(nil, user_name, routing_key)
        response.reply "#{response.user.name}, no longer following '#{routing_key}'"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e} (routing_key: '#{routing_key}')"
      end

      # Command for requestor-only watching a topic ID
      def list_follow(response)
        user_name = response.user.andand.name
        response.reply "#{response.user.name}, list for '#{user_name}': #{list_spam(nil, user_name)}"
      rescue Error => e
        log.error e.inspect
        log.error response.inspect
        response.reply "#{response.user.name}, #{e}"
      end

      # Raises an error unless the routing key is valid
      def validate_follow_routing_key(routing_key)
        raise Error, VALID_FOLLOW_ROUTING_KEYS_HELPTEXT unless VALID_FOLLOW_ROUTING_REGEX.match(routing_key)
        raise Error, 'unauthorized' if routing_key.include?('modmail')
        raise Error, 'unauthorized' if routing_key.start_with?('#')
        raise Error, 'unauthorized' if routing_key.start_with?('*')
      end
    end # class GamedevSpam
  end # module Handlers
end # module Lita
