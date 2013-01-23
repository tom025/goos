require 'lib/auction_sniper'
require 'lib/sniper_snapshot'
require 'lib/auction_sniper/swing_thread_sniper_listener'

class AuctionSniper
  class SniperLauncher
    attr_reader :auction_house, :snipers
    private :auction_house, :snipers

    def initialize(auction_house, snipers)
      @auction_house = auction_house
      @snipers = snipers
      @not_to_be_gced = []
    end

    def join_auction(item_id)
      snipers.add_sniper(SniperSnapshot.joining(item_id))

      auction = auction_house.auction_for(item_id)
      @not_to_be_gced << auction

      auction.add_auction_event_listener(
        AuctionSniper.new(item_id,
                          auction,
                          SwingThreadSniperListener.new(snipers))
      )
      auction.join
    end
  end
end
