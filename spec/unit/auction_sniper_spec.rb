require 'lib/auction_sniper'

describe AuctionSniper do
  let(:sniper_listener) { double(:sniper_listener) }
  let(:sniper) { AuctionSniper.new(auction, sniper_listener) }
  let(:auction) { double(:auction) }

  it 'reports loss when auction closes' do
    sniper_listener.should_receive(:sniper_lost)
    sniper.auction_closed
  end

  it 'bids higer and reports bidding when new price arrives' do
    price = 1001
    increment = 25
    auction.should_receive(:bid).with(price + increment)
    sniper_listener.should_receive(:sniper_bidding).at_least(1)
    sniper.current_price(price, increment)
  end
end
