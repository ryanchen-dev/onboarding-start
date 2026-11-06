// spi_peripheral.v
// Ryan Chen

`default_nettype none

module spi_peripheral (
    input  wire       clk,             // System Clock - 10 MHz
    input  wire       rst_n,           // Reset: active low
    input  wire       sclk,            // SPI clock - controller
    input  wire       copi,            // SPI data - controller
    input  wire       ncs,             // SPI chip select: active low
    output reg  [7:0] en_reg_out_7_0,  // 0x00
    output reg  [7:0] en_reg_out_15_8, // 0x01
    output reg  [7:0] en_reg_pwm_7_0,  // 0x02
    output reg  [7:0] en_reg_pwm_15_8, // 0x03
    output reg  [7:0] pwm_duty_cycle   // 0x04
);

  // Synchronizers - preventing metastability
  // bit 0: first flip-flop (might be metastable, don't read)
  // bit 1: second flip-flop (synchronized and accurate value)
  // bit 2: bit 1 from one clock earlier (used to find edges)
  reg [2:0] sclk_sync;
  reg [2:0] ncs_sync;
  reg [1:0] copi_sync; // Since no edges needed on COPI, only 2 flip-flops

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // When reset is required
      sclk_sync <= 3'b000; // Set all three SCLK boxes to 0
      ncs_sync  <= 3'b111; // Set all 3 nCS boxes to 1
      copi_sync <= 2'b00;  // Set both COPI boxes to 0
    end else begin
      sclk_sync <= {sclk_sync[1:0], sclk};
      ncs_sync  <= {ncs_sync[1:0], ncs};
      copi_sync <= {copi_sync[0], copi};
    end
  end
endmodule