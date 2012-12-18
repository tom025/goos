require 'lib/window_licker'
require 'lib/hamcrest'

class ApplicationRunner
  class AuctionSniperDriver < WindowLicker::JFrameDriver

    def self.with_timeout(timeout)
      top_level_driver = WindowLicker::JFrameDriver.top_level_frame(
        named(AuctionSniper::MainWindow::MAIN_WINDOW_NAME), showing_on_screen)
      gesture_performer = WindowLicker::GesturePerformer.new
      event_queue_probe = WindowLicker::AWTEventQueueProber.new(timeout, 100)
      new(gesture_performer, top_level_driver, event_queue_probe)
    end

    def has_column_titles
      headers = WindowLicker::JTableHeaderDriver.new(self, Swing::JTableHeader.java_class)
      headers.has_headers(matching(with_label_text("Item"),
                                   with_label_text("Last Price"),
                                   with_label_text("Last Bid"),
                                   with_label_text("State")))
    end

    def shows_sniper_status(item_id, text)
      snipers_table.has_cell(with_label_text(equal_to(text)))
    end

    def shows_sniper_state(item_id, last_price, last_bid, status_text)
      snipers_table.has_row(matching(with_label_text(item_id),
                                     with_label_text(last_price.to_s),
                                     with_label_text(last_bid.to_s),
                                     with_label_text(status_text)))
    end

    def named(*args)
      self.class.named(*args)
    end

    def with_label_text(*args)
      WindowLicker::JLabelTextMatcher.with_label_text(*args)
    end

    def matching(*args)
      WindowLicker::IterableComponentsMatcher.matching(*args)
    end

    def method_missing(method_name, *args, &block)
      begin
        Hamcrest::Matchers.send(method_name, *args)
      rescue NoMethodError
        super
      end
    end

    private
    def snipers_table
      @snipers_table ||= WindowLicker::JTableDriver.new(
        self, named(AuctionSniper::MainWindow::SNIPER_TABLE_NAME))
    end
  end
end
