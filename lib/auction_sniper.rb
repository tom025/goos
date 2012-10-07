require 'lib/smack'
require 'lib/swing'
require 'lib/awt'

module AuctionSniper
  SNIPER_STATUS_NAME = 'status'
  AUCTION_RESOURCE = 'Auction'

  def self.start(hostname, sniper_id, password, item_id)
    main = Main.new
    main.join_auction(connection(hostname, sniper_id, password), item_id)
  end

  class Main
    ITEM_ID_AS_LOGIN = 'auction-%s'
    AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + '@%s/' + AUCTION_RESOURCE

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
    MAIN_WINDOW_NAME = 'Auction Sniper'
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

