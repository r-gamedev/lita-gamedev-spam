require 'spec_helper'

# TODO: Figure out how to make this work...
describe Lita::Handlers::GamedevSpam, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }
  subject { described_class.new(robot) }

  describe '#run' do
    it { is_expected.to route_event(:connected) }
  end
end
