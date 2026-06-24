`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,

    input  wire [7:0] data_in,
    input  wire       data_valid,

    output reg        tx,
    output reg        busy
);

    // Handshake rule:
    // - data_valid is accepted only when busy is 0.
    // - data_in is sampled when a valid request is accepted.
    // - data_valid asserted while busy is 1 is ignored.
    // - No FIFO is implemented; requests during busy are not buffered.

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam [1:0]
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3;

    reg [1:0]  state;
    reg [31:0] baud_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            baud_cnt  <= 32'd0;
            bit_idx   <= 3'd0;
            shift_reg <= 8'd0;
            tx        <= 1'b1;
            busy      <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    tx       <= 1'b1;
                    busy     <= 1'b0;
                    baud_cnt <= 32'd0;
                    bit_idx  <= 3'd0;

                    if (data_valid) begin
                        shift_reg <= data_in;
                        busy      <= 1'b1;
                        tx        <= 1'b0;
                        state     <= START;
                    end
                end

                START: begin
                    busy <= 1'b1;
                    tx   <= 1'b0;

                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 32'd0;
                        state    <= DATA;
                        tx       <= shift_reg[0];
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                DATA: begin
                    busy <= 1'b1;
                    tx   <= shift_reg[bit_idx];

                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 32'd0;

                        if (bit_idx == 3'd7) begin
                            bit_idx <= 3'd0;
                            state   <= STOP;
                            tx      <= 1'b1;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                            tx      <= shift_reg[bit_idx + 1'b1];
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                STOP: begin
                    busy <= 1'b1;
                    tx   <= 1'b1;

                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 32'd0;
                        busy     <= 1'b0;
                        state    <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: begin
                    state     <= IDLE;
                    baud_cnt  <= 32'd0;
                    bit_idx   <= 3'd0;
                    shift_reg <= 8'd0;
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                end

            endcase
        end
    end

endmodule
