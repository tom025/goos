require 'java'
require 'lib/window_licker'
require 'lib/hamcrest'
require 'rspec'
require 'rspec/given'

module AWT
  java_import java.awt.Color
end

module JConcurrent
  java_import java.util.concurrent.ArrayBlockingQueue
  java_import java.util.concurrent.TimeUnit
end
