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

  context 'when another bidder is bidding' do
    Given { auction.report_price(1000, 98, 'other bidder') }
    Given { application.has_shown_sniper_is_bidding }
    Given { auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID) }

    context 'the sniper makes a higher bid but loses' do
      When { auction.announce_closed }
      Then { application.shows_sniper_has_lost_auction }
    end

    context 'the sniper wins an auction by bidding higer' do
      Given { auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID) }
      Given { application.has_shown_sniper_is_winning }

      When { auction.announce_closed }
      Then { application.shows_sniper_has_won_auction }
    end
  end
end
