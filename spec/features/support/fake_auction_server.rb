require 'lib/smack'

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = 'auction-%s'
  XMPP_HOSTNAME = 'localhost'
  AUCTION_PASSWORD = 'auction'
  AUCTION_RESOURCE = 'Auction'

  attr_accessor :current_chat, :message_listener, :item_id

  def initialize(item_id)
    @item_id = item_id
    @connection = Smack::XMPPConnection.new(XMPP_HOSTNAME)
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    @connection.connect
    @connection.login(ITEM_ID_AS_LOGIN % @item_id,
                     AUCTION_PASSWORD,
                     AUCTION_RESOURCE)
    @connection.get_chat_manager.add_chat_listener(ChatManagerListener.new(self))
  end

  def has_received_join_request_from_sniper
    message_listener.receives_a_message
  end

  def announce_closed
    current_chat.send_message(Smack::Message.new)
  end

  def stop
    @connection.disconnect
  end

  class ChatManagerListener
    def initialize(chat_observer)
      @chat_observer = chat_observer
    end

    def chat_created(chat, created_locally)
      @chat_observer.current_chat = chat
      chat.add_message_listener(@chat_observer.message_listener)
    end
  end

  class SingleMessageListener
    include RSpec::Matchers

    def initialize
      @messages = JConcurrent::ArrayBlockingQueue.new(1)
    end

    def process_message(chat, message)
      @messages.add(message)
    end

    def receives_a_message
      @messages.poll(5, JConcurrent::TimeUnit::SECONDS).should_not be_nil
    end

  end
end
