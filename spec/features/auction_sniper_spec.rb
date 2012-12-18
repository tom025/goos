require 'spec_helper'
require 'lib/auction_sniper'

describe AuctionSniper do
  after do
    auction.stop
    application.stop
  end

  Given(:auction) { FakeAuctionServer.new('item-54321') }
  Given(:application) { ApplicationRunner.new }

  context 'bidding for a single item' do
    Given { auction.start_selling_item }
    Given { application.start_bidding_in(auction) }
    Given { auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID) }

    context 'sniper joins auction until auction closes' do
      When { auction.announce_closed }
      Then { application.shows_sniper_has_lost(auction) }
    end

    context 'when another bidder is bidding' do
      Given { auction.report_price(1000, 98, 'other bidder') }
      Given { application.has_shown_sniper_is_bidding(auction, 1000, 1098) }
      Given { auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID) }

      context 'the sniper makes a higher bid but loses' do
        When { auction.announce_closed }
        Then { application.shows_sniper_has_lost(auction) }
      end

      context 'the sniper wins an auction by bidding higer' do
        Given { auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID) }
        Given { application.has_shown_sniper_is_winning(auction, 1098) }

        When { auction.announce_closed }
        Then { application.shows_sniper_has_won(auction, 1098) }
      end
    end
  end

  context 'sniper bids for multiple items' do
    Given(:auction2) { FakeAuctionServer.new('item-65432') }

    Given {
      auction.start_selling_item
      auction2.start_selling_item
    }

    Given {
      application.start_bidding_in(auction, auction2)
      auction.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
      auction2.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    }

    Given {
      auction.report_price(1000, 98, 'other bidder')
      auction.has_received_bid(1098, ApplicationRunner::SNIPER_XMPP_ID)
    }

    Given {
      auction2.report_price(500, 21, 'other bidder')
      auction2.has_received_bid(521, ApplicationRunner::SNIPER_XMPP_ID)
    }

    Given {
      auction.report_price(1098, 97, ApplicationRunner::SNIPER_XMPP_ID)
      auction2.report_price(521, 22, ApplicationRunner::SNIPER_XMPP_ID)
    }

    Given {
      application.has_shown_sniper_is_winning(auction, 1098)
      application.has_shown_sniper_is_winning(auction2, 521)
    }

    When {
      auction.announce_closed
      auction2.announce_closed
    }

    Then {
      application.shows_sniper_has_won(auction, 1098)
      application.shows_sniper_has_won(auction2, 521)
    }
  end
end
