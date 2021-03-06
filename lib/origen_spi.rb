require 'origen'
require 'origen_testers'
require_relative '../config/application.rb'
module OrigenSpi
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

  # Example of how to explicitly require a file
  # require "origen_spi/my_file"

  # Load all files in the lib/origen_spi directory.
  # Note that there is no problem from requiring a file twice (Ruby will ignore
  # the second require), so if you have a file that must be required first, then
  # explicitly require it up above and then let this take care of the rest.
  Dir.glob("#{File.dirname(__FILE__)}/origen_spi/**/*.rb").sort.each do |file|
    require file
  end
end
