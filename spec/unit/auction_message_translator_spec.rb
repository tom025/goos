require 'lib/auction_sniper/auction_message_translator'

module AuctionSniper
  describe AuctionMessageTranslator do
    let(:chat) { double(:chat) }
    let(:listener) { double(:event_listener) }
    let(:translator) { AuctionMessageTranslator.new(listener) }

    it 'notifies the when the auction closed' do
      message = double(:message, :body => "SOLVersion 1.1; Event: CLOSE")
      listener.should_receive(:auction_closed)
      translator.process_message(chat, message)
    end

  end
end
