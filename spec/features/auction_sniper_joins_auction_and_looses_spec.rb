require 'java'
require 'org/smack/smack.jar'
require 'org/smack/smackx.jar'
require 'org/window_licker/windowlicker-swing-DEV.jar'
require 'org/window_licker/windowlicker-core-DEV.jar'
require 'org/hamcrest/hamcrest-all-SNAPSHOT.jar'
require 'rspec'
require 'rspec/given'

module Smack
  include_package 'org/jivesoftware/smack'
  java_import org.jivesoftware.smack.XMPPConnection
end

module WindowLicker
  include_package 'com/objogate/wl'
  include_package 'com/objogate/wl/swing'
  java_import com.objogate.wl.swing.driver.JFrameDriver
  java_import com.objogate.wl.swing.gesture.GesturePerformer
  java_import com.objogate.wl.swing.AWTEventQueueProber
end

module AuctionSniper
  MAIN_WINDOW_NAME = 'Auction Sniper'
  STATUS_JOINING = 'joining'
  def self.start(hostname, sniper_id, password, auction_item_id)
  end
end

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
  XMPP_HOSTNAME = 'localhost'
  def start_bidding_in(auction)
    Thread.new("Test Application") do
      begin
        AuctionSniper.start(XMPP_HOSTNAME, SNIPER_ID, SNIPER_PASSWORD, auction.item_id)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
    @driver = AuctionSniperDriver.with_timeout(1000)
    @driver.shows_sniper_status(AuctionSniper::STATUS_JOINING)
  end

  class AuctionSniperDriver < WindowLicker::JFrameDriver
    def self.with_timeout(timeout)
      top_level_driver = WindowLicker::JFrameDriver.top_level_frame(named(AuctionSniper::MAIN_WINDOW_NAME), showing_on_screen)
      gesture_performer = WindowLicker::GesturePerformer.new
      event_queue_probe = WindowLicker::AWTEventQueueProber.new(timeout, 100)
      new(gesture_performer, top_level_driver, event_queue_probe)
    end
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
