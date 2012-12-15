class Column
  attr_reader :name
  def initialize(name, &value_in)
    @name = name
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

  COLUMNS = [ITEM_IDENTIFIER = new('Item', &:item_id),
             LAST_PRICE = new('Last Price', &:last_price),
             LAST_BID = new('Last Bid', &:last_bid),
             SNIPER_STATE = new('State') do |snapshot|
               AuctionSniper::SnipersTableModel.text_for(snapshot.state)
             end]
end
