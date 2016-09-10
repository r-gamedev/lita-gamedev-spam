require 'common/tracking'
require 'json'

module Lemtzas
  module Common
    module Messaging
      # The base message class.
      # Handles serialization, deserialization, and typing selection.
      class Message
        include Trackable
        attr_accessor :message_type

        def initialize
          @message_type = self.class.to_s
        end

        # Serialize a message to a string
        def serialize
          hash = {}
          instance_variables.each do |var|
            hash[var] = instance_variable_get var
          end
          hash.to_json
        end

        # Deserialize a message to a native type, or nil.
        def self.deserialize(string)
          base = JSON.load(string)
          type = Object.const_get(base['@message_type'])
          obj = type.allocate
          JSON.load(string).each do |var, val|
            obj.instance_variable_set var, val
          end
          obj
        rescue NameError
          nil
        end
      end
    end # module Messaging
  end # module Common
end # module Lemtzas
