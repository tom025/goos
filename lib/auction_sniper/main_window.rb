require 'lib/swing'
require 'lib/awt'

class AuctionSniper
  class MainWindow < Swing::JFrame
    SNIPER_TABLE_NAME = 'Sniper Table'
    SNIPER_STATUS_NAME = 'status'
    MAIN_WINDOW_NAME = 'Auction Sniper'
    STATUS_JOINING = 'joining'
    STATUS_BIDDING = 'bidding'
    STATUS_WINNING = 'winning'
    STATUS_LOST = 'lost'
    STATUS_WON = 'won'

    attr_accessor :sniper_status

    def initialize
      super("Auction Sniper")
      @snipers = SnipersTableModel.new
      set_name(MAIN_WINDOW_NAME)
      fill_content_pane(make_snipers_table)
      pack
      set_default_close_operation(Swing::JFrame::EXIT_ON_CLOSE)
      set_visible(true)
    end

    def sniper_state_changed(sniper_snapshot)
      @snipers.sniper_state_changed(sniper_snapshot)
    end

    private
    def fill_content_pane(snipers_table)
      content_pane.layout = AWT::BorderLayout.new
      content_pane.add(Swing::JScrollPane.new(snipers_table), AWT::BorderLayout::CENTER)
    end

    def make_snipers_table
      snipers_table = Swing::JTable.new(@snipers)
      snipers_table.name = SNIPER_TABLE_NAME
      snipers_table
    end

  end
end
