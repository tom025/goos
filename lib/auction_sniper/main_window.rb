require 'lib/swing'
require 'lib/awt'
require 'lib/user_requests'
require 'lib/auction_sniper/snipers_table_model'

class AuctionSniper
  class MainWindow < Swing::JFrame
    SNIPER_TABLE_NAME = 'Sniper Table'
    SNIPER_STATUS_NAME = 'status'
    MAIN_WINDOW_NAME = 'Auction Sniper'
    NEW_ITEM_ID_NAME = 'item id'
    JOIN_BUTTON_NAME = 'join button'
    STATUS_JOINING = 'joining'
    STATUS_BIDDING = 'bidding'
    STATUS_WINNING = 'winning'
    STATUS_LOST = 'lost'
    STATUS_WON = 'won'

    def initialize(portfolio)
      super("Auction Sniper")
      @user_requests = UserRequests.new
      set_name(MAIN_WINDOW_NAME)
      fill_content_pane(make_snipers_table(portfolio), make_controls)
      pack
      set_default_close_operation(Swing::JFrame::EXIT_ON_CLOSE)
      set_visible(true)
    end

    def add_user_request_listener(listener)
      @user_requests << listener
    end

    private
    def fill_content_pane(snipers_table, controls)
      content_pane.layout = AWT::BorderLayout.new
      content_pane.add(controls, AWT::BorderLayout::NORTH)
      content_pane.add(Swing::JScrollPane.new(snipers_table), AWT::BorderLayout::CENTER)
    end

    def make_snipers_table(portfolio)
      model = SnipersTableModel.new
      portfolio.add_portfolio_listener(model)
      snipers_table = Swing::JTable.new(model)
      snipers_table.name = SNIPER_TABLE_NAME
      snipers_table
    end

    def make_controls
      controls = Swing::JPanel.new(AWT::FlowLayout.new)
      item_id_field = Swing::JTextField.new
      item_id_field.columns = 25
      item_id_field.name = NEW_ITEM_ID_NAME
      controls.add(item_id_field)

      join_auction_button = Swing::JButton.new('Join Auction')
      join_auction_button.name = JOIN_BUTTON_NAME
      join_auction_button.add_action_listener do 
        @user_requests.notify(:join_auction, item_id_field.text)
      end
      controls.add(join_auction_button)

      controls
    end

  end
end
