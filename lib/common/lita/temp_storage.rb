require 'andand'

module Lemtzas
  module Common
    module Lita
      # Temporary storage for lita, based on users and rooms.
      class TempStorage
        def initialize
          @user_data = {}
          @room_data = {}
        end

        # Get the storage object for the user or room. Room prioritized.
        def [](room_name, user_name)
          if room_name
            room(room_name)
          else
            user(user_name)
          end
        end

        # Get the storage object for the user.
        def user(user_name)
          raise 'bad user name' unless user_name.andand.is_a? String
          @user_data[user_name] ||= OpenStruct.new
        end

        # Get the storage object for the room.
        def room(room_name)
          raise 'bad room name' unless room_name.andand.is_a? String
          @room_data[room_name] ||= OpenStruct.new
        end
      end # class TempStorage
    end # module Lita
  end # module Common
end # module Lemtzas
