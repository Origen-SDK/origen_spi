require 'spec_helper'
require_relative "#{Origen.root!}/lib/origen_spi/driver"

describe OrigenSpi::Driver do
  class TestDUT
    include Origen::TopLevel
    
    def initialize
      add_pin :sclk
      add_pin :mosi
      add_pin :miso
      add_pin :ss
    end
  end
  
  specify 'attributes can be initialized on create' do
    Origen.target.temporary = -> { TestDUT.new; OrigenTesters::J750.new }
    Origen.target.load!
    settings = {
      sclk_pin: dut.pin(:sclk),
      mosi_pin: dut.pin(:mosi),
      miso_pin: dut.pin(:miso),
      ss_pin: dut.pin(:ss),
      clk_format: :rl,
      ss_active: 0,
      clk_multiple: 1,
      data_order: :lsb0
    }
    
    spi_ins = OrigenSpi::Driver.new(settings)
    spi_ins.sclk_pin.name.to_s.should == 'sclk'
    spi_ins.mosi_pin.name.to_s.should == 'mosi'
    spi_ins.miso_pin.name.to_s.should == 'miso'
    spi_ins.ss_pin.name.to_s.should == 'ss'
    spi_ins.clk_format.should == :rl
    spi_ins.clk_multiple.should == 1
    spi_ins.data_order.should == :lsb0
    
    spi_ins.validate_settings
    spi_ins.settings_validated.should == true
  end
  
  specify 'attributes can be updated causing re-validate' do
    Origen.target.temporary = -> { TestDUT.new; OrigenTesters::J750.new }
    Origen.target.load!
    settings = {
      sclk_pin: dut.pin(:sclk),
      mosi_pin: dut.pin(:mosi),
      miso_pin: dut.pin(:miso),
      ss_pin: dut.pin(:ss),
      clk_format: :rl,
      ss_active: 0,
      clk_multiple: 1,
      data_order: :lsb0
    }
    
    spi_ins = OrigenSpi::Driver.new(settings)
    spi_ins.validate_settings
    spi_ins.settings_validated.should == true
    spi_ins.clk_multiple = 8
    spi_ins.clk_multiple.should == 8
    spi_ins.settings_validated.should == false
  end

end