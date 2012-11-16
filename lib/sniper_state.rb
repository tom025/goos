class SniperState
  attr_reader :value
  def initialize(value, &when_auction_closed)
    @when_auction_closed = when_auction_closed
    @value = value
  end

  def ordinal
    STATES.map(&:value).index(value)
  end

  def when_auction_closed
    @when_auction_closed.call
  end

  STATES = [
    JOINING = new(:joining) { LOST },
    BIDDING = new(:bidding) { LOST },
    WINNING = new(:winning) { WON },
    LOST    = new(:lost) { raise RuntimeError, 'Acution is already closed' },
    WON     = new(:won) { raise RuntimeError, 'Auction is already closed' }
  ]
end
