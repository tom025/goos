require 'lib/auction_sniper/main'
require 'lib/auction_sniper/main_window'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'

class AuctionSniper
  def self.start(hostname, sniper_id, password, item_id)
    main = Main.new
    main.start_user_interface
    main.join_auction(connection(hostname, sniper_id, password), item_id)
  end

  def self.connection(hostname, username, password)
    connection = Smack::XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, Main::AUCTION_RESOURCE)
    connection
  end

  attr_reader :item_id
  def initialize(item_id, auction, sniper_listener)
    @auction = auction
    @item_id = item_id
    @sniper_listener = sniper_listener
    @winning = false
  end

  def auction_closed
    if @winning
      @sniper_listener.sniper_won
    else
      @sniper_listener.sniper_lost
    end
  end

  def current_price(price, increment, price_source)
    @winning = price_source == :from_sniper
    if @winning
      @sniper_listener.sniper_winning
    else
      bid = price + increment
      sniper_snapshot = SniperSnapshot.new(item_id, price, bid, SniperState::BIDDING)
      @sniper_listener.sniper_state_changed(sniper_snapshot)
      @auction.bid(price + increment)
    end
  end
end

