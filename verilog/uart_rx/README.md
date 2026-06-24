# UART RX Project

## Goal

This project implements a basic UART receiver and a self-checking Verilog testbench.

## Features

- 50 MHz default input clock
- 115200 default baud rate
- 8 data bits
- 1 start bit
- 1 stop bit
- LSB-first receive order
- no parity
- one-clock `data_valid` pulse after a valid frame
- `busy` asserted while receiving

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

## Run Simulation

From `verilog/uart_rx/sim`:

```powershell
.\run_sim.ps1
```

Expected final output:

```text
PASS: UART RX test completed successfully.
```
