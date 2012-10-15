require 'lib/auction_sniper'

describe AuctionSniper do
  let(:sniper_listener) { double(:sniper_listener, :sniper_winning => nil,
                                                   :sniper_bidding => nil,
                                                   :sniper_lost => nil) }
  let(:sniper) { AuctionSniper.new(auction, sniper_listener) }
  let(:auction) { double(:auction).as_null_object }

  it 'reports loss when auction closes imediately' do
    sniper_listener.should_receive(:sniper_lost)
    sniper.auction_closed
  end

  it 'bids higer and reports bidding when current price is from an other bidder' do
    price = 1001
    increment = 25
    auction.should_receive(:bid).with(price + increment)
    sniper_listener.should_receive(:sniper_bidding).at_least(1)
    sniper.current_price(price, increment, :from_other_bidder)
  end

  it 'reports loss if auction closes when bidding' do
    sniper_listener.should_receive(:sniper_lost)
    sniper.current_price(123, 45, :from_other_bidder)
    sniper.auction_closed
  end

  it 'reports win if auction closes when winning' do
    sniper_listener.should_receive(:sniper_winning)
    sniper.current_price(123, 45, :from_sniper)

    sniper_listener.should_receive(:sniper_won)
    sniper.auction_closed
  end
end
