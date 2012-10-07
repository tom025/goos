require 'java'
require 'org/hamcrest/hamcrest-all-SNAPSHOT.jar'
require 'org/window_licker/windowlicker-swing-DEV.jar'
require 'org/window_licker/windowlicker-core-DEV.jar'

module WindowLicker
  include_package 'com/objogate/wl'
  include_package 'com/objogate/wl/swing'
  java_import com.objogate.wl.swing.driver.JFrameDriver
  java_import com.objogate.wl.swing.driver.JLabelDriver
  java_import com.objogate.wl.swing.gesture.GesturePerformer
  java_import com.objogate.wl.swing.AWTEventQueueProber
end


