`timescale 1ns / 1ps

module tb_uart_loopback;

    parameter CLK_FREQ      = 50000000;
    parameter BAUD_RATE     = 115200;
    parameter CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
    parameter CLK_PERIOD    = 20;
    parameter FRAME_CLKS    = 10 * CLKS_PER_BIT;
    parameter BUSY_TOL      = 3;
    parameter FRAME_TIMEOUT = 25 * CLKS_PER_BIT;
    parameter BUSY_TIMEOUT  = 4 * CLKS_PER_BIT;
    parameter GLOBAL_TIMEOUT = (FRAME_TIMEOUT * 10) + 1000;

    reg        clk;
    reg        rst_n;
    reg        data_valid;
    reg [7:0]  data_in;

    wire       tx_busy;
    wire       rx_busy;
    wire       rx_data_valid;
    wire [7:0] rx_data_out;
    wire       tx_line;

    integer error_count;

    uart_loopback #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(data_valid),
        .data_in(data_in),
        .tx_busy(tx_busy),
        .rx_busy(rx_busy),
        .rx_data_valid(rx_data_valid),
        .rx_data_out(rx_data_out),
        .tx_line(tx_line)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        repeat (GLOBAL_TIMEOUT) @(posedge clk);
        $display("FAIL/TIMEOUT: UART Loopback simulation timeout at time %0t.", $time);
        $finish;
    end

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        error_count = 0;
        rst_n = 1'b0;
        data_valid = 1'b0;
        data_in = 8'd0;

        repeat (10) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        repeat (10) @(posedge clk);

        run_loopback_test(8'h55);
        run_loopback_test(8'hA5);
        run_loopback_test(8'h00);
        run_loopback_test(8'hFF);
        run_loopback_test(8'h3C);
        run_loopback_test(8'hC3);

        repeat (20) @(posedge clk);

        if (error_count == 0) begin
            $display("PASS: UART Loopback test completed successfully.");
        end else begin
            $display("FAIL: UART Loopback test failed. error_count = %0d", error_count);
        end

        $finish;
    end

    task run_loopback_test;
        input [7:0] test_data;
        integer start_error_count;
        begin
            start_error_count = error_count;
            $display("Testing loopback byte: 0x%02h", test_data);

            send_loopback_byte(test_data);
            fork
                check_tx_busy_behavior(test_data);
                check_rx_busy_behavior(test_data);
                wait_for_rx_data(test_data, FRAME_TIMEOUT);
            join
            check_busy_low_after_frame(test_data);

            if (error_count == start_error_count) begin
                $display("PASS: Loopback byte 0x%02h received correctly.", test_data);
            end else begin
                $display("FAIL: Loopback byte 0x%02h failed. new_errors=%0d",
                         test_data, error_count - start_error_count);
            end

            repeat (5) @(posedge clk);
        end
    endtask

    task send_loopback_byte;
        input [7:0] send_data;
        begin
            wait_for_idle(FRAME_TIMEOUT);

            @(negedge clk);
            data_in = send_data;
            data_valid = 1'b1;

            @(posedge clk);
            #1;

            if (data_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: input data_valid should be high for one clock.");
            end

            @(negedge clk);
            data_valid = 1'b0;
            data_in = 8'd0;

            @(posedge clk);
            #1;

            if (data_valid !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: input data_valid should deassert after one clock.");
            end
        end
    endtask

    task wait_for_rx_data;
        input [7:0] expected_data;
        input integer max_cycles;
        integer wait_count;
        begin
            wait_count = 0;

            while ((rx_data_valid !== 1'b1) && (wait_count < max_cycles)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (rx_data_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: rx_data_valid did not assert. expected=0x%02h",
                         expected_data);
                $finish;
            end

            if (rx_data_out !== expected_data) begin
                error_count = error_count + 1;
                $display("FAIL: RX data mismatch. expected=0x%02h actual=0x%02h",
                         expected_data, rx_data_out);
            end

            @(posedge clk);
            #1;

            if (rx_data_valid !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: rx_data_valid should be a one-clock pulse.");
            end
        end
    endtask

    task check_tx_busy_behavior;
        input [7:0] expected_data;
        integer wait_count;
        integer high_count;
        begin
            wait_count = 0;
            high_count = 0;

            while ((tx_busy !== 1'b1) && (wait_count < BUSY_TIMEOUT)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (tx_busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: tx_busy did not assert within %0d clocks. expected_data=0x%02h",
                         BUSY_TIMEOUT, expected_data);
                $finish;
            end

            high_count = 1;
            while ((tx_busy === 1'b1) && (high_count <= FRAME_TIMEOUT)) begin
                @(posedge clk);
                #1;

                if (tx_busy === 1'b1) begin
                    high_count = high_count + 1;
                end
            end

            if (tx_busy === 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: tx_busy did not deassert after %0d clocks. expected_data=0x%02h",
                         FRAME_TIMEOUT, expected_data);
                $finish;
            end

            if (high_count < (FRAME_CLKS - BUSY_TOL)) begin
                error_count = error_count + 1;
                $display("FAIL: tx_busy dropped early. expected_data=0x%02h min_cycles=%0d actual_cycles=%0d",
                         expected_data, FRAME_CLKS - BUSY_TOL, high_count);
            end else begin
                $display("PASS: tx_busy held through TX frame. data=0x%02h cycles=%0d",
                         expected_data, high_count);
            end
        end
    endtask

    task check_rx_busy_behavior;
        input [7:0] expected_data;
        integer wait_count;
        integer monitor_count;
        integer busy_error_seen;
        begin
            wait_count = 0;
            monitor_count = 0;
            busy_error_seen = 0;

            while ((rx_busy !== 1'b1) && (wait_count < BUSY_TIMEOUT)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (rx_busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: rx_busy did not assert within %0d clocks. expected_data=0x%02h",
                         BUSY_TIMEOUT, expected_data);
                $finish;
            end

            while ((rx_data_valid !== 1'b1) && (monitor_count < FRAME_TIMEOUT)) begin
                @(posedge clk);
                #1;
                monitor_count = monitor_count + 1;

                if ((rx_data_valid !== 1'b1) && (rx_busy !== 1'b1) &&
                    (busy_error_seen == 0)) begin
                    busy_error_seen = 1;
                    error_count = error_count + 1;
                    $display("FAIL: rx_busy dropped before rx_data_valid. expected_data=0x%02h monitor_count=%0d",
                             expected_data, monitor_count);
                end
            end

            if (rx_data_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: rx_data_valid missing during rx_busy check. expected_data=0x%02h",
                         expected_data);
                $finish;
            end

            @(posedge clk);
            #1;

            if (rx_busy !== 1'b0) begin
                busy_error_seen = 1;
                error_count = error_count + 1;
                $display("FAIL: rx_busy should return to 0 after rx_data_valid. expected_data=0x%02h busy=%b",
                         expected_data, rx_busy);
            end

            if (busy_error_seen == 0) begin
                $display("PASS: rx_busy held through RX frame. data=0x%02h",
                         expected_data);
            end
        end
    endtask

    task wait_for_idle;
        input integer max_cycles;
        integer wait_count;
        begin
            wait_count = 0;

            while (((tx_busy !== 1'b0) || (rx_busy !== 1'b0)) &&
                   (wait_count < max_cycles)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if ((tx_busy !== 1'b0) || (rx_busy !== 1'b0)) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: DUT did not become idle. tx_busy=%b rx_busy=%b",
                         tx_busy, rx_busy);
                $finish;
            end
        end
    endtask

    task check_busy_low_after_frame;
        input [7:0] expected_data;
        integer wait_count;
        begin
            wait_count = 0;

            while (((tx_busy !== 1'b0) || (rx_busy !== 1'b0)) &&
                   (wait_count < BUSY_TIMEOUT)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (tx_busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: tx_busy should return to 0 after loopback byte 0x%02h.", expected_data);
            end

            if (rx_busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: rx_busy should return to 0 after loopback byte 0x%02h.", expected_data);
            end
        end
    endtask

endmodule
