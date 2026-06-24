# UART TX Verilog Project

## 1. Project Overview

This project implements a simple UART transmitter using Verilog HDL.

It includes:

- UART TX RTL design
- Self-checking Verilog testbench
- UART frame duration check
- Handshake behavior verification
- Timeout protection in testbench
- Icarus Verilog simulation
- PowerShell simulation script

## 2. Features

- 8-bit UART transmission
- 1 start bit
- 8 data bits
- 1 stop bit
- No parity bit
- Parameterized clock frequency and baud rate
- `busy` signal during transmission
- Self-checking testbench
- Verification that `data_valid` during `busy = 1` is ignored

## 3. Directory Structure

```text
verilog/uart/
├── src/
│   └── uart_tx.v
├── tb/
│   └── tb_uart_tx.v
├── sim/
│   └── run_sim.ps1
├── docs/
│   └── uart_tx_design.md
└── README.md