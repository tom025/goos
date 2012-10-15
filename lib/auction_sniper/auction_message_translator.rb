require 'active_support/all'

class AuctionSniper
  class AuctionMessageTranslator
    def initialize(sniper_id, listener)
      @sniper_id = sniper_id
      @listener = listener
    end

    def process_message(chat, message)
      event = AuctionEvent.from(message.body)
      event_type = event.type
      if event_type == "CLOSE"
        @listener.auction_closed
      elsif event_type == "PRICE"
        @listener.current_price(event.current_price,
                                event.increment,
                                event.is_from(@sniper_id))
      end
    end

    class AuctionEvent
      INTEGER_ATTRIBUTES = [
        :current_price,
        :increment
      ]

      def self.from(message_body)
        new(unpack_event_from(message_body))
      end

      def self.unpack_event_from(message)
        message.split(';').inject({}) do |event, element|
          pair = element.split(":")
          event[pair[0].strip] = pair[1].strip
          event
        end
      end

      def initialize(unpacked_message)
        @unpacked_message = unpacked_message
      end

      def type
        @unpacked_message.fetch("Event")
      end

      def is_from(sniper_id)
        sniper_id == bidder ? :from_sniper : :from_other_bidder
      end

      def method_missing(attribute, *args, &block)
        value = @unpacked_message.fetch(attribute.to_s.classify)
        return value.to_i if INTEGER_ATTRIBUTES.include?(attribute)
        value
      rescue IndexError
        super
      end
    end
  end
end
