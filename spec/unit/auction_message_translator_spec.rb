require 'lib/auction_sniper/auction_message_translator'

class AuctionSniper
  describe AuctionMessageTranslator do
    let(:chat) { double(:chat) }
    let(:listener) { double(:event_listener) }
    let(:translator) { AuctionMessageTranslator.new(listener) }

    it 'notifies the when the auction closed' do
      message = double(:message, :body => "SOLVersion: 1.1; Event: CLOSE;")
      listener.should_receive(:auction_closed)
      translator.process_message(chat, message)
    end

    it 'notifies the bid details current price message received' do
      message_text = "SOLVersion: 1.1; Event: PRICE; CurrentPrice: 192; " +
        "Increment: 7; Bidder: Someone else;"
      message = double(:message, :body => message_text)
      listener.should_receive(:current_price).with(192, 7)
      translator.process_message(chat, message)
    end

  end
end
