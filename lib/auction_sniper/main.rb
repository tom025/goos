require 'lib/smack'
require 'lib/swing'
require 'lib/awt'
require 'lib/auction_sniper/auction_message_translator'
require 'lib/auction_sniper/snipers_table_model'
require 'lib/auction_sniper/swing_thread_sniper_listener'

class AuctionSniper
  class Main
    AUCTION_RESOURCE = 'Auction'
    ITEM_ID_AS_LOGIN = 'auction-%s'
    AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + '@%s/' + AUCTION_RESOURCE

    def initialize
      @snipers = SnipersTableModel.new
      @not_to_be_gced = []
    end

    def start_user_interface
      Swing::SwingUtilities.invoke_and_wait do
        @ui = MainWindow.new(@snipers)
      end
    end

    def join_auction(connection, item_id)
      safely_add_item_to_model(item_id)
      chat = connection.get_chat_manager.
        create_chat(auction_id(item_id, connection), nil)
      @not_to_be_gced << chat
      auction = Auction.new(chat)
      chat.add_message_listener(
        AuctionMessageTranslator.new(
          connection.user,
          AuctionSniper.new(item_id, auction, SwingThreadSniperListener.new(@snipers)))
      )
      auction.join
    end

    def disconnect_when_ui_closes(connection)
      window_adapter = WindowAdapter.new
      window_adapter.connection = connection
      @ui.add_window_listener(window_adapter)
    end

    private
    def safely_add_item_to_model(item_id)
      Swing::SwingUtilities.invoke_and_wait do
        @snipers.add_sniper(SniperSnapshot.joining(item_id))
      end
    end

    def auction_id(item_id, connection)
      AUCTION_ID_FORMAT % [item_id, connection.get_service_name]
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

  attr_reader :item_id
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

