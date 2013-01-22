require 'lib/auction_event_listeners'
require 'lib/auction_message_translator'

class XMPPAuction
  AUCTION_RESOURCE = 'Auction'
  ITEM_ID_AS_LOGIN = 'auction-%s'
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + '@%s/' + AUCTION_RESOURCE

  JOIN_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Join;'
  BID_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Bid; Amount: %d'

  attr_reader :item_id
  def initialize(connection, item_id)
    @auction_event_listeners = AuctionEventListeners.new
    @chat = connection.get_chat_manager.
                       create_chat(
                         auction_id(item_id, connection),
                         AuctionMessageTranslator.new(connection.user,
                                                      @auction_event_listeners))

  end

  def add_auction_event_listener(listener)
    @auction_event_listeners << listener
  end

  def bid(amount)
    send_message(BID_COMMAND_FORMAT % amount)
  end

  def join
    send_message(JOIN_COMMAND_FORMAT)
  end

  private
  def auction_id(item_id, connection)
    AUCTION_ID_FORMAT % [item_id, connection.get_service_name]
  end

  def send_message(message)
    @chat.send_message(message)
  rescue XMPPException => e
    puts e.message
  end
end
