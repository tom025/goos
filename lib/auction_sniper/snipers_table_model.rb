require 'lib/swing'
require 'lib/sniper_state'
require 'lib/sniper_snapshot'
require 'lib/column'

class AuctionSniper
  class SnipersTableModel < Swing::AbstractTableModel
    STATUS_JOINING = 'joining'
    STATUS_BIDDING = 'bidding'
    STATUS_WINNING = 'winning'
    STATUS_LOST = 'lost'
    STATUS_WON = 'won'

    STATUS_TEXT = [
      STATUS_JOINING,
      STATUS_BIDDING,
      STATUS_WINNING,
      STATUS_LOST,
      STATUS_WON
    ]

    attr_reader :snapshots

    def initialize
      @snapshots = []
    end

    def sniper_added(sniper)
      add_sniper_snapshot(sniper.snapshot)
      sniper.add_sniper_listener(SwingThreadSniperListener.new(self))
    end

    def add_sniper_snapshot(snapshot)
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

