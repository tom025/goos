$LOAD_PATH << File.join(File.dirname(__FILE__), 'features', 'support')
require 'lib/window_licker'
require 'lib/hamcrest'
require 'lib/jconcurrent'
require 'fake_auction_server'
require 'rspec'
require 'rspec/given'
