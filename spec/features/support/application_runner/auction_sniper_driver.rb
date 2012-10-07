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

    def shows_sniper_status(text)
      WindowLicker::JLabelDriver.new(
        self, named(AuctionSniper::MainWindow::SNIPER_STATUS_NAME)).
          has_text(equal_to(text))
    end

    def named(*args)
      self.class.named(*args)
    end

    def method_missing(method_name, *args, &block)
      begin
        Hamcrest::Matchers.send(method_name, *args)
      rescue NoMethodError
        super
      end
    end
  end
end
