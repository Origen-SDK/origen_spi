Pattern.create do
  tester.set_timeset 'tp0', 20
  dut.pin(:ss).drive 1
  dut.pin(:sclk).drive 0
  dut.pin(:mosi).drive 0
  dut.pin(:miso).dont_care
  
  tester.cycle
  dut.spi.clock_cycle
  tester.cycle
  
  cc 'change multiple to 2'
  dut.spi.clk_multiple = 2
  dut.spi.clock_cycle
  tester.cycle
  
  cc 'change multiple to 80'
  dut.spi.clk_multiple = 80
  dut.spi.clock_cycle
  tester.cycle
  
  cc 'change clock format and repeat'
  dut.pin(:sclk).drive 1
  dut.spi.clk_format = :rh
  dut.spi.clk_multiple = 1
  dut.spi.clock_cycle
  tester.cycle

  cc 'change multiple to 2'
  dut.spi.clk_multiple = 2
  dut.spi.clock_cycle
  tester.cycle
  
  cc 'change multiple to 80'
  dut.spi.clk_multiple = 80
  dut.spi.clock_cycle
  tester.cycle
  
end