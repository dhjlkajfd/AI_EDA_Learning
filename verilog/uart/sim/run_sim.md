# UART TX Simulation

## Tool

Recommended tool:

- Icarus Verilog
- GTKWave

## Compile

Run this command inside `verilog/uart/sim`:

```bash
iverilog -o uart_tx_sim ../src/uart_tx.v ../tb/tb_uart_tx.v
```

## Run

```bash
vvp uart_tx_sim
```

## View Waveform

```bash
gtkwave uart_tx.vcd
```

## Expected Result

The terminal should print:

```text
PASS: UART TX test completed successfully.
```