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
  java_import org.jivesoftware.smack.packet.Message
end

module WindowLicker
  include_package 'com/objogate/wl'
  include_package 'com/objogate/wl/swing'
  java_import com.objogate.wl.swing.driver.JFrameDriver
  java_import com.objogate.wl.swing.driver.JLabelDriver
  java_import com.objogate.wl.swing.gesture.GesturePerformer
  java_import com.objogate.wl.swing.AWTEventQueueProber
end

module Hamcrest
  java_import org.hamcrest.Matchers
end

module Swing
  java_import javax.swing.SwingUtilities
  java_import javax.swing.JFrame
  java_import javax.swing.JLabel
  java_import javax.swing.border.LineBorder
end

module AWT
  java_import java.awt.Color
end

module JConcurrent
  java_import java.util.concurrent.ArrayBlockingQueue
  java_import java.util.concurrent.TimeUnit
end

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

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = 'auction-%s'
  XMPP_HOSTNAME = 'localhost'
  AUCTION_PASSWORD = 'auction'
  AUCTION_RESOURCE = 'Auction'

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
    @connection.get_chat_manager.add_chat_listener(ChatManagerListener.new(self))
  end

  def has_received_join_request_from_sniper
    message_listener.receives_a_message
  end

  def announce_closed
    current_chat.send_message(Smack::Message.new)
  end

  def stop
    @connection.disconnect
  end

  class ChatManagerListener
    def initialize(chat_observer)
      @chat_observer = chat_observer
    end

    def chat_created(chat, created_locally)
      @chat_observer.current_chat = chat
      chat.add_message_listener(@chat_observer.message_listener)
    end
  end

  class SingleMessageListener
    include RSpec::Matchers

    def initialize
      @messages = JConcurrent::ArrayBlockingQueue.new(1)
    end

    def process_message(chat, message)
      @messages.add(message)
    end

    def receives_a_message
      @messages.poll(5, JConcurrent::TimeUnit::SECONDS).should_not be_nil
    end

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
