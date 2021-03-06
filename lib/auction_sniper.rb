require 'lib/auction_sniper/main'
require 'lib/auction_sniper/xmpp_auction'
require 'lib/auction_sniper/main_window'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'
require 'lib/sniper_listeners'

class AuctionSniper
  def self.start(hostname, sniper_id, password, *item_ids)
    main = Main.new
    main.start_user_interface
    auction_house = XMPPAuctionHouse.connect(hostname, sniper_id, password)
    main.disconnect_when_ui_closes(auction_house)
    main.add_user_request_listener_for(auction_house)
  end

  attr_reader :snapshot
  def initialize(item_id, auction)
    @auction = auction
    @snapshot = SniperSnapshot.joining(item_id)
    @sniper_listeners = SniperListeners.new
  end

  def add_sniper_listener(sniper_listener)
    @sniper_listeners << sniper_listener
  end

  def auction_closed
    @snapshot = snapshot.closed
    notify_change
  end

  def current_price(price, increment, price_source)
    case price_source
    when :from_sniper
      @snapshot = snapshot.winning(price)
    when :from_other_bidder
      bid = price + increment
      @snapshot = snapshot.bidding(price, bid)
      @auction.bid(bid)
    end
    notify_change
  end

  private
  def notify_change
    @sniper_listeners.notify(:sniper_state_changed, snapshot)
  end
end

