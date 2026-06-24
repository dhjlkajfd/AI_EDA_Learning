# UART RX Project

## Project Overview

This project implements a basic UART receiver in Verilog-2005 with a self-checking testbench and an Icarus Verilog simulation script.

The receiver accepts a standard UART frame on `rx`, samples the serial data near each bit center, and outputs one received byte with a one-clock `data_valid` pulse.

## Directory Structure

```text
uart_rx/
|-- src/
|   `-- uart_rx.v
|-- tb/
|   `-- tb_uart_rx.v
|-- sim/
|   `-- run_sim.ps1
|-- docs/
|   `-- uart_rx_design.md
`-- README.md
```

## Module Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low asynchronous reset |
| `rx` | input | 1 | UART serial input |
| `data_out` | output | 8 | Received byte |
| `data_valid` | output | 1 | One-clock pulse when `data_out` is valid |
| `busy` | output | 1 | High while a frame is being received |

## UART RX Function

Default configuration:

- `CLK_FREQ = 50000000`
- `BAUD_RATE = 115200`
- 1 start bit
- 8 data bits
- LSB first
- 1 stop bit
- no parity

UART frame:

```text
idle  start    data[0] ... data[7]    stop
  1      0       LSB          MSB        1
```

## Start Bit Detection

The RX line is idle high. When the synchronized `rx` input goes low, the receiver treats this as a possible start bit and enters the `START` state.

The start bit is checked again around the bit center. If the line has returned high before the center point, the event is treated as a false start and the receiver returns to idle.

## Bit Center Sampling

With the default parameters:

```text
CLKS_PER_BIT = 50000000 / 115200 = 434
HALF_CLKS_PER_BIT = 434 / 2 = 217
```

The receiver:

- checks the start bit after `HALF_CLKS_PER_BIT` clocks;
- samples each data bit every `CLKS_PER_BIT` clocks after that;
- checks the stop bit after the final data bit period.

## data_valid and busy Behavior

- `busy` goes high while the receiver is processing a frame.
- `busy` returns low when the frame is complete or rejected.
- `data_valid` pulses high for exactly one clock after a valid stop bit is received.
- `data_valid` is not asserted when the stop bit is invalid.
- `data_valid` may assert in the same cycle that `busy` has returned low.

## Run Simulation

From `verilog/uart_rx/sim`:

```powershell
.\run_sim.ps1
```

The script checks for `iverilog` and `vvp`, creates `sim/build/`, compiles with `iverilog -g2005 -Wall`, and runs the simulation.

## Expected PASS Output

Expected output includes:

```text
Testing RX byte: 0x55
PASS: busy behavior OK for RX byte 0x55.
PASS: RX byte 0x55 received correctly.
Testing RX byte: 0xa5
PASS: busy behavior OK for RX byte 0xa5.
PASS: RX byte 0xa5 received correctly.
Testing RX byte: 0x00
PASS: busy behavior OK for RX byte 0x00.
PASS: RX byte 0x00 received correctly.
Testing RX byte: 0xff
PASS: busy behavior OK for RX byte 0xff.
PASS: RX byte 0xff received correctly.
Testing false start: test_false_start_ignored
PASS: test_false_start_ignored
Testing invalid stop bit: test_invalid_stop_bit
PASS: test_invalid_stop_bit
Testing back-to-back frames: test_back_to_back_frames
PASS: back-to-back frame 0 received correctly. data=0x12
PASS: back-to-back frame 1 received correctly. data=0x34
PASS: back-to-back frame 2 received correctly. data=0xa5
PASS: test_back_to_back_frames
PASS: UART RX test completed successfully.
PASS: Simulation finished.
```

## Current Limitations

- No oversampling.
- No `framing_error` output.
- No parity support.
- No FIFO.
- First version only targets a basic UART RX function.

## Future Improvements

- Add 8x or 16x oversampling.
- Add `framing_error` and optional error counters.
- Add parity support.
- Add configurable data width and stop bit count.
- Add RX FIFO and ready/valid style output handshake.
- Add synthesis checks and optional FPGA loopback demo with UART TX.
