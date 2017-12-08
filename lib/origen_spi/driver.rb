module OrigenSpi
  class Driver
  
    # Dut pin that serves as the spi clock
    # @example
    #   spi_instance.sclk_pin = dut.pin(:p1)
    attr_accessor :sclk_pin
    
    # Dut pin that serves as the master out slave in pin
    # @example
    #   spi_instance.mosi_pin = dut.pin(:p2)
    attr_accessor :mosi_pin
    
    # Dut pin that serves as the master in slave out
    # @example
    #   spi_instance.miso_pin = dut.pin(:p3)
    attr_accessor :miso_pin
    
    # Dut pin that serves as the slave select
    # @example
    #   spi_instance.ss_pin = dut.pin(:p4)
    # @example
    #   spi_instance.ss_pin = nil   # no ss pin
    attr_accessor :ss_pin
    
    # clock format
    #
    # available options are:
    #   :nr   # non-return
    #   :rl   # return low
    #   :rh   # return high
    #
    # @example
    #   spi_instance.clk_format = :rl
    attr_accessor :clk_format
    
    # pin state corresponding to slave select active
    # @example
    #   spi_instance.ss_active = 0
    attr_accessor :ss_active
    
    # time between ss_active and the first spi clock
    #
    # 0 < clk_wait_time < 1 will result in a fixed time delay
    # clk_wait_time >= 1 will result in a fixed tester.cycle delay
    #
    # @example
    #   spi_instance.clk_wait_time = 0        # no delay
    #   spi_instance.clk_wait_time = 0.001    # 1ms delay
    #   spi_instance.clk_wait_time = 2        # 2 cycle delay
    attr_accessor :clk_wait_time
    
    # number of tester cycles per spi clock
    attr_accessor :clk_multiple
    
    # cycle on which miso compares are placed (0 is the first cycle)
    attr_accessor :miso_compare_cycle
    
    # data order
    #
    # available options are:
    #   :msb0
    #   :lsb0
    #
    # @example
    #   spi_instance.data_order = :lsb0
    attr_accessor :data_order

    # options hash can configure
    # 
    # @example
    #   options = {
    #     sclk_pin: dut.pin(:p1),
    #     mosi_pin: dut.pin(:p2),
    #     miso_pin: dut.pin(:p3),
    #     ss_pin: dut.pin(:p4),
    #     clk_format: :nr,
    #     ss_active: 0,
    #     clk_wait_time: 0,
    #     clk_multiple: 2,
    #     miso_compare_cycle: 1,
    #     data_order: :msb0
    #   }
    #   spi = OrigenSpi::Driver.new(options)
    def initialize(options = {})
      options = {
        sclk_pin: nil,
        mosi_pin: nil,
        miso_pin: nil,
        ss_pin: nil,
        clk_format: :nr,
        ss_active: 0,
        clk_wait_time: 0,
        clk_multiple: 2,
        data_order: :msb0
      }.merge(options)
      
      @sclk_pin = options[:sclk_pin]
      @mosi_pin = options[:mosi_pin]
      @miso_pin = options[:miso_pin]
      @ss_pin = options[:ss_pin]
      @clk_format = options[clk_format]
      @ss_active = options[:ss_active]
      @clk_wait_time = options[:clk_wait_time]
      @clk_multiple = options[:clk_multiple]
      @miso_compare_cycle = options[:miso_compare_cycle] ? options[:miso_compare_cycle] : @clk_multiple - 1
      @data_order = options[:data_order]
    end
  end
end