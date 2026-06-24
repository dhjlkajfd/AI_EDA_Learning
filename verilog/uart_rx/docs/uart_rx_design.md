# UART RX Design

## 1. Function

`uart_rx` receives one standard UART frame from the serial `rx` input and outputs an 8-bit byte on `data_out`.

The first version targets a simple, readable UART RX implementation suitable for simulation, review, and portfolio presentation.

## 2. UART Frame Format

The supported UART format is:

- idle line: `1`
- start bit: `0`
- data bits: 8
- bit order: LSB first
- stop bit: `1`
- parity: none

Frame layout:

```text
idle  start    data[0] data[1] ... data[7]    stop
  1      0        LSB              MSB          1
```

## 3. Parameters and Baud Timing

| Parameter | Default | Description |
|---|---:|---|
| `CLK_FREQ` | 50000000 | Input clock frequency in Hz |
| `BAUD_RATE` | 115200 | UART baud rate |

The bit period is calculated as:

```text
CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
             = 50000000 / 115200
             = 434
```

This integer division truncates the fractional part. For the default setting, one UART bit is treated as 434 clock cycles.

`HALF_CLKS_PER_BIT` is:

```text
HALF_CLKS_PER_BIT = CLKS_PER_BIT / 2
                  = 434 / 2
                  = 217
```

It is used to check the start bit near its center, reducing the chance that a short low pulse is accepted as a valid frame.

## 4. RX Synchronizer

The external `rx` input is asynchronous to `clk`. The RTL uses a 2-stage synchronizer before the signal enters the FSM:

```verilog
rx_sync_0 <= rx;
rx_sync_1 <= rx_sync_0;
```

The FSM uses `rx_sync_1` instead of the raw `rx` input. This reduces metastability risk in FPGA implementation.

## 5. Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low reset |
| `rx` | input | 1 | UART serial receive input |
| `data_out` | output | 8 | Received byte |
| `data_valid` | output | 1 | One-clock pulse after a valid byte is received |
| `busy` | output | 1 | High while receiving a frame |

## 6. State Machine

### IDLE

The receiver waits while the synchronized RX line is high. When `rx_sync_1` becomes low, the FSM treats it as a possible start bit and enters `START`.

### START

The FSM waits `HALF_CLKS_PER_BIT` clocks and checks the start bit near its center.

- If `rx_sync_1` is still low, the frame is accepted and the FSM enters `DATA`.
- If `rx_sync_1` is high, the event is treated as a false start and the FSM returns to `IDLE`.

### DATA

The FSM samples one data bit every `CLKS_PER_BIT` clocks.

Data is stored LSB first:

```verilog
rx_shift[bit_idx] <= rx_sync_1;
```

After bit 7 is sampled, the FSM enters `STOP`.

### STOP

The FSM waits one bit period and checks the stop bit.

- If `rx_sync_1` is high, the frame is valid. `data_out` is updated and `data_valid` pulses for one clock.
- If `rx_sync_1` is low, the frame is invalid. `data_valid` remains low.

## 7. Stop Bit Error Handling

This first version has no `framing_error` output.

The stop bit policy is:

- valid stop bit `1`: update `data_out` and assert `data_valid` for one clock;
- invalid stop bit `0`: reject the frame and do not assert `data_valid`.

After either case, the FSM returns to `IDLE`.

## 8. data_valid and busy Behavior

- `busy` is asserted after a possible start bit is detected.
- `busy` stays high through start, data, and stop processing.
- `busy` returns low when the frame is complete or rejected.
- `data_valid` is a one-clock pulse.
- `data_valid` can be high in the same completion cycle where `busy` has already returned low.

## 9. Testbench Coverage

The self-checking testbench covers:

- normal frames:
  - `8'h55`
  - `8'hA5`
  - `8'h00`
  - `8'hFF`
- busy behavior:
  - busy asserts during reception;
  - busy stays high during frame processing;
  - busy returns low after completion.
- false start:
  - short low pulse shorter than `HALF_CLKS_PER_BIT`;
  - no `data_valid` should be generated.
- invalid stop bit:
  - stop bit forced low;
  - no `data_valid` should be generated.
- back-to-back frames:
  - `8'h12`
  - `8'h34`
  - `8'hA5`
  - each frame must generate the correct `data_valid` and `data_out`.

The testbench includes global and local timeout checks to avoid silent hangs.

## 10. Current Design Limitations

- No oversampling.
- No `framing_error` output.
- No parity support.
- No FIFO.
- No configurable stop bit count.
- Baud timing uses integer division.
- This is a first-version basic UART RX implementation.
