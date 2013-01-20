require 'lib/smack'
require 'lib/swing'
require 'lib/awt'
require 'lib/auction_sniper/auction_message_translator'
require 'lib/auction_sniper/snipers_table_model'
require 'lib/auction_sniper/swing_thread_sniper_listener'
require 'lib/user_request'
require 'lib/auction_sniper/auction'
require 'lib/auction_event_listeners'

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

    def disconnect_when_ui_closes(connection)
      window_adapter = WindowAdapter.new
      window_adapter.connection = connection
      @ui.add_window_listener(window_adapter)
    end

    def add_user_request_listener_for(connection)
      @ui.add_user_request_listener(UserRequest.new { |item_id|
        @snipers.add_sniper(SniperSnapshot.joining(item_id))
        chat = connection.get_chat_manager.
          create_chat(auction_id(item_id, connection), nil)
        @not_to_be_gced << chat

        auction_event_listeners = AuctionEventListeners.new
        auction = Auction.new(chat)

        chat.add_message_listener(
          AuctionMessageTranslator.new(
            connection.user,
            auction_event_listeners
          ))

        auction_event_listeners <<(
          AuctionSniper.new(item_id,
                            auction,
                            SwingThreadSniperListener.new(@snipers))
        )

        auction.join
      })
    end

    private
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

