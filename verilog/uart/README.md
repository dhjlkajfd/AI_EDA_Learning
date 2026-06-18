# UART Project

## Goal

This project implements a UART transmitter and its testbench.

## Module List

- uart_tx.v
- tb_uart_tx.v

## UART TX Features

- 50MHz input clock
- 115200 baud rate
- 8-bit data
- 1 start bit
- 8 data bits
- 1 stop bit
- LSB first
- busy output
- data_valid input handshake

## Directory Structure

uart/
├── src/
│   └── uart_tx.v
├── tb/
│   └── tb_uart_tx.v
├── docs/
│   └── uart_tx_design.md
└── sim/
    └── run_sim.md

## Status

In development.