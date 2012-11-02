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
      @snipers = SniperTableModel.new
      set_name(MAIN_WINDOW_NAME)
      fill_content_pane(make_snipers_table)
      pack
      set_default_close_operation(Swing::JFrame::EXIT_ON_CLOSE)
      set_visible(true)
    end

    def show_status(text)
      @snipers.set_status(text)
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

    class SniperTableModel < Swing::AbstractTableModel
      def initialize
        @status_text = STATUS_JOINING
      end

      def getColumnCount; 1; end 
      def getRowCount; 1; end

      def getValueAt(row, column); @status_text; end

      def set_status(new_status)
        @status_text = new_status
        fire_table_rows_updated(0, 0)
      end
    end

  end
end
