require 'securerandom'

module Lemtzas
  module Common
    # A mixin for making a class trackable.
    module Trackable
      attr_accessor :uuid,
                    :parent_uuid,
                    :script_uuid

      # Add tracking information to an object
      # @param parent The Parent Trackable. Omit if no trackable parent.
      def track(parent = nil)
        @script_uuid ||= Tracking.script_uuid
        @parent_uuid ||= parent.uuid if parent && parent.is_a?(Trackable)
        @uuid ||= SecureRandom.uuid
        self
      end
    end # module Trackable

    # Handles tracking tasks
    module Tracking
      # Gets the UUID for this script.
      # rubocop:disable Style/GlobalVars
      def self.script_uuid
        $script_uuid ||= SecureRandom.uuid
      end
    end # module Tracking
  end # module Common
end # module Lemtzas
