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
  cc 'shifting in same register, should be no compares'
  dut.spi.shift master_in: in_data
end