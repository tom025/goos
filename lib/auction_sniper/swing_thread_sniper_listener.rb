require 'lib/swing'
class AuctionSniper
  class SwingThreadSniperListener
    def initialize(snipers)
      @snipers = snipers
    end

    def sniper_state_changed(sniper_snapshot)
      Swing::SwingUtilities.invoke_later do
        @snipers.sniper_state_changed(sniper_snapshot)
      end
    end
  end
end

