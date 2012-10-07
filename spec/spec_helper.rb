require 'java'
require 'lib/window_licker'
require 'lib/hamcrest'
require 'rspec'
require 'rspec/given'

module JConcurrent
  java_import java.util.concurrent.ArrayBlockingQueue
  java_import java.util.concurrent.TimeUnit
end
