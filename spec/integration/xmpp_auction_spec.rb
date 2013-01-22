require 'spec_helper'
require 'lib/auction_sniper/xmpp_auction_house'
require 'lib/jconcurrent'
require 'lib/auction_sniper'

describe XMPPAuctionHouse do
  let(:auction_house) { XMPPAuctionHouse.connect('localhost', 'sniper', 'sniper') }
  let(:server) { FakeAuctionServer.new('item-54321') }
  let(:auction) { auction_house.auction_for(server.item_id) }

  before do
    server.start_selling_item
  end

  after do
    server.stop
  end

  it 'receives events from auction server after joining' do
    auction_was_closed = JConcurrent::CountDownLatch.new(1)

    auction.add_auction_event_listener(auction_closed_listener(auction_was_closed))
    auction.join

    server.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    server.announce_closed

    auction_was_closed.await(2, JConcurrent::TimeUnit::SECONDS).should be_true
  end

  def auction_closed_listener(auction_was_closed)
    AuctionListener.new(auction_was_closed)
  end

  class AuctionListener
    def initialize(counter)
      @counter = counter
    end

    def auction_closed
      @counter.count_down
    end
  end
end
