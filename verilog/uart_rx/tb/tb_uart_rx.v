`timescale 1ns / 1ps

module tb_uart_rx;

    parameter CLK_FREQ        = 50000000;
    parameter BAUD_RATE       = 115200;
    parameter CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    parameter CLK_PERIOD      = 20;
    parameter FRAME_WAIT_CLKS = 12 * CLKS_PER_BIT;
    parameter BUSY_WAIT_CLKS  = 2 * CLKS_PER_BIT;
    parameter GLOBAL_TIMEOUT  = (FRAME_WAIT_CLKS * 8) + 1000;

    reg        clk;
    reg        rst_n;
    reg        rx;
    wire [7:0] data_out;
    wire       data_valid;
    wire       busy;

    integer error_count;
    integer i;

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid),
        .busy(busy)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        repeat (GLOBAL_TIMEOUT) @(posedge clk);
        $display("FAIL/TIMEOUT: UART RX simulation timeout at time %0t.", $time);
        $finish;
    end

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        error_count = 0;
        rst_n = 1'b0;
        rx = 1'b1;

        repeat (10) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        repeat (10) @(posedge clk);

        run_uart_rx_test(8'h55);
        run_uart_rx_test(8'hA5);
        run_uart_rx_test(8'h00);
        run_uart_rx_test(8'hFF);
        test_false_start_ignored;
        test_invalid_stop_bit;

        repeat (20) @(posedge clk);

        if (error_count == 0) begin
            $display("PASS: UART RX test completed successfully.");
        end else begin
            $display("FAIL: UART RX test failed. error_count = %0d", error_count);
        end

        $finish;
    end

    task run_uart_rx_test;
        input [7:0] expected_data;
        integer start_error_count;
        begin
            start_error_count = error_count;
            $display("Testing RX byte: 0x%02h", expected_data);

            fork
                drive_uart_frame(expected_data);
                check_received_byte(expected_data);
                check_busy_behavior(expected_data);
            join

            if (error_count == start_error_count) begin
                $display("PASS: RX byte 0x%02h received correctly.", expected_data);
            end else begin
                $display("FAIL: RX byte 0x%02h failed. new_errors=%0d",
                         expected_data, error_count - start_error_count);
            end

            repeat (5) @(posedge clk);
        end
    endtask

    task test_false_start_ignored;
        integer wait_count;
        integer start_error_count;
        integer pulse_clks;
        begin
            start_error_count = error_count;
            pulse_clks = (CLKS_PER_BIT / 4);

            if (pulse_clks < 1) begin
                pulse_clks = 1;
            end

            $display("Testing false start: test_false_start_ignored");

            rx = 1'b1;
            repeat (5) @(posedge clk);

            @(negedge clk);
            rx = 1'b0;
            repeat (pulse_clks) @(posedge clk);

            @(negedge clk);
            rx = 1'b1;

            for (wait_count = 0; wait_count < FRAME_WAIT_CLKS; wait_count = wait_count + 1) begin
                @(posedge clk);
                #1;

                if (data_valid === 1'b1) begin
                    error_count = error_count + 1;
                    $display("FAIL: false start generated data_valid. data_out=0x%02h wait_count=%0d",
                             data_out, wait_count);
                end
            end

            if (busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: DUT did not return to idle after false start. busy=%b", busy);
            end

            if (error_count == start_error_count) begin
                $display("PASS: test_false_start_ignored");
            end else begin
                $display("FAIL: test_false_start_ignored. new_errors=%0d",
                         error_count - start_error_count);
            end
        end
    endtask

    task test_invalid_stop_bit;
        integer wait_count;
        integer start_error_count;
        begin
            start_error_count = error_count;
            $display("Testing invalid stop bit: test_invalid_stop_bit");

            drive_uart_frame_bad_stop(8'h55);

            for (wait_count = 0; wait_count < FRAME_WAIT_CLKS; wait_count = wait_count + 1) begin
                @(posedge clk);
                #1;

                if (data_valid === 1'b1) begin
                    error_count = error_count + 1;
                    $display("FAIL: invalid stop bit generated data_valid. data_out=0x%02h wait_count=%0d",
                             data_out, wait_count);
                end
            end

            if (busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: DUT did not return to idle after invalid stop bit. busy=%b", busy);
            end

            if (error_count == start_error_count) begin
                $display("PASS: test_invalid_stop_bit");
            end else begin
                $display("FAIL: test_invalid_stop_bit. new_errors=%0d",
                         error_count - start_error_count);
            end
        end
    endtask

    task drive_uart_frame;
        input [7:0] send_data;
        integer bit_num;
        begin
            rx = 1'b1;
            repeat (2) @(posedge clk);

            @(negedge clk);
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            for (bit_num = 0; bit_num < 8; bit_num = bit_num + 1) begin
                @(negedge clk);
                rx = send_data[bit_num];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end

            @(negedge clk);
            rx = 1'b1;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    task drive_uart_frame_bad_stop;
        input [7:0] send_data;
        integer bit_num;
        begin
            rx = 1'b1;
            repeat (2) @(posedge clk);

            @(negedge clk);
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            for (bit_num = 0; bit_num < 8; bit_num = bit_num + 1) begin
                @(negedge clk);
                rx = send_data[bit_num];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end

            @(negedge clk);
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            @(negedge clk);
            rx = 1'b1;
        end
    endtask

    task check_busy_behavior;
        input [7:0] expected_data;
        integer wait_count;
        integer monitor_count;
        integer busy_error_seen;
        begin
            wait_count = 0;
            monitor_count = 0;
            busy_error_seen = 0;

            while ((busy !== 1'b1) && (wait_count < BUSY_WAIT_CLKS)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: busy did not assert after RX frame started. expected_data=0x%02h",
                         expected_data);
                $finish;
            end

            while ((data_valid !== 1'b1) && (monitor_count < FRAME_WAIT_CLKS)) begin
                @(posedge clk);
                #1;
                monitor_count = monitor_count + 1;

                if ((data_valid !== 1'b1) && (busy !== 1'b1) &&
                    (busy_error_seen == 0)) begin
                    busy_error_seen = 1;
                    error_count = error_count + 1;
                    $display("FAIL: busy deasserted before RX frame completed. expected_data=0x%02h monitor_count=%0d",
                             expected_data, monitor_count);
                end
            end

            if (data_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: data_valid did not assert during busy behavior check. expected_data=0x%02h",
                         expected_data);
                $finish;
            end

            @(posedge clk);
            #1;

            if (busy !== 1'b0) begin
                busy_error_seen = 1;
                error_count = error_count + 1;
                $display("FAIL: busy should be 0 after RX frame completion. expected_data=0x%02h busy=%b",
                         expected_data, busy);
            end

            if (busy_error_seen == 0) begin
                $display("PASS: busy behavior OK for RX byte 0x%02h.", expected_data);
            end
        end
    endtask

    task check_received_byte;
        input [7:0] expected_data;
        integer wait_count;
        begin
            wait_count = 0;

            while ((data_valid !== 1'b1) && (wait_count < FRAME_WAIT_CLKS)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (data_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: data_valid did not assert for expected byte 0x%02h.", expected_data);
                $finish;
            end

            if (data_out !== expected_data) begin
                error_count = error_count + 1;
                $display("FAIL: RX data mismatch. expected=0x%02h actual=0x%02h",
                         expected_data, data_out);
            end

            @(posedge clk);
            #1;

            if (data_valid !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL: data_valid should be a one-clock pulse.");
            end
        end
    endtask

endmodule
