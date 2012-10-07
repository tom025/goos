require 'lib/swing'
require 'lib/awt'

module AuctionSniper
  class MainWindow < Swing::JFrame
    SNIPER_STATUS_NAME = 'status'
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
end
