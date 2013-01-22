require 'lib/smack'
require 'lib/swing'
require 'lib/awt'
require 'lib/auction_sniper/snipers_table_model'
require 'lib/auction_sniper/swing_thread_sniper_listener'
require 'lib/user_request'
require 'lib/auction_sniper/xmpp_auction'

class AuctionSniper
  class Main
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

        auction = XMPPAuction.new(connection, item_id)
        @not_to_be_gced << auction

        auction.add_auction_event_listener(
          AuctionSniper.new(item_id,
                            auction,
                            SwingThreadSniperListener.new(@snipers))
        )
        auction.join
      })
    end

    class WindowAdapter < AWT::WindowAdapter
      attr_accessor :connection
      def windowClosed(event)
        connection.disconnect
      end
    end
  end

end

