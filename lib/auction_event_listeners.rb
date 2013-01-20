class AuctionEventListeners
  def initialize
    @listeners = []
  end

  def <<(listener)
    @listeners << listener
  end

  def notify(event, *args)
    @listeners.each do |listener|
      listener.public_send(event, *args)
    end
  end
end
