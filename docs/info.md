<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is an SPI-controlled PWM peripheral. An SPI controller writes to five 8-bit registers, and those registers control 16 output pins: `uo_out[7:0]` (outputs 0 to 7) and `uio_out[7:0]` (outputs 8 to 15). The design runs on a 10 MHz clock.

### SPI interface

The peripheral uses SPI mode 0 at about 100 kHz and is write-only, so there is no CIPO line. SCLK, COPI and nCS each pass through a two-flip-flop synchronizer into the 10 MHz clock domain. A transaction starts on the falling edge of nCS, and COPI is sampled on each rising edge of SCLK.

Every transaction is 16 bits, sent most significant bit first:

| Order | Field   | Size   | Meaning                       |
|-------|---------|--------|-------------------------------|
| 1st   | R/W     | 1 bit  | 1 = write, 0 = read (ignored) |
| 2nd   | Address | 7 bits | Valid range: 0x00 to 0x04     |
| 3rd   | Data    | 8 bits | Value to write                |

Read transactions and writes to any other address are ignored.

### Registers

| Address | Register          | Function                             | Reset |
|---------|-------------------|--------------------------------------|-------|
| 0x00    | `en_reg_out_7_0`  | Output enable for `uo_out[7:0]`      | 0x00  |
| 0x01    | `en_reg_out_15_8` | Output enable for `uio_out[7:0]`     | 0x00  |
| 0x02    | `en_reg_pwm_7_0`  | PWM enable for `uo_out[7:0]`         | 0x00  |
| 0x03    | `en_reg_pwm_15_8` | PWM enable for `uio_out[7:0]`        | 0x00  |
| 0x04    | `pwm_duty_cycle`  | PWM duty cycle (0x00 = 0%, 0xFF = 100%) | 0x00  |

### Output behaviour

Each output pin is controlled by its own output-enable bit and PWM-enable bit. Output enable takes precedence.

| Output enable | PWM enable | Pin        |
|---------------|------------|------------|
| 0             | any        | 0          |
| 1             | 0          | 1          |
| 1             | 1          | PWM signal |

### PWM

The PWM signal is about 3 kHz, derived from the 10 MHz clock by dividing by 13 x 256. All PWM outputs share one duty cycle, equal to `pwm_duty_cycle` / 256. The value 0xFF is a special case that holds the output high (100%).

## How to test

Connect an SPI controller to `ui_in[0]` (SCLK), `ui_in[1]` (COPI) and `ui_in[2]` (nCS), then reset the design. All outputs start at 0.

1. Write 0xFF to address 0x00. Outputs `uo_out[7:0]` go high. The bits sent are `1000 0000 1111 1111`.
2. Write 0xFF to address 0x02. Those outputs switch to PWM and go low, because the duty cycle resets to 0x00.
3. Write 0x80 to address 0x04. The outputs show a 50% duty cycle at about 3 kHz, which can be checked with an oscilloscope.
4. Write 0xFF to address 0x04. The outputs stay high.

To run the simulation tests, go to the `test` folder and run `make -B`.

## External hardware

An SPI controller, such as a microcontroller, to drive SCLK, COPI and nCS. LEDs or an oscilloscope on the output pins are useful for observing the result.
