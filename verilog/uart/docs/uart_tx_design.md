# UART TX Design

## 1. Function

UART TX converts 8-bit parallel data into serial UART data.

Frame format:

- 1 start bit: 0
- 8 data bits: LSB first
- 1 stop bit: 1

## 2. Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| clk | input | 1 | System clock |
| rst_n | input | 1 | Active-low reset |
| data_in | input | 8 | Parallel input data |
| data_valid | input | 1 | Input data valid |
| tx | output | 1 | UART serial output |
| busy | output | 1 | TX module is busy |

## 3. Parameters

| Parameter | Default | Description |
|---|---:|---|
| CLK_FREQ | 50000000 | Clock frequency |
| BAUD_RATE | 115200 | UART baud rate |

## 4. State Machine

States:

1. IDLE
2. START
3. DATA
4. STOP

## 5. Design Notes

- TX line is high when idle.
- Data is transmitted LSB first.
- busy is high during transmission.
- New data is accepted only when the module is idle.