class Column
  def initialize(&value_in)
    @value_in = value_in
  end

  def self.at(index)
    COLUMNS.fetch(index) { raise ArgumentError, "No column at #{column_index}" }
  end

  def self.length
    COLUMNS.length
  end

  def value_in(snapshot)
    @value_in.call(snapshot)
  end

  def ordinal
    COLUMNS.index(self)
  end

  COLUMNS = [ITEM_IDENTIFIER = new(&:item_id),
             LAST_PRICE = new(&:last_price),
             LAST_BID = new(&:last_bid),
             SNIPER_STATE = new do |snapshot|
               AuctionSniper::SnipersTableModel.text_for(snapshot.state)
             end]
end
