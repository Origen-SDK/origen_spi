Pattern.create do
  tester.set_timeset 'tp0', 20
  dut.pin(:ss).drive 1
  dut.pin(:sclk).drive 0
  dut.pin(:mosi).drive 0
  dut.pin(:miso).dont_care
  
  tester.cycle

  out_data = Origen::Registers::Reg.dummy(12).write 7
  in_data = Origen::Registers::Reg.dummy(12).read 0x5a5
  cc 'shifting 12-bits lsb first, 0x7 out, 0x5a5 in -- keeping ss active'
  dut.spi.shift master_out: out_data, master_in: in_data, keep_ss_active: true
  
  cc 'cycle with ss active'
  tester.cycle

  cc 'shifting 12-bits lsb first, 0x7 out, 0x5a5 in -- allow ss inactive'
  dut.spi.shift master_out: out_data, master_in: in_data
  
  cc 'cycle with ss inactive'
  tester.cycle

end