require 'lib/auction_sniper/snipers_table_model'

class AuctionSniper
  class MainWindow
    describe SnipersTableModel do

      let(:model) { SnipersTableModel.new }
      let(:listener) { double(:table_model_listener, :table_changed => nil) }

      before do
        model.add_table_model_listener(listener)
      end

      it 'has the correct number of columns' do
        model.getColumnCount.should == Column.length
      end

      it 'sets the values of the columns' do
        listener.should_receive(:table_changed)

        model.add_sniper(SniperSnapshot.joining('item-1234'))

        cell_value(0, Column::ITEM_IDENTIFIER).should == 'item-1234'
        cell_value(0, Column::LAST_PRICE).should == '-'
        cell_value(0, Column::LAST_BID).should == '-'
        cell_value(0, Column::SNIPER_STATE).should == STATUS_JOINING
      end

      it 'notifies listeners when adding a sniper' do
        joining_sniper_snapshot = SniperSnapshot.joining('item123')
        listener.should_receive(:table_changed)

        model.row_count.should == 0

        model.add_sniper(joining_sniper_snapshot)

        model.row_count.should == 1
        model.snapshots.fetch(0).should == joining_sniper_snapshot
      end

      it 'holds snipers in addition order' do
        model.add_sniper(SniperSnapshot.joining('item-0'))
        model.add_sniper(SniperSnapshot.joining('item-1'))

        cell_value(0, Column::ITEM_IDENTIFIER).should == 'item-0'
        cell_value(1, Column::ITEM_IDENTIFIER).should == 'item-1'
      end

      it 'updates the correct row for the sniper' do
        model.add_sniper(SniperSnapshot.joining('item-0'))

        sniper_snapshot = SniperSnapshot.joining('item-1')
        model.add_sniper(sniper_snapshot)

        model.sniper_state_changed(sniper_snapshot.bidding(50, 100))

        cell_value(0, Column::ITEM_IDENTIFIER).should == 'item-0'
        cell_value(0, Column::SNIPER_STATE).should == STATUS_JOINING

        cell_value(1, Column::ITEM_IDENTIFIER).should == 'item-1'
        cell_value(1, Column::SNIPER_STATE).should == STATUS_BIDDING
      end

      it 'errors when if there is no exsiting sniper for an update' do
        model.add_sniper(SniperSnapshot.joining('item-0'))
        sniper_snapshot = SniperSnapshot.joining('item-1')

        expect {
          model.sniper_state_changed(sniper_snapshot.bidding(50, 100))
        }.to raise_error IndexError, 'Snapshot not found in table model.'
      end

      def cell_value(row_index, column)
        column.value_in(model.snapshots.fetch(row_index))
      end
    end
  end
end
