class SniperSnapshot < Struct.new(:item_id, :last_price, :last_bid, :state)
  def self.joining(item_id)
    new(item_id, '-', '-', SniperState::JOINING)
  end

  def bidding(new_last_price, new_last_bid)
    new(item_id, new_last_price, new_last_bid, SniperState::BIDDING)
  end

  def winning(new_last_price)
    new(item_id, new_last_price, new_last_price, SniperState::WINNING)
  end

  def closed
    new(item_id, last_price, last_bid, state.when_auction_closed)
  end

  private
  def new(*args)
    self.class.new(*args)
  end
end
