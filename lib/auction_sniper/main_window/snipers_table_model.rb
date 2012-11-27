require 'lib/auction_sniper/main_window'
require 'lib/swing'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'
require 'lib/column'

class AuctionSniper
  class MainWindow < Swing::JFrame
    class SnipersTableModel < Swing::AbstractTableModel
      STATUS_TEXT = [
        STATUS_JOINING,
        STATUS_BIDDING,
        STATUS_WINNING,
        STATUS_LOST,
        STATUS_WON
      ]

      STARTING_UP = SniperSnapshot.new('-', '-', '-', SniperState::JOINING)

      attr_reader :sniper_snapshot, :status_text

      def initialize
        @sniper_snapshot = STARTING_UP
      end

      def getColumnCount
        Column.length
      end

      def getRowCount; 1; end

      def getValueAt(row_index, column_index)
        Column.at(column_index).value_in(sniper_snapshot)
      end

      def sniper_state_changed(new_sniper_snapshot)
        @sniper_snapshot = new_sniper_snapshot
        fire_table_rows_updated(0, 0)
      end

      def self.text_for(sniper_state)
        STATUS_TEXT[sniper_state.ordinal]
      end
    end
  end
end

