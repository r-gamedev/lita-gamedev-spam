require 'spec_helper'

describe Lita::Handlers::GamedevSpam, lita_handler: true do
  describe '#run' do
    it { is_expected.to route_event(:connected) }
  end
end
