require 'lib/auction_sniper/main'
require 'lib/auction_sniper/main_window'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'

class AuctionSniper
  def self.start(hostname, sniper_id, password, *item_ids)
    main = Main.new
    main.start_user_interface
    connection = connection(hostname, sniper_id, password)
    main.disconnect_when_ui_closes(connection)
    item_ids.each do |item_id|
      main.join_auction(connection, item_id)
    end
  end

  def self.connection(hostname, username, password)
    connection = Smack::XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, Main::AUCTION_RESOURCE)
    connection
  end

  attr_reader :snapshot
  def initialize(item_id, auction, sniper_listener)
    @auction = auction
    @snapshot = SniperSnapshot.joining(item_id)
    @sniper_listener = sniper_listener
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
    @sniper_listener.sniper_state_changed(snapshot)
  end
end

