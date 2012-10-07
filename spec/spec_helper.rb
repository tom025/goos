require 'java'
require 'lib/window_licker'
require 'lib/hamcrest'
require 'rspec'
require 'rspec/given'

module Swing
  java_import javax.swing.SwingUtilities
  java_import javax.swing.JFrame
  java_import javax.swing.JLabel
  java_import javax.swing.border.LineBorder
end

module AWT
  java_import java.awt.Color
end

module JConcurrent
  java_import java.util.concurrent.ArrayBlockingQueue
  java_import java.util.concurrent.TimeUnit
end
