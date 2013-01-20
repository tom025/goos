require 'lib/smack'
require 'fake_auction_server/single_message_listener'

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = 'auction-%s'
  XMPP_HOSTNAME = 'localhost'
  AUCTION_PASSWORD = 'auction'
  AUCTION_RESOURCE = 'Auction'

  include RSpec::Matchers

  attr_accessor :current_chat, :message_listener, :item_id

  def initialize(item_id)
    @item_id = item_id
    @connection = Smack::XMPPConnection.new(XMPP_HOSTNAME)
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    @connection.connect
    @connection.login(ITEM_ID_AS_LOGIN % @item_id,
                      AUCTION_PASSWORD,
                      AUCTION_RESOURCE)
    @connection.get_chat_manager.add_chat_listener do |chat, created_locally|
      @current_chat = chat
      chat.add_message_listener(@message_listener)
    end
  end

  def report_price(price, increment, bidder)
    @current_chat.send_message("SOLVersion: 1.1; Event: PRICE; " +
                               "CurrentPrice: #{price}; Increment: #{increment}; " +
                               "Bidder: #{bidder};")
  end

  def has_received_join_request_from(sniper_id)
    receives_a_message_matching(
      sniper_id, eq(XMPPAuction::JOIN_COMMAND_FORMAT))
  end

  def has_received_bid(bid, sniper_id)
    receives_a_message_matching(sniper_id, eq(XMPPAuction::BID_COMMAND_FORMAT % bid))
  end

  def announce_closed
    current_chat.send_message("SOLVersion: 1.1; Event: CLOSE;")
  end

  def stop
    @connection.disconnect
  end

  private
  def receives_a_message_matching(sniper_id, matcher)
    @message_listener.receives_a_message(matcher)
    @current_chat.participant.should == sniper_id
  end
end
