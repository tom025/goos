require 'lib/auction_sniper/main'
require 'lib/auction_sniper/main_window'

module AuctionSniper
  def self.start(hostname, sniper_id, password, item_id)
    main = Main.new
    main.join_auction(connection(hostname, sniper_id, password), item_id)
  end

  def self.connection(hostname, username, password)
    connection = Smack::XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, Main::AUCTION_RESOURCE)
    connection
  end
end

