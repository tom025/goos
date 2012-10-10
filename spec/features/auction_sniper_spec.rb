require 'spec_helper'
require 'lib/auction_sniper'

describe AuctionSniper do
  after do
    auction.stop
    application.stop
  end

  Given(:auction) { FakeAuctionServer.new('item-54321') }
  Given(:application) { ApplicationRunner.new }

  Given { auction.start_selling_item }
  Given { application.start_bidding_in(auction) }
  Given { auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID) }

  context 'sniper joins auction until auction closes' do
    When { auction.announce_closed }
    Then { application.shows_sniper_has_lost_auction }
  end

  context 'sniper makes a higher bid but loses' do
    Given { auction.report_price(1000, 90, 'other bidder') }
    Given { application.has_shown_sniper_is_bidding }
    Given { auction.has_recived_bid(1098, ApplicationRunner::SNIPER_XMPP_ID) }

    When { auction.announce_closed }
    Then { application.shows_sniper_has_lost_auction }
  end
end
