require 'spec_helper'
require_relative '..\lib\origen_spi\driver'

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
  end

end