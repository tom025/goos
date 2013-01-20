class UserRequest
  def initialize(&block)
    @when_joining = block
  end

  def join_auction(item_id)
    @when_joining.call(item_id)
  end
end
