module OrigenSpi
  module TestDut
    class Dut1
      include Origen::TopLevel

      def initialize(options = {})
        add_pin :sclk
        add_pin :mosi
        add_pin :miso
        add_pin :ss

        sub_block :spi, class_name:   'OrigenSpi::Driver',
                        sclk_pin:     dut.pin(:sclk),
                        mosi_pin:     dut.pin(:mosi),
                        miso_pin:     dut.pin(:miso),
                        ss_pin:       dut.pin(:ss),
                        clk_format:   :rl,
                        ss_active:    0,
                        clk_multiple: 1,
                        data_order:   :lsb0
      end
    end
  end
end
