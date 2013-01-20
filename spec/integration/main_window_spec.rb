require 'spec_helper'
require 'lib/auction_sniper/snipers_table_model'
require 'lib/auction_sniper/main_window'
require 'lib/user_request'

class AuctionSniper
  describe MainWindow do
    let(:table_model) { SnipersTableModel.new }
    let(:main_window) { MainWindow.new(table_model) }
    let(:driver) { ApplicationRunner::AuctionSniperDriver.with_timeout(100) }

    it 'sends join requests to the application' do
      button_probe = WindowLicker::ValueMatcherProbe.new(equal_to('item-1'), 'join request')
      request_listener = UserRequest.new do |item_id|
        button_probe.received_value = item_id
      end

      main_window.add_user_request_listener(request_listener)

      driver.start_bidding_for('item-1')
      driver.check(button_probe)
      driver.dispose
    end

    def method_missing(method_name, *args, &block)
      begin
        Hamcrest::Matchers.send(method_name, *args)
      rescue NoMethodError
        super
      end
    end
  end
end
