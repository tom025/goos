require 'lib/jconcurrent'

class FakeAuctionServer
  class SingleMessageListener
    include RSpec::Matchers

    def initialize
      @messages = JConcurrent::ArrayBlockingQueue.new(1)
    end

    def process_message(chat, message)
      @messages.add(message)
    end

    def receives_a_message(message_matcher)
      message = @messages.poll(5, JConcurrent::TimeUnit::SECONDS)
      message.should_not be_nil
      message.body.should message_matcher
    end
  end
end
