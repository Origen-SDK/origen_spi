module OrigenSpi
  class Driver
    include Origen::Model

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
    #   :rl   # return low - data changes while sclk is low, latches on rising edge
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
    #   :msb0 - MSB is shifted first
    #   :lsb0
    #
    # @example
    #   spi_instance.data_order = :lsb0
    attr_reader :data_order

    # internal attribute
    attr_reader :settings_validated

    # options hash can configure
    #
    # @example
    #   options = {
    #     sclk_pin: dut.pin(:p1),
    #     mosi_pin: dut.pin(:p2),
    #     miso_pin: dut.pin(:p3),
    #     ss_pin: dut.pin(:p4),
    #     clk_format: :rl,
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
        clk_wait_time: { time_in_us: 0 },
        clk_multiple:  2,
        data_order:    :msb0
      }.merge(options)

      @sclk_pin = options[:sclk_pin]
      @mosi_pin = options[:mosi_pin]
      @miso_pin = options[:miso_pin]
      @ss_pin = options[:ss_pin]
      @clk_format = options[:clk_format]
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
        Origen.log.error 'Valid formats are :rl, :rh'
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

    # Check settings
    def validate_settings
      unless @settings_validated
        settings_valid = true

        # materialize pins
        @sclk_pin = dut.pins(@sclk_pin) if @sclk_pin.is_a?(Symbol)
        @mosi_pin = dut.pins(@mosi_pin) if @mosi_pin.is_a?(Symbol)
        @miso_pin = dut.pins(@miso_pin) if @miso_pin.is_a?(Symbol)
        @ss_pin = dut.pins(@ss_pin) if @ss_pin.is_a?(Symbol)

        # check that clock and miso are provided
        unless @sclk_pin.is_a?(Origen::Pins::Pin)
          settings_valid = false
          Origen.log.error 'OrigenSpi::Driver.sclk_pin must be an Origen pin object'
        end

        unless @clk_format == :rl || @clk_format == :rh
          settings_valid = false
          Origen.log.error 'OrigenSpi::Driver.clk_format must be one of :rl, :rh'
        end

        unless @ss_active == 0 || @ss_active == 1
          settings_valid = false
          Origen.log.error 'OrigenSpi::Driver.ss_active must be either 0 or 1'
        end

        @clk_multiple = 1 if @clk_multiple < 1
        @half_cycle = @clk_multiple / 2

        @miso_compare_cycle = @clk_multiple - 1 if @miso_compare_cycle > @clk_multiple - 1

        unless @data_order == :msb0 || @data_order == :lsb0
          settings_valid = false
          Origen.log.error 'OrigenSpi::Driver.data_order must be either :msb0 or :lsb0'
        end

        @settings_validated = settings_valid
      end
    end

    # Run a spi clock cycle
    #
    # This method can be used to clock the spi port without specifying shift data
    def sclk_cycle
      validate_settings
      cc 'OrigenSpi::Driver - Issue a clock cycle'
      @sclk_pin.restore_state do
        @sclk_pin.drive @clk_format == :rl ? 0 : 1
        @half_cycle.times { tester.cycle }
        @sclk_pin.drive @clk_format == :rl ? 1 : 0
        @half_cycle.upto(@clk_multiple - 1) { tester.cycle }
      end
    end

    # Shift a spi packet
    #
    # Overlay and capture is specified through reg.overlay and reg.store
    #
    # @example
    #   spi_instance.shift master_out: out_reg, master_in: in_cmp_reg
    # @example
    #   spi_instance.shift master_out: 0x7a, size: 32
    # @example
    #   spi_instance.shift master_in: in_cmp_reg
    def shift(options = {})
      options = {
        master_out:     0,
        keep_ss_active: false
      }.merge(options)

      validate_settings
      options = validate_options(options)
      out_reg = build_output_packet(options).bits
      in_reg = build_input_packet(options).bits

      # reverse bit order if :msb0
      if @data_order == :msb0
        out_reg = out_reg.reverse
        in_reg = in_reg.reverse
      end

      # set ss active
      @ss_pin.drive @ss_active unless @ss_pin.nil?

      # apply wait time if requested
      tester.wait @clk_wait_time unless @clk_wait_time == { time_in_us: 0 }

      # now do the shifting
      0.upto(out_reg.size - 1) do |bit|
        # note which bit this is
        if @data_order == :msb0
          thisbit = out_reg.size - 1 - bit
        else
          thisbit = bit
        end

        # park the clock
        @sclk_pin.drive @clk_format == :rl ? 0 : 1
        @miso_pin.dont_care unless @miso_pin.nil?

        # setup the bit to be driven, prep for overlay if requested
        overlay_options = {}
        unless @mosi_pin.nil?
          @mosi_pin.drive out_reg[bit].data
          if out_reg[bit].has_overlay?
            overlay_options[:pins] = @mosi_pin
            overlay_options[:overlay_str] = out_reg[bit].overlay_str
          end
        end

        # advance to clock active edge
        @half_cycle.times do |c|
          handle_miso c, in_reg[bit], thisbit
          cycle overlay_options
          overlay_options[:change_data] = false unless overlay_options == {}
        end

        # drive the clock to active
        @sclk_pin.drive @clk_format == :rl ? 1 : 0

        # advance to the end of the sclk cycle checking for appropriate miso compare placement
        @half_cycle.upto(@clk_multiple - 1) do |c|
          handle_miso c, in_reg[bit], thisbit
          cycle overlay_options
        end
      end

      # park the clock, mask miso, clear ss
      @sclk_pin.drive @clk_format == :rl ? 0 : 1
      @miso_pin.dont_care unless @miso_pin.nil?
      @mosi_pin.drive 0 unless @mosi_pin.nil?
      @ss_pin.drive @ss_active == 1 ? 0 : 1 unless @ss_pin.nil? || options[:keep_ss_active]

      # clear flags if registers were provided
      options[:master_out].clear_flags if options[:master_out].respond_to?(:clear_flags)
      options[:master_in].clear_flags if options[:master_in].respond_to?(:clear_flags)
    end

    # Internal method
    #
    # Set the state of miso
    def handle_miso(c, bit, bit_number)
      unless @miso_pin.nil?
        if c == @miso_compare_cycle
          @miso_pin.assert bit.data, meta: { position: bit_number } if bit.is_to_be_read?
          tester.store_next_cycle @miso_pin if bit.is_to_be_stored?
        else
          @miso_pin.dont_care
        end
      end
    end

    # Internal method
    #
    # Issue a tester cycle, conditionally with overlay options supplied
    def cycle(overlay_options = {})
      overlay_options == {} ? tester.cycle : (tester.cycle overlay: overlay_options)
    end

    # Build the shift out packet
    #
    # This is an internal method used by the shift method
    def build_output_packet(options)
      out_reg = Origen::Registers::Reg.dummy(options[:size])
      if options[:master_out].respond_to?(:data)
        out_reg.copy_all(options[:master_out])
      else
        out_reg.write options[:master_out]
      end
      out_reg
    end

    # Build the input packet
    #
    # This is an internal method used by the shift method
    def build_input_packet(options)
      in_reg = Origen::Registers::Reg.dummy(options[:size])
      if options[:master_in].respond_to?(:data)
        in_reg.copy_all(options[:master_in])
      else
        unless options[:master_in].nil?
          in_reg.write options[:master_in]
          in_reg.read
        end
      end
      in_reg
    end

    # Internal method that logs errors in options passed to the shift method
    def validate_options(options)
      # check that size of the packet can be determined
      unless options[:size]
        options[:size] = options[:master_in].size if options[:master_in].respond_to?(:data)
      end
      unless options[:size]
        options[:size] = options[:master_out].size if options[:master_out].respond_to?(:data)
      end
      unless options[:size]
        Origen.log.error "OrigenSpi::Driver can't determine the packet size"
        exit
      end
      options
    end
  end
end
