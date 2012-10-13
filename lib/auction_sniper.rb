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
end

