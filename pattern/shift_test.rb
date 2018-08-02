Pattern.create do
  tester.set_timeset 'tp0', 20
  dut.pin(:ss).drive 1
  dut.pin(:sclk).drive 0
  dut.pin(:mosi).drive 0
  dut.pin(:miso).dont_care
  
  tester.cycle

  out_data = Origen::Registers::Reg.dummy(12).write 7
  in_data = Origen::Registers::Reg.dummy(12).read 0x5a5
  cc 'shifting 12-bits lsb first, 0x7 out, 0x5a5 in'
  dut.spi.shift master_out: out_data, master_in: in_data
  
  tester.cycle
  
  cc 'repeat 12-bits lsb first, 0x7 out, 0x5a5 in; clock multiple = 4'
  out_data.write 7
  in_data.read 0x5a5
  dut.spi.clk_multiple = 4
  dut.spi.shift master_out: out_data, master_in: in_data
  
  tester.cycle
  
  cc 'repeat 12-bits, 0x7 out, 0x5a5 in; clock multiple = 4, with msb first, move miso compare to cycle 3'
  out_data.write 7
  in_data.read 0x5a5
  dut.spi.data_order = :msb0
  dut.spi.miso_compare_cycle = 3
  dut.spi.shift master_out: out_data, master_in: in_data

  tester.cycle
  
  cc 'Now check bit masking'
  cc 'shift 0xa5a, 12-bits, msb first, multiple = 1, clk format :rh, all bits masked'
  dut.spi.clk_format = :rh
  dut.spi.clk_multiple = 1
  dut.spi.shift master_out: 0xa5a, size: 12
  
  tester.cycle
  
  cc 'repeat same, comparing for LLLL_XXXX_HHHH, clock back to :rl'
  dut.spi.clk_format = :rl
  in_data.write 0xf
  in_data.bits[11..8].read
  in_data.bits[7..4].clear_flags
  in_data.bits[3..0].read
  dut.spi.shift master_out: 0xa5a, master_in: in_data
  
  tester.cycle
  
  cc 'test capture'
  in_data.bits[11..8].read
  in_data.bits[7..4].store
  in_data.bits[3..0].read
  dut.spi.shift master_out: 0xa5a, master_in: in_data
  
  tester.cycle
  
  # cc 'test overlay, label should appear at bit 3'
  # out_data.write 0xa5a
  # out_data.bits[3..0].overlay 'heres_the_label'
  # tester.overlay_style = :label
  # dut.spi.shift master_out: out_data
  
  # tester.cycle
end