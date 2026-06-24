# UART RX Design

## Function

`uart_rx` receives one UART frame from the serial `rx` line and outputs one 8-bit byte.

Frame format:

- idle line: 1
- start bit: 0
- data bits: 8 bits, LSB first
- stop bit: 1
- parity: none

## Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| clk | input | 1 | System clock |
| rst_n | input | 1 | Active-low reset |
| rx | input | 1 | UART serial receive input |
| data_out | output | 8 | Received byte |
| data_valid | output | 1 | One-clock pulse after a valid byte is received |
| busy | output | 1 | High while receiving a frame |

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| CLK_FREQ | 50000000 | Input clock frequency |
| BAUD_RATE | 115200 | UART baud rate |

`CLKS_PER_BIT = CLK_FREQ / BAUD_RATE`.

## State Machine

1. `IDLE`: wait for `rx` to go low.
2. `START`: sample the start bit near its center.
3. `DATA`: sample 8 data bits, LSB first.
4. `STOP`: sample the stop bit and assert `data_valid` for one clock if valid.

## Notes

- This first version targets functional simulation with Icarus Verilog.
- `data_valid` is asserted only when the stop bit is high.
- No parity checking or framing error output is implemented yet.
