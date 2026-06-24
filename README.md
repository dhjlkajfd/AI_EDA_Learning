# AI EDA Learning

This repository records my AI-assisted Verilog / FPGA / RTL learning and practice projects.

## Current Projects

| Project | Description | Status |
|---|---|---|
| UART TX | Verilog UART transmitter with self-checking testbench | Completed |
| UART RX | Verilog UART receiver with self-checking testbench | Completed |
| UART Loopback | UART TX + RX internal loopback system | Completed |

## UART TX Highlights

The UART TX project includes:

- Verilog RTL design
- Parameterized baud rate
- Self-checking testbench
- Timeout protection
- UART frame duration check
- Handshake behavior verification
- Icarus Verilog simulation
- PowerShell simulation script
- Design documentation

## Tools

- Verilog HDL
- Icarus Verilog
- GTKWave
- Git / GitHub
- Codex-assisted workflow

## Project Structure

```text
ai-EDA-learning/
├── README.md
└── verilog/
    └── uart/
        ├── src/
        ├── tb/
        ├── sim/
        ├── docs/
        └── README.md
