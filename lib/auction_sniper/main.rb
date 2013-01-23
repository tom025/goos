require 'lib/awt'
require 'lib/auction_sniper/snipers_table_model'
require 'lib/auction_sniper/swing_thread_sniper_listener'
require 'lib/user_request'
require 'lib/auction_sniper/xmpp_auction_house'

class AuctionSniper
  class Main
    attr_reader :snipers, :ui
    private :snipers, :ui
    def initialize
      @snipers = SnipersTableModel.new
    end

    def start_user_interface
      Swing::SwingUtilities.invoke_and_wait do
        @ui = MainWindow.new(snipers)
      end
    end

    def disconnect_when_ui_closes(auction_house)
      window_adapter = WindowAdapter.new
      window_adapter.auction_house = auction_house
      ui.add_window_listener(window_adapter)
    end

    def add_user_request_listener_for(auction_house)
      ui.add_user_request_listener(
        SniperLauncher.new(auction_house, snipers)
      )
    end

    class WindowAdapter < AWT::WindowAdapter
      attr_accessor :auction_house
      def windowClosed(event)
        auction_house.disconnect
      end
    end
  end

end

