class XMPPAuction
  JOIN_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Join;'
  BID_COMMAND_FORMAT = 'SOLVersion: 1.1; Command: Bid; Amount: %d'

  attr_reader :item_id
  def initialize(chat)
    @chat = chat
  end

  def bid(amount)
    send_message(BID_COMMAND_FORMAT % amount)
  end

  def join
    send_message(JOIN_COMMAND_FORMAT)
  end

  private
  def send_message(message)
    @chat.send_message(message)
  rescue XMPPException => e
    puts e.message
  end
end
