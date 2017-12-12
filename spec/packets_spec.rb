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
  
  specify 'output packet builder works' do
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
    out_reg = spi_ins.build_output_packet(master_out: 1, size: 7)
    out_reg.class.should == Origen::Registers::Reg
    out_reg.size.should == 7
    out_reg.data.should == 1
    
    dut_reg = Origen::Registers::Reg.dummy(16)
    dut_reg.write 0x32
    out_reg = spi_ins.build_output_packet(master_out: dut_reg, size: 16)
    out_reg.class.should == Origen::Registers::Reg
    out_reg.size.should == dut_reg.size
    out_reg.data.should == dut_reg.data
    
    out_reg.data = 0
    out_reg.data.should_not == dut_reg.data
    
    dut_reg.bits[1..2].overlay 'testing'
    out_reg = spi_ins.build_output_packet(master_out: dut_reg, size: 16)
    out_reg.bits[1].has_overlay?.should == true
    out_reg.bits[2].has_overlay?.should == true
    out_reg.bits[1].overlay_str.should == 'testing'
  end
  
  specify 'input packet builder works' do
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
    in_reg = spi_ins.build_input_packet(master_in: 3, size: 6)
    in_reg.class.should == Origen::Registers::Reg
    in_reg.size.should == 6
    in_reg.data.should == 3
    in_reg.bits[0].is_to_be_read?.should == true
    
    dut_reg = Origen::Registers::Reg.dummy(16)
    dut_reg.read 0x32
    in_reg = spi_ins.build_input_packet(master_in: dut_reg, size: 16)
    in_reg.data.should == 0x32
    in_reg.size.should == 16
    in_reg.bits[0].is_to_be_read?.should == true
    
    dut_reg.bits[9].store
    in_reg = spi_ins.build_input_packet(master_in: dut_reg, size: 16)
    in_reg.bits[9].is_to_be_stored?.should == true
  end

end