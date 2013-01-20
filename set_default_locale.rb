require 'java'
default_locale = Java::JavaUtil::Locale.new('en', 'GB', 'Colemak')
Java::JavaUtil::Locale.setDefault(default_locale)
