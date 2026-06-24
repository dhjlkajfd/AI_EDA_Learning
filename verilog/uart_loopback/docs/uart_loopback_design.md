# UART Loopback Design

## 1. Design Goal

This project integrates `uart_tx` and `uart_rx` into a small internal UART loopback system.

The goal is to verify that data transmitted by the UART TX module can be received and reconstructed correctly by the UART RX module when both modules are connected inside the RTL.

This is an internal module integration test. It is not a physical board-level UART loopback test.

## 2. System Architecture

```text
data_valid/data_in
       |
       v
   uart_tx
       |
       | tx_line
       v
   uart_rx
       |
       v
rx_data_valid/rx_data_out
```

The system accepts one 8-bit parallel byte, serializes it through `uart_tx`, sends the serial frame through `tx_line`, and receives it back through `uart_rx`.

## 3. Module Connection

- `uart_tx.tx` is connected directly to `uart_rx.rx`.
- `tx_line` is the same internal serial line exported as a top-level output for simulation and waveform observation.
- `uart_tx` and `uart_rx` use the same `CLK_FREQ` and `BAUD_RATE` parameters.
- The top-level module does not add protocol logic. It only connects the TX and RX modules.

## 4. Top-level Parameters

| Parameter | Default | Description |
|---|---:|---|
| `CLK_FREQ` | 50000000 | System clock frequency in Hz |
| `BAUD_RATE` | 115200 | UART baud rate |

Derived timing:

```text
CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
             = 50000000 / 115200
             = 434
```

The TX and RX modules both use this same bit timing value through the shared top-level parameters.

## 5. Top-level Ports

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low reset |
| `data_valid` | input | 1 | One-clock request to transmit `data_in` |
| `data_in` | input | 8 | Parallel byte sent to `uart_tx` |
| `tx_busy` | output | 1 | High while `uart_tx` is sending a UART frame |
| `rx_busy` | output | 1 | High while `uart_rx` is receiving a UART frame |
| `rx_data_valid` | output | 1 | One-clock pulse when `rx_data_out` is valid |
| `rx_data_out` | output | 8 | Byte recovered by `uart_rx` |
| `tx_line` | output | 1 | Internal serial UART line exported for observation |

## 6. Timing Flow

1. The testbench drives `data_in` and asserts `data_valid` for one clock.
2. `uart_tx` samples `data_in` when it accepts the request.
3. `tx_busy` asserts while the TX frame is being sent.
4. `tx_line` outputs the UART serial frame.
5. `uart_rx` observes `tx_line` and detects the start bit.
6. `rx_busy` asserts while the RX frame is being received.
7. `uart_rx` samples the data bits in LSB-first order.
8. After the stop bit, `rx_data_valid` asserts for one clock.
9. `rx_data_out` holds the recovered byte.

TX and RX busy timing do not need to start and end on the exact same clock because RX includes start bit detection and synchronization latency.

## 7. Verification Strategy

The self-checking testbench verifies the loopback path by:

- sending multiple test bytes into the top-level input;
- waiting for `rx_data_valid`;
- checking that `rx_data_out` equals the transmitted byte;
- checking that `rx_data_valid` is a one-clock pulse;
- checking that `tx_busy` asserts and remains active through the TX frame;
- checking that `rx_busy` asserts and remains active through the RX frame;
- checking that `tx_busy` and `rx_busy` return low after frame completion;
- using timeout counters so simulation cannot hang silently.

## 8. Test Coverage

Tested data values:

- `8'h55`
- `8'hA5`
- `8'h00`
- `8'hFF`
- `8'h3C`
- `8'hC3`

Behavior coverage:

- `tx_busy` behavior
- `rx_busy` behavior
- `rx_data_valid` single-cycle behavior
- `rx_data_out` data match
- timeout protection

## 9. Current Limitations

- Internal loopback only, not an external physical UART test.
- Baud rate mismatch tolerance is not tested.
- No noise injection.
- No FIFO.
- No parity.
- No FPGA board-level verification yet.

## 10. Future Improvements

- FPGA board-level loopback.
- External UART pin constraints.
- Baud mismatch tolerance testing.
- Parity support.
- Multi-byte stream mode.
- Error frame injection.
