module Lita
  module Handlers
    # GamedevSpam handler.
    class GamedevSpam < Handler
      # insert handler code here

      Lita.register_handler(self)

      on(:connected) do |payload|
        target = Source.new(room: payload[:room])
        robot.send_message(target, "Hello #{payload[:room]}!")
      end
    end
  end
end
