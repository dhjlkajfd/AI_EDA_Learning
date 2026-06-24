# UART Loopback Project

## Project Overview

This project implements an internal UART TX -> UART RX loopback system.

It is not a board-level external UART loopback test. The system connects the `tx` output of `uart_tx` directly to the `rx` input of `uart_rx` inside the RTL. The goal is to verify that the UART transmitter and receiver modules can be integrated and tested as a small system.

The top-level accepts 8-bit parallel input data and a one-clock `data_valid` request. `uart_tx` serializes the byte onto `tx_line`. The same serial line is connected to `uart_rx`, which receives the UART frame and reconstructs the original 8-bit data.

## Project Structure

```text
verilog/uart_loopback/
|-- src/
|   |-- uart_loopback.v
|   |-- uart_tx.v
|   `-- uart_rx.v
|-- tb/
|   `-- tb_uart_loopback.v
|-- sim/
|   `-- run_sim.ps1
|-- docs/
|   `-- uart_loopback_design.md
`-- README.md
```

## Top-level Module Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low reset |
| `data_valid` | input | 1 | One-clock transmit request |
| `data_in` | input | 8 | Parallel byte sent into `uart_tx` |
| `tx_busy` | output | 1 | High while `uart_tx` is transmitting |
| `rx_busy` | output | 1 | High while `uart_rx` is receiving |
| `rx_data_valid` | output | 1 | One-clock pulse when `rx_data_out` is valid |
| `rx_data_out` | output | 8 | Byte reconstructed by `uart_rx` |
| `tx_line` | output | 1 | Internal UART serial line exported for waveform observation |

## Internal Architecture

```text
data_in/data_valid
     |
     v
  uart_tx
     |
     | tx_line
     v
  uart_rx
     |
     v
rx_data_out/rx_data_valid
```

`tx_line` is the internal serial connection between the transmitter and receiver. It is also exported from the top-level module so the testbench and GTKWave can inspect the UART frame.

## Data Flow

```text
data_in -> uart_tx -> tx_line -> uart_rx -> rx_data_out
```

The expected result is that `rx_data_out` matches the original `data_in` value when `rx_data_valid` pulses high.

## Tested Bytes

The self-checking testbench currently verifies:

- `8'h55`
- `8'hA5`
- `8'h00`
- `8'hFF`
- `8'h3C`
- `8'hC3`

## How to Run Simulation

From the repository root:

```powershell
cd verilog/uart_loopback/sim
powershell -ExecutionPolicy Bypass -File .\run_sim.ps1
```

The script checks for `iverilog` and `vvp`, compiles the RTL and testbench with Icarus Verilog, and runs the simulation.

## Expected Output

A passing simulation should include output similar to:

```text
Testing loopback byte: 0x55
PASS: rx_busy held through RX frame. data=0x55
PASS: tx_busy held through TX frame. data=0x55 cycles=4339
PASS: Loopback byte 0x55 received correctly.
Testing loopback byte: 0xa5
PASS: rx_busy held through RX frame. data=0xa5
PASS: tx_busy held through TX frame. data=0xa5 cycles=4339
PASS: Loopback byte 0xa5 received correctly.
Testing loopback byte: 0x00
PASS: rx_busy held through RX frame. data=0x00
PASS: tx_busy held through TX frame. data=0x00 cycles=4339
PASS: Loopback byte 0x00 received correctly.
Testing loopback byte: 0xff
PASS: rx_busy held through RX frame. data=0xff
PASS: tx_busy held through TX frame. data=0xff cycles=4339
PASS: Loopback byte 0xff received correctly.
Testing loopback byte: 0x3c
PASS: rx_busy held through RX frame. data=0x3c
PASS: tx_busy held through TX frame. data=0x3c cycles=4339
PASS: Loopback byte 0x3c received correctly.
Testing loopback byte: 0xc3
PASS: rx_busy held through RX frame. data=0xc3
PASS: tx_busy held through TX frame. data=0xc3 cycles=4339
PASS: Loopback byte 0xc3 received correctly.
PASS: UART Loopback test completed successfully.
PASS: Simulation finished.
```

## Waveform

The simulation generates:

```text
verilog/uart_loopback/sim/uart_loopback.vcd
```

Recommended signals to inspect:

- `data_valid`
- `data_in[7:0]`
- `tx_busy`
- `tx_line`
- `rx_busy`
- `rx_data_valid`
- `rx_data_out[7:0]`

## Current Limitations

- Internal loopback only, not a board-level UART test.
- No parity.
- No FIFO.
- No noise injection.
- No baud mismatch tolerance test.
- No real FPGA pin constraints.

## Future Improvements

- Add FPGA board verification.
- Add baud mismatch test.
- Add parity support.
- Add multi-byte stream test.
- Add error frame test.
