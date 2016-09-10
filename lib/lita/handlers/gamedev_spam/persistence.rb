require 'json'

module Lita
  module Handlers
    # The persistence partial for GamedevSpam
    class GamedevSpam < Handler
      extend Handler::EventRouter
      on :connected, :start_all

      # Sets spam persistence for a routing key on a user
      def persist(room_name, user_name, routing_key)
        raise Error, "bad routing key '#{routing_key}'" unless routing_key.andand.is_a? String
        # TODO: Potential threading issue
        data = redis_get(room_name, user_name)
        data['routing_keys'][routing_key] = true
        redis_set(room_name, user_name, data)
      end

      # Removes spam persistence for a routing key on a user
      def unpersist(room_name, user_name, routing_key)
        raise Error, "bad routing key '#{routing_key}'" unless routing_key.andand.is_a? String
        # TODO: Potential threading issue
        data = redis_get(room_name, user_name)
        data['routing_keys'].delete(routing_key)
        redis_set(room_name, user_name, data)
      end

      # Gets the persistence for a room or user. Prioritizes room.
      def redis_get(room_name, user_name)
        raise Error, 'no room or name' unless room_name || user_name
        data =
          if room_name
            redis_get_room(room_name)
          else
            redis_get_user(user_name)
          end
        data['routing_keys'] ||= {}
        data
      end

      def redis_get_rooms
        rooms_s = redis.get('rooms')
        rooms = JSON.parse(rooms_s) if rooms_s
        rooms ||= {}
        rooms
      end

      def redis_get_room(room_name)
        rooms = redis_get_rooms
        rooms[room_name] ||= {}
        rooms[room_name]
      end

      def redis_get_users
        users_s = redis.get('users')
        users = JSON.parse(users_s) if users_s
        users ||= {}
        users
      end

      def redis_get_user(user_name)
        users = redis_get_users
        users[user_name] ||= {}
        users[user_name]
      end

      # Sets the persistence for a room or user. Prioritizes room.
      def redis_set(room_name, user_name, data)
        raise Error, 'no room or name' unless room_name || user_name
        if room_name
          rooms = redis_get_rooms
          rooms[room_name] = data
          redis.set('rooms', rooms.to_json)
        else
          users = redis_get_users
          users[user_name] = data
          redis.set('users', users.to_json)
        end
      end

      # Starts all spams on join
      def start_all(_unpopulated_payload)
        log.info 'rooms starting'
        start_rooms
        log.info 'rooms started'

        log.info 'users starting'
        start_users
        log.info 'users started'
      end

      # Starts all room spam on join
      def start_rooms
        rooms_s = redis.get('rooms')
        rooms = JSON.parse(rooms_s) if rooms_s
        return unless rooms
        rooms.each do |room_name, data|
          data['routing_keys'].each do |routing_key, _true|
            spam(room_name, nil, routing_key)
          end
        end
      end

      # starts all user spam on join
      def start_users
        users_s = redis.get('users')
        users = JSON.parse(users_s) if users_s
        return unless users
        users.each do |user_name, data|
          data['routing_keys'].each do |routing_key, _true|
            spam(nil, user_name, routing_key)
          end
        end
      end
    end # class GamedevSpam
  end # module Handlers
end # module Lita
