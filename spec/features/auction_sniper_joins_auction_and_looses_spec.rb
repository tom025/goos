require 'spec_helper'
require 'lib/smack'
require 'lib/swing'
require 'lib/awt'

module AuctionSniper
  MAIN_WINDOW_NAME = 'Auction Sniper'
  SNIPER_STATUS_NAME = 'status'
  AUCTION_RESOURCE = 'Auction'
  ITEM_ID_AS_LOGIN = 'auction-%s'
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + '@%s/' + AUCTION_RESOURCE

  def self.start(hostname, sniper_id, password, item_id)
    main = Main.new
    main.join_auction(connection(hostname, sniper_id, password), item_id)
  end

  class Main
    def initialize
      start_user_interface
    end

    def start_user_interface
      Swing::SwingUtilities.invoke_and_wait do
        @ui = MainWindow.new
      end
    end

    def join_auction(connection, item_id)
      chat = connection.get_chat_manager.
        create_chat(auction_id(item_id, connection)) do |a_chat, message|
          Swing::SwingUtilities.invoke_later do
            @ui.show_status(MainWindow::STATUS_LOST)
          end
        end
      chat.send_message(Smack::Message.new)
    end

    private
    def auction_id(item_id, connection)
      AUCTION_ID_FORMAT % [item_id, connection.get_service_name]
    end

  end

  private
  class MainWindow < Swing::JFrame
    STATUS_JOINING = 'joining'
    STATUS_LOST = 'lost'

    attr_accessor :sniper_status

    def initialize
      super("Auction Sniper")
      @sniper_status = create_label(STATUS_JOINING)
      set_name(MAIN_WINDOW_NAME)
      add(sniper_status)
      pack
      set_default_close_operation(Swing::JFrame::EXIT_ON_CLOSE)
      set_visible(true)
    end

    def show_status(text)
      @sniper_status.set_text(text)
    end

    private
    def create_label(initial_text)
      label = Swing::JLabel.new(initial_text)
      label.set_name(SNIPER_STATUS_NAME)
      label.set_border(Swing::LineBorder.new(AWT::Color::BLACK))
      label
    end
  end

  def self.connection(hostname, username, password)
    connection = Smack::XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    connection
  end
end

class ApplicationRunner
  XMPP_HOSTNAME = 'localhost'
  SNIPER_ID = 'sniper'
  SNIPER_PASSWORD = 'sniper'

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
    @driver.shows_sniper_status(AuctionSniper::MainWindow::STATUS_JOINING)
  end

  def shows_sniper_has_lost_auction
    @driver.shows_sniper_status(AuctionSniper::MainWindow::STATUS_LOST)
  end

  def stop
    @driver.dispose if @driver
  end

  class AuctionSniperDriver < WindowLicker::JFrameDriver

    def self.with_timeout(timeout)
      top_level_driver = WindowLicker::JFrameDriver.top_level_frame(
        named(AuctionSniper::MAIN_WINDOW_NAME), showing_on_screen)
      gesture_performer = WindowLicker::GesturePerformer.new
      event_queue_probe = WindowLicker::AWTEventQueueProber.new(timeout, 100)
      new(gesture_performer, top_level_driver, event_queue_probe)
    end

    def shows_sniper_status(text)
      WindowLicker::JLabelDriver.new(
        self, named(AuctionSniper::SNIPER_STATUS_NAME)).has_text(equal_to(text))
    end

    def named(*args)
      self.class.named(*args)
    end

    def method_missing(method_name, *args, &block)
      begin
        Hamcrest::Matchers.send(method_name, *args)
      rescue NoMethodError
        super
      end
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
