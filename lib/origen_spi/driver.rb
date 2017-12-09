module OrigenSpi
  class Driver
    # Dut pin that serves as the spi clock
    # @example
    #   spi_instance.sclk_pin = dut.pin(:p1)
    attr_reader :sclk_pin

    # Dut pin that serves as the master out slave in pin
    # @example
    #   spi_instance.mosi_pin = dut.pin(:p2)
    attr_reader :mosi_pin

    # Dut pin that serves as the master in slave out
    # @example
    #   spi_instance.miso_pin = dut.pin(:p3)
    attr_reader :miso_pin

    # Dut pin that serves as the slave select
    # @example
    #   spi_instance.ss_pin = dut.pin(:p4)
    # @example
    #   spi_instance.ss_pin = nil   # no ss pin
    attr_reader :ss_pin

    # clock format
    #
    # available options are:
    #   :nr   # non-return
    #   :rl   # return low
    #   :rh   # return high
    #
    # @example
    #   spi_instance.clk_format = :rl
    attr_reader :clk_format

    # pin state corresponding to slave select active
    # @example
    #   spi_instance.ss_active = 0
    attr_reader :ss_active

    # time between ss_active and the first spi clock
    #
    # hash containing the wait time
    #
    # @example
    #   spi_instance.clk_wait_time = {time_in_us: 0}        # no delay
    #   spi_instance.clk_wait_time = {time_in_ms: 1}        # 1ms delay
    #   spi_instance.clk_wait_time = {time_in_cycles: 2}    # 2 cycle delay
    attr_reader :clk_wait_time

    # number of tester cycles per spi clock
    attr_reader :clk_multiple

    # cycle on which miso compares are placed (0 is the first cycle)
    attr_reader :miso_compare_cycle

    # data order
    #
    # available options are:
    #   :msb0
    #   :lsb0
    #
    # @example
    #   spi_instance.data_order = :lsb0
    attr_reader :data_order

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
    #     clk_wait_time: {time_in_cycles: 2},
    #     clk_multiple: 2,
    #     miso_compare_cycle: 1,
    #     data_order: :msb0
    #   }
    #   spi = OrigenSpi::Driver.new(options)
    def initialize(options = {})
      options = {
        sclk_pin:      nil,
        mosi_pin:      nil,
        miso_pin:      nil,
        ss_pin:        nil,
        clk_format:    :nr,
        ss_active:     0,
        clk_wait_time: { time_in_s: 0 },
        clk_multiple:  2,
        data_order:    :msb0
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
      @settings_validated = false
    end

    def sclk_pin=(pin)
      @sclk_pin = pin
      @settings_validated = false
    end

    def mosi_pin=(pin)
      @mosi_pin = pin
      @settings_validated = false
    end

    def miso_pin=(pin)
      @miso_pin = pin
      @settings_validated = false
    end

    def ss_pin=(pin)
      @ss_pin = pin
      @settings_validated = false
    end

    def clk_format=(format)
      if format == :nr || format == :rl || format == :rh
        @clk_format = format
      else
        Origen.log.error "Invalid clock format for OrigenSpi::Driver -> #{format}"
        Origen.log.error 'Valid formats are :nr, :rl, :rh'
      end
      @settings_validated = false
    end

    def ss_active=(state)
      if state == 0 || state == 1
        @ss_active = state
      else
        Origen.log.error 'Invalid OrigenSpi::Driver.ss_active state (valid states are 0 and 1)'
      end
      @settings_validated = false
    end

    def clk_wait_time=(clk_wait)
      @clk_wait_time = clk_wait
      @settings_validated = false
    end

    def clk_multiple=(mult)
      @clk_multiple = mult
      @settings_validated = false
    end

    def miso_compare_cycle=(cycle)
      @miso_compare_cycle = cycle
      @settings_validated = false
    end

    def data_order=(order)
      if order == :msb0 || order == :lsb0
        @data_order = order
      else
        Origen.log.error "Invalid OrigenSpi::Driver.data_order -> #{order}, (use :msb0 or :lsb0)"
      end
    end
  end
end
