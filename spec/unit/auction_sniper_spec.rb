require 'lib/auction_sniper'

describe AuctionSniper do
  let(:item_id) { 'item-54321' }
  let(:sniper_listener) { double(:sniper_listener, :sniper_state_changed => nil,
                                                   :sniper_lost => nil) }
  let(:sniper) { AuctionSniper.new(item_id, auction, sniper_listener) }
  let(:auction) { double(:auction).as_null_object }

  it 'reports loss when auction closes imediately' do
    lost_snapshot = SniperSnapshot.new(item_id, '-', '-', SniperState::LOST)
    sniper_listener.should_receive(:sniper_state_changed).with(lost_snapshot)
    sniper.auction_closed
  end

  it 'bids higer and reports bidding when current price is from an other bidder' do
    price = 1001
    increment = 25
    bid = price + increment
    sniper_snapshot = SniperSnapshot.new(item_id, price, bid, SniperState::BIDDING)

    auction.should_receive(:bid).with(price + increment)
    sniper_listener.should_receive(:sniper_state_changed).with(sniper_snapshot).at_least(1)
    sniper.current_price(price, increment, :from_other_bidder)
  end

  it 'reports loss if auction closes when bidding' do
    bidding_snapshot = SniperSnapshot.new(item_id, 123, 168, SniperState::BIDDING)
    sniper_listener.stub(:sniper_state_changed).with(bidding_snapshot)

    lost_snapshot = SniperSnapshot.new(item_id, 123, 168, SniperState::LOST)
    sniper_listener.should_receive(:sniper_state_changed).with(lost_snapshot)
    sniper.current_price(123, 45, :from_other_bidder)
    sniper.auction_closed
  end

  it 'reports win if auction closes when winning' do
    winning_snapshot = SniperSnapshot.new(item_id, 135, 135, SniperState::WINNING)
    won_snapshot = SniperSnapshot.new(item_id, 135, 135, SniperState::WON)
    bidding_snapshot = SniperSnapshot.new(item_id, 123, 135, SniperState::BIDDING)

    sniper_listener.should_receive(:sniper_state_changed).with(bidding_snapshot)

    sniper_listener.should_receive(:sniper_state_changed).with(winning_snapshot)
    sniper.current_price(123, 12, :from_other_bidder)
    sniper.current_price(135, 45, :from_sniper)

    sniper_listener.should_receive(:sniper_state_changed).with(won_snapshot)
    sniper.auction_closed
  end
end
