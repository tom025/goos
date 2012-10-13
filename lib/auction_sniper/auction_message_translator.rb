class AuctionSniper
  class AuctionMessageTranslator
    def initialize(listener)
      @listener = listener
    end

    def process_message(chat, message)
      event = unpack_event_from(message)
      type = event.fetch("Event")
      if type == "CLOSE"
        @listener.auction_closed
      elsif type == "PRICE"
        @listener.current_price(event.fetch("Current Price").to_i,
                                event.fetch("Increment").to_i)
      end
    end

    private
    def unpack_event_from(message)
      message.body.split(';').inject({}) do |event, element|
        pair = element.split(":")
        event[pair[0].strip] = pair[1].strip
        event
      end
    end
  end
end
