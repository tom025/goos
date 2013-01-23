require 'lib/portfolio_listeners'

class SniperPortfolio
  def initialize
    @portfolio_listeners = PortfolioListeners.new
    @snipers = []
  end

  def add_sniper(sniper)
    @snipers << sniper
    @portfolio_listeners.notify(:sniper_added, sniper)
  end

  def add_portfolio_listener(listener)
    @portfolio_listeners << listener
  end
end
