require 'java'
require 'org/smack/smack.jar'
require 'org/smack/smackx.jar'

module Smack
  include_package 'org/jivesoftware/smack'
  java_import org.jivesoftware.smack.XMPPConnection
  java_import org.jivesoftware.smack.packet.Message
end

