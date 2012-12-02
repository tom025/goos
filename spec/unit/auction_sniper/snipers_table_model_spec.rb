require 'lib/auction_sniper/snipers_table_model'

class AuctionSniper
  class MainWindow
    describe SnipersTableModel do

      let(:model) { SnipersTableModel.new }
      let(:listener) { double(:table_model_listener) }

      before do
        model.add_table_model_listener(listener)
      end

      it 'has the correct number of columns' do
        model.getColumnCount.should == Column.length
      end

      it 'sets the values of the columns' do
        listener.should_receive(:table_changed)

        sniper_snapshot = SniperSnapshot.new('item-1234', 555, 666, SniperState::BIDDING)
        model.sniper_state_changed(sniper_snapshot)

        column_should_be(Column::ITEM_IDENTIFIER, 'item-1234')
        column_should_be(Column::LAST_PRICE, 555)
        column_should_be(Column::LAST_BID, 666)
        column_should_be(Column::SNIPER_STATE, STATUS_BIDDING)
      end

      def column_should_be(column, expected)
        row_index = 0
        column_index = column.ordinal
        model.getValueAt(row_index, column_index).should == expected
      end

    end
  end
end
