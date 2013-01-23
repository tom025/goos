require 'lib/awt'
require 'lib/swing'
require 'lib/auction_sniper/sniper_launcher'
require 'lib/sniper_portfolio'
require 'lib/auction_sniper/main_window'

class AuctionSniper
  class Main
    attr_reader :portfolio, :ui
    private :portfolio, :ui
    def initialize
      @portfolio = SniperPortfolio.new
    end

    def start_user_interface
      Swing::SwingUtilities.invoke_and_wait do
        @ui = MainWindow.new(portfolio)
      end
    end

    def disconnect_when_ui_closes(auction_house)
      window_adapter = WindowAdapter.new
      window_adapter.auction_house = auction_house
      ui.add_window_listener(window_adapter)
    end

    def add_user_request_listener_for(auction_house)
      ui.add_user_request_listener(
        SniperLauncher.new(auction_house, portfolio)
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

