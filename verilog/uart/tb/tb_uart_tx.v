`timescale 1ns / 1ps

module tb_uart_tx;

    parameter CLK_FREQ     = 50000000;
    parameter BAUD_RATE    = 115200;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    parameter CLK_PERIOD   = 20;

    reg        clk;
    reg        rst_n;
    reg [7:0]  data_in;
    reg        data_valid;
    wire       tx;
    wire       busy;

    integer error_count;
    integer i;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .tx(tx),
        .busy(busy)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        error_count = 0;
        rst_n = 1'b0;
        data_in = 8'd0;
        data_valid = 1'b0;

        repeat (10) @(posedge clk);
        rst_n = 1'b1;
        repeat (10) @(posedge clk);

        run_uart_test(8'h55);
        run_uart_test(8'hA5);
        run_uart_test(8'h00);
        run_uart_test(8'hFF);

        repeat (20) @(posedge clk);

        if (error_count == 0) begin
            $display("PASS: UART TX test completed successfully.");
        end else begin
            $display("FAIL: UART TX test failed. error_count = %0d", error_count);
        end

        $finish;
    end

    task run_uart_test;
        input [7:0] test_data;
        begin
            $display("Testing byte: 0x%02h", test_data);

            fork
                send_byte(test_data);
                check_uart_frame(test_data);
            join
        end
    endtask

    task send_byte;
        input [7:0] send_data;
        begin
            @(posedge clk);
            while (busy) @(posedge clk);

            data_in <= send_data;
            data_valid <= 1'b1;

            @(posedge clk);
            data_valid <= 1'b0;
            data_in <= 8'd0;

            @(negedge busy);
            repeat (5) @(posedge clk);
        end
    endtask

    task check_uart_frame;
        input [7:0] expected_data;
        begin
            @(negedge tx);

            repeat (CLKS_PER_BIT / 2) @(posedge clk);

            if (tx !== 1'b0) begin
                $display("ERROR: Start bit should be 0.");
                error_count = error_count + 1;
            end

            for (i = 0; i < 8; i = i + 1) begin
                repeat (CLKS_PER_BIT) @(posedge clk);

                if (tx !== expected_data[i]) begin
                    $display("ERROR: Data bit %0d mismatch. Expected %b, got %b",
                             i, expected_data[i], tx);
                    error_count = error_count + 1;
                end
            end

            repeat (CLKS_PER_BIT) @(posedge clk);

            if (tx !== 1'b1) begin
                $display("ERROR: Stop bit should be 1.");
                error_count = error_count + 1;
            end
        end
    endtask

endmodule