require 'lib/auction_sniper/main'
require 'lib/auction_sniper/main_window'

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

  def initialize(auction, sniper_listener)
    @auction = auction
    @sniper_listener = sniper_listener
  end

  def auction_closed
    @sniper_listener.sniper_lost
  end

  def current_price(price, increment, price_source)
    @sniper_listener.sniper_bidding
    @auction.bid(price + increment)
  end
end

