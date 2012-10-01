require 'java'
require 'org/smack/smack.jar'
require 'org/smack/smackx.jar'
require 'rspec'
require 'rspec/given'

module Smack
  include_package 'org/jivesoftware/smack'
  java_import org.jivesoftware.smack.XMPPConnection
end

module AuctionSniper; end

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = 'auction-%s'
  XMPP_HOSTNAME = 'localhost'
  AUCTION_PASSWORD = 'auction'
  AUCTION_RESOURCE = 'Auction'

  def initialize(item_id)
    @item_id = item_id
    @connection = Smack::XMPPConnection.new(XMPP_HOSTNAME)
  end

  def start_selling_item
    @connection.connect
    @connection.login(ITEM_ID_AS_LOGIN % @item_id,
                      AUCTION_PASSWORD,
                      AUCTION_RESOURCE)
  end
end

class ApplicationRunner
  def start_bidding_in(auction)
  end
end

describe AuctionSniper do
  after do
    auction.stop
    application.stop
  end

  Given(:auction) { FakeAuctionServer.new('item-54321') }
  Given(:application) { ApplicationRunner.new }

  context 'sniper joins auction until auction closes' do
    When { auction.start_selling_item }
    When { application.start_bidding_in(auction) }
    When { auction.has_received_join_request_from_sniper }
    When { auction.announce_closed }
    Then { application.shows_sniper_has_lost_auction }
  end

end
