require 'lib/auction_sniper/main_window'

class AuctionSniper
  class MainWindow
    describe SnipersTableModel do

      let(:model) { SnipersTableModel.new }
      let(:listener) { double(:table_model_listener) }

      before do
        model.add_table_model_listener(listener)
      end

      it 'has the correct number of columns' do
        model.getColumnCount.should == SnipersTableModel::COLUMNS.length
      end

      it 'sets the values of the columns' do
        listener.should_receive(:table_changed)

        sniper_snapshot = SniperSnapshot.new('item-1234', 555, 666, SniperState::BIDDING)
        model.sniper_state_changed(sniper_snapshot)

        column_should_be(:item_identifier, 'item-1234')
        column_should_be(:last_price, 555)
        column_should_be(:last_bid, 666)
        column_should_be(:sniper_status, STATUS_BIDDING)
      end

      def column_should_be(column_name, expected)
        row_index = 0
        column_index = SnipersTableModel::COLUMNS.index(column_name)
        model.getValueAt(row_index, column_index).should == expected
      end

    end
  end
end
