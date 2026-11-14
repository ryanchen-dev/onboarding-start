## How it works

This is an SPI-controlled PWM peripheral. The clock is 10 MHz, and it is write only (read messages are ignored). There are three SPI input pins from the controller (SCLK, COPI, nCS).
Each message should normally come from a microcontroller, but in this simulation it comes from cocotb. Each message contains 16 bits, sent from most significant to least.
These messages change 5 registers, which control outputs.

## The registers
0x00 & 0x01: switches pin on or off
0x02 & 0x03: determines whether PWM
0x04: duty cycle (all pwm pins share it; it determines how much the pwm pins are high)

## How to test
run make -B in the test folder