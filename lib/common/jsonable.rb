
module Lemtzas
  module Common
    # An object that can convert to/from json.
    # implement from_json on your own.
    # include JSONable
    # def self.from_json(string) new.from_json!(string) end
    module JSONable
      def to_json
        hash = {}
        instance_variables.each do |var|
          hash[var] = instance_variable_get var
        end
        hash.to_json
      end

      def from_json!(string)
        JSON.load(string).each do |var, val|
          instance_variable_set var, val
        end
        self
      end
    end # module JSONable
  end # module Common
end # module Lemtzas
