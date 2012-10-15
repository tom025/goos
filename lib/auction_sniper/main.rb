require 'lib/smack'
require 'lib/swing'
require 'lib/awt'
require 'lib/auction_sniper/auction_message_translator'

class AuctionSniper
  class Main
    AUCTION_RESOURCE = 'Auction'
    ITEM_ID_AS_LOGIN = 'auction-%s'
    AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + '@%s/' + AUCTION_RESOURCE

    def start_user_interface
      Swing::SwingUtilities.invoke_and_wait do
        @ui = MainWindow.new
      end
    end

    def join_auction(connection, item_id)
      disconnect_when_ui_closes(connection)
      chat = connection.get_chat_manager.
        create_chat(auction_id(item_id, connection), nil)
      @not_to_be_gced = chat
      auction = Auction.new(chat)
      chat.add_message_listener(
        AuctionMessageTranslator.new(
          connection.user,
          AuctionSniper.new(auction, SniperStateDisplayer.new(@ui)))
      )
      auction.join
    end

    class SniperStateDisplayer
      def initialize(ui)
        @ui = ui
      end

      def sniper_won
        show_status(MainWindow::STATUS_WON)
      end

      def sniper_lost
        show_status(MainWindow::STATUS_LOST)
      end

      def sniper_bidding
        show_status(MainWindow::STATUS_BIDDING)
      end

      def sniper_winning
        show_status(MainWindow::STATUS_WINNING)
      end

      private
      def show_status(status)
        Swing::SwingUtilities.invoke_later { @ui.show_status(status) }
      end
    end

    private
    def auction_id(item_id, connection)
      AUCTION_ID_FORMAT % [item_id, connection.get_service_name]
    end

    def disconnect_when_ui_closes(connection)
      window_adapter = WindowAdapter.new
      window_adapter.connection = connection
      @ui.add_window_listener(window_adapter)
    end

    class WindowAdapter < AWT::WindowAdapter
      attr_accessor :connection
      def windowClosed(event)
        connection.disconnect
      end
    end
  end
end

class Auction
  JOIN_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Join;'
  BID_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Bid; Amount: %d'

  def initialize(chat)
    @chat = chat
  end

  def bid(amount)
    send_message(BID_COMMAND_FORMAT % amount)
  end

  def join
    send_message(JOIN_COMMAND_FORMAT)
  end

  private
  def send_message(message)
    @chat.send_message(message)
  rescue XMPPException => e
    puts e.message
  end
end

