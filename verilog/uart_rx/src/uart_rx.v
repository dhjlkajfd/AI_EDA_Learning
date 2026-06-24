`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,

    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        busy
);

    localparam integer CLKS_PER_BIT      = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_CLKS_PER_BIT = CLKS_PER_BIT / 2;

    localparam [1:0]
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3;

    reg [1:0]  state;
    reg [31:0] baud_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  rx_shift;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            baud_cnt   <= 32'd0;
            bit_idx    <= 3'd0;
            rx_shift   <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
            busy       <= 1'b0;
        end else begin
            data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    busy     <= 1'b0;
                    baud_cnt <= 32'd0;
                    bit_idx  <= 3'd0;

                    if (rx == 1'b0) begin
                        busy  <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    busy <= 1'b1;

                    if (baud_cnt == HALF_CLKS_PER_BIT - 1) begin
                        baud_cnt <= 32'd0;

                        if (rx == 1'b0) begin
                            state <= DATA;
                        end else begin
                            busy  <= 1'b0;
                            state <= IDLE;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                DATA: begin
                    busy <= 1'b1;

                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt         <= 32'd0;
                        rx_shift[bit_idx] <= rx;

                        if (bit_idx == 3'd7) begin
                            bit_idx <= 3'd0;
                            state   <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                STOP: begin
                    busy <= 1'b1;

                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 32'd0;
                        busy     <= 1'b0;
                        state    <= IDLE;

                        if (rx == 1'b1) begin
                            data_out   <= rx_shift;
                            data_valid <= 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: begin
                    state      <= IDLE;
                    baud_cnt   <= 32'd0;
                    bit_idx    <= 3'd0;
                    rx_shift   <= 8'd0;
                    data_valid <= 1'b0;
                    busy       <= 1'b0;
                end
            endcase
        end
    end

endmodule
