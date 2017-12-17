Pattern.create do
  tester.set_timeset 'tp0', 20
  dut.pin(:ss).drive 1
  dut.pin(:sclk).drive 0
  dut.pin(:mosi).drive 0
  dut.pin(:miso).dont_care
  
  tester.cycle
  tester.overlay_style = :label
  out_data = Origen::Registers::Reg.dummy(12).write 7
  out_data.bits[3..0].overlay 'heres_the_label'
  dut.spi.shift master_out: out_data
  
  cc 'repeat test reversing bit order'
  dut.spi.data_order = :msb0
  out_data.bits[3..0].overlay 'heres_the_other_label'
  dut.spi.shift master_out: out_data
end