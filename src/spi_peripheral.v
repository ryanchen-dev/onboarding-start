/*
 * Copyright (c) 2026 Ryan Chen
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module spi_peripheral (
    input  wire       clk,              // System Clock - 10 MHz
    input  wire       rst_n,            // Reset: active low
    input  wire       sclk,             // SPI clock - controller
    input  wire       copi,             // SPI data - controller
    input  wire       ncs,              // SPI chip select: active low
    output reg  [7:0] en_reg_out_7_0,   // 0x00
    output reg  [7:0] en_reg_out_15_8,  // 0x01
    output reg  [7:0] en_reg_pwm_7_0,   // 0x02
    output reg  [7:0] en_reg_pwm_15_8,  // 0x03
    output reg  [7:0] pwm_duty_cycle    // 0x04
);

endmodule
