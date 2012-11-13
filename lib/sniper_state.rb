class SniperState
  attr_reader :value
  def initialize(value)
    @value = value
  end

  def ordinal
    STATES.map(&:value).index(value)
  end

  STATES = [
    JOINING = new(:joining),
    BIDDING = new(:bidding),
    WINNING = new(:winning),
    LOST    = new(:lost),
    WON     = new(:won)
  ]
end
