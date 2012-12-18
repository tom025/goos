require 'application_runner/auction_sniper_driver'

class ApplicationRunner
  XMPP_HOSTNAME = 'localhost'
  SNIPER_ID = 'sniper'
  SNIPER_PASSWORD = 'sniper'
  SNIPER_XMPP_ID = 'sniper@localhost/Auction'

  def start_bidding_in(*auctions)
    item_ids = auctions.map(&:item_id)
    Thread.new("Test Application") do
      begin
        AuctionSniper.start(XMPP_HOSTNAME, SNIPER_ID, SNIPER_PASSWORD, *item_ids)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
    @driver = AuctionSniperDriver.with_timeout(1000)
    @driver.has_title(AuctionSniper::MainWindow::MAIN_WINDOW_NAME)
    @driver.has_column_titles
    auctions.each do |auction|
      @driver.shows_sniper_status(auction.item_id, AuctionSniper::MainWindow::STATUS_JOINING)
    end
  end

  def shows_sniper_has_lost(auction)
    @driver.shows_sniper_status(auction.item_id, AuctionSniper::MainWindow::STATUS_LOST)
  end

  def shows_sniper_has_won(auction, last_price)
    @driver.shows_sniper_state(auction.item_id,
                               last_price,
                               last_price,
                               AuctionSniper::MainWindow::STATUS_WON)
  end

  def has_shown_sniper_is_bidding(auction, last_price, last_bid)
    @driver.shows_sniper_state(auction.item_id,
                               last_price,
                               last_bid,
                               AuctionSniper::MainWindow::STATUS_BIDDING)
  end

  def has_shown_sniper_is_winning(auction, winning_bid)
    @driver.shows_sniper_state(auction.item_id,
                               winning_bid,
                               winning_bid,
                               AuctionSniper::MainWindow::STATUS_WINNING)
  end

  def stop
    @driver.dispose if @driver
  end

end

