`timescale 1ns / 1ps

// UART TX to RX loopback system.
//
// This top-level module connects uart_tx.tx directly to uart_rx.rx.
// The internal serial line is also exported as tx_line for testbench and
// waveform observation.
module uart_loopback #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       data_valid,
    input  wire [7:0] data_in,

    output wire       tx_busy,
    output wire       rx_busy,
    output wire       rx_data_valid,
    output wire [7:0] rx_data_out,
    output wire       tx_line
);

    wire loopback_serial;

    assign tx_line = loopback_serial;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .tx(loopback_serial),
        .busy(tx_busy)
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(loopback_serial),
        .data_out(rx_data_out),
        .data_valid(rx_data_valid),
        .busy(rx_busy)
    );

endmodule
