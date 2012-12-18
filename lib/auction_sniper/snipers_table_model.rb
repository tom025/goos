require 'lib/swing'
require 'lib/auction_sniper/main_window'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'
require 'lib/column'

class AuctionSniper
  class SnipersTableModel < Swing::AbstractTableModel
    STATUS_TEXT = [
      MainWindow::STATUS_JOINING,
      MainWindow::STATUS_BIDDING,
      MainWindow::STATUS_WINNING,
      MainWindow::STATUS_LOST,
      MainWindow::STATUS_WON
    ]

    attr_reader :snapshots

    def initialize
      @snapshots = []
    end

    def add_sniper(snapshot)
      snapshots << snapshot
      row = row_count
      fire_table_rows_inserted(row, row)
    end

    def getColumnCount
      Column.length
    end

    def getRowCount
      snapshots.size
    end

    def getColumnName(column)
      Column.at(column).name
    end

    def getValueAt(row_index, column_index)
      Column.at(column_index).value_in(snapshots.fetch(row_index))
    end

    def sniper_state_changed(new_snapshot)
      row = row_matching(new_snapshot)
      @snapshots[row] = new_snapshot
      fire_table_rows_updated(row, row)
    end

    def row_matching(snapshot)
      snapshots.index { |s| s.item_id == snapshot.item_id } or
        raise IndexError, 'Snapshot not found in table model.'
    end

    def self.text_for(sniper_state)
      STATUS_TEXT[sniper_state.ordinal]
    end
  end
end

