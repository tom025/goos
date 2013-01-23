require 'lib/auction_sniper'
require 'lib/sniper_snapshot'
require 'lib/auction_sniper/swing_thread_sniper_listener'

class AuctionSniper
  class SniperLauncher
    attr_reader :auction_house, :collector
    private :auction_house, :collector

    def initialize(auction_house, collector)
      @auction_house = auction_house
      @collector = collector
    end

    def join_auction(item_id)
      auction = auction_house.auction_for(item_id)
      sniper = AuctionSniper.new(item_id, auction)

      auction.add_auction_event_listener(sniper)
      collector.add_sniper(sniper)
      auction.join
    end
  end
end
