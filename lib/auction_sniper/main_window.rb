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

    def show_status(text)
      @snipers.set_status(text)
    end

    def sniper_status_changed(sniper_state, status_text)
      @snipers.sniper_status_changed(sniper_state, status_text)
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

    require 'lib/sniper_state'
    class SnipersTableModel < Swing::AbstractTableModel
      STARTING_UP = SniperState.new('-', '-', '-')
      COLUMNS = [:item_identifier, :last_price, :last_bid, :sniper_status]

      attr_reader :sniper_state, :status_text

      def initialize
        @status_text = STATUS_JOINING
        @sniper_state = STARTING_UP
      end

      def getColumnCount
        COLUMNS.length
      end

      def getRowCount; 1; end

      def getValueAt(row_index, column_index)
        column_name = COLUMNS.at(column_index)
        case column_name
        when :item_identifier then sniper_state.item_id
        when :last_price then sniper_state.last_price
        when :last_bid then sniper_state.last_bid
        when :sniper_status then status_text
        else raise ArgumentError, "No column at #{column_index}"
        end
      end

      def sniper_status_changed(new_sniper_state, new_status_text)
        @sniper_state = new_sniper_state
        @status_text = new_status_text
        fire_table_rows_updated(0, 0)
      end

      def set_status(new_status)
        @status_text = new_status
        fire_table_rows_updated(0, 0)
      end
    end

  end
end
