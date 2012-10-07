require 'java'
require 'org/smack/smack.jar'
require 'org/smack/smackx.jar'
require 'org/window_licker/windowlicker-swing-DEV.jar'
require 'org/window_licker/windowlicker-core-DEV.jar'
require 'org/hamcrest/hamcrest-all-SNAPSHOT.jar'
require 'rspec'
require 'rspec/given'


module Smack
  include_package 'org/jivesoftware/smack'
  java_import org.jivesoftware.smack.XMPPConnection
  java_import org.jivesoftware.smack.packet.Message
end

module WindowLicker
  include_package 'com/objogate/wl'
  include_package 'com/objogate/wl/swing'
  java_import com.objogate.wl.swing.driver.JFrameDriver
  java_import com.objogate.wl.swing.driver.JLabelDriver
  java_import com.objogate.wl.swing.gesture.GesturePerformer
  java_import com.objogate.wl.swing.AWTEventQueueProber
end

module Hamcrest
  java_import org.hamcrest.Matchers
end

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
