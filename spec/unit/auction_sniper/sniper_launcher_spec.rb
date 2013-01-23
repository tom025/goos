require 'lib/auction_sniper/sniper_launcher'

class AuctionSniper
  describe SniperLauncher do
    let(:item_id) { 'item-123' }
    let(:auction) { double(:auction) }
    let(:auction_state) { AuctionState.new('not joined') }
    let(:auction_house) { double(:auction_house) }
    let(:sniper) { double(:sniper) }
    let(:sniper_collector) { double(:sniper_collector) }
    let(:launcher) { SniperLauncher.new(auction_house, sniper_collector) }

    before do
      auction_house.stub(:auction_for).with(item_id) { auction }
      AuctionSniper.stub(:new).with(item_id, auction) { sniper }
    end

    it 'adds a new sniper to a collector then joins auction' do
      auction.should_receive(:add_auction_event_listener).with(sniper) do
        auction_state.state.should == 'not joined'
      end

      sniper_collector.should_receive(:add_sniper).with(sniper) do
        auction_state.state.should == 'not joined'
      end

      auction.should_receive(:join) do
        auction_state.state = 'joined'
      end

      launcher.join_auction(item_id)
    end

    class AuctionState
      attr_accessor :state
      def initialize(initail_state)
        @state = initail_state
      end

      def is?(state)
        @state == state
      end
    end
  end
end
