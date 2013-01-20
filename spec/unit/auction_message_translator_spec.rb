require 'lib/auction_message_translator'
require 'lib/auction_event_listeners'

describe AuctionMessageTranslator do
  let(:chat) { double(:chat) }
  let(:sniper_id) { 'sniper' }
  let(:auction_event_listeners) { AuctionEventListeners.new }
  let(:listener) { double(:event_listener) }
  let(:translator) { AuctionMessageTranslator.new(sniper_id, auction_event_listeners) }

  let(:price_event_text) { "SOLVersion: 1.1; Event: PRICE; CurrentPrice: 192; " +
                           "Increment: 7; Bidder: #{bidder};" }
  let(:price_event_message) { double(:message, :body => price_event_text) }

  before do
    auction_event_listeners << listener
  end

  it 'notifies the when the auction closed' do
    message = double(:message, :body => "SOLVersion: 1.1; Event: CLOSE;")
    listener.should_receive(:auction_closed)
    translator.process_message(chat, message)
  end

  context 'when current price message is from the auction sniper' do
    let(:bidder) { sniper_id }
    it 'notifies that the bid cam from the sniper' do
      listener.should_receive(:current_price).with(192, 7, :from_sniper)
      translator.process_message(chat, price_event_message)
    end
  end

  context 'when current price message is from an other bidder' do
    let(:bidder) { 'Someone else' }
    it 'notifies that the bid came from another bidder' do
      listener.should_receive(:current_price).with(192, 7, :from_other_bidder)
      translator.process_message(chat, price_event_message)
    end
  end

end
