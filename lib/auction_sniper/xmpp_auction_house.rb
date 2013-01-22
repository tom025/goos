require 'lib/smack'
require 'lib/auction_sniper/xmpp_auction'

class XMPPAuctionHouse
  def self.connect(hostname, username, password)
    connection = Smack::XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, XMPPAuction::AUCTION_RESOURCE)
    new(connection)
  end

  attr_reader :connection
  private :connection
  def initialize(connection)
    @connection = connection
  end

  def auction_for(item_id)
    XMPPAuction.new(connection, item_id)
  end

  def disconnect
    connection.disconnect
  end
end
