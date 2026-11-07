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

  // Synchronizers to preventing metastability
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

  // Edge detection: compare the clean value now (bit 1)
  // with the clean value one clock ago (bit 2).
  // Each pulse is 1 for exactly one clk cycle.
  wire sclk_rising = (sclk_sync[2:1] == 2'b01);  // 0-->1: Grab a bit
  wire ncs_falling = (ncs_sync[2:1]  == 2'b10);  // 1-->0: Message starts
  wire ncs_rising  = (ncs_sync[2:1]  == 2'b01);  // 0-->1: Message ends
  wire ncs_active  = ~ncs_sync[1]; // 1 while message in progress

  // Receiving bits
  reg [15:0] shift_reg; // Bits received so far (newest bit is 0)
  reg [4:0]  bit_count; // How many bits have been received

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // Reset
      shift_reg <= 16'h0000; 
      bit_count <= 5'd0;
    end else if (ncs_falling) begin // Message starts
      shift_reg <= 16'h0000;
      bit_count <= 5'd0;
    end else if (ncs_active && sclk_rising) begin
      shift_reg <= {shift_reg[14:0], copi_sync[1]};
      bit_count <= bit_count + 5'd1;
    end
  end

  // After 16 bits
  wire rw_bit  = shift_reg[15]; // 1: Write
  wire [6:0] address = shift_reg[14:8]; // Which register
  wire [7:0] data    = shift_reg[7:0]; // The value
  
endmodule