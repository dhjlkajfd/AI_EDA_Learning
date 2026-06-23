`timescale 1ns / 1ps

module tb_uart_tx;

    parameter CLK_FREQ     = 50000000;
    parameter BAUD_RATE    = 115200;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    parameter CLK_PERIOD   = 20;
    parameter FRAME_CLKS   = 10 * CLKS_PER_BIT;
    parameter FRAME_TOL    = 2;

    parameter GLOBAL_TIMEOUT_CLKS = (FRAME_CLKS * 8) + 1000;
    parameter START_TIMEOUT_CLKS  = CLKS_PER_BIT + 20;
    parameter BUSY_TIMEOUT_CLKS   = FRAME_CLKS + 20;

    reg        clk;
    reg        rst_n;
    reg [7:0]  data_in;
    reg        data_valid;
    wire       tx;
    wire       busy;

    integer error_count;
    integer clk_count;
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
        clk_count = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    always @(posedge clk) begin
        clk_count = clk_count + 1;
    end

    initial begin
        repeat (GLOBAL_TIMEOUT_CLKS) @(posedge clk);
        $display("FAIL/TIMEOUT: Global simulation timeout at time %0t.", $time);
        $finish;
    end

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        error_count = 0;
        rst_n = 1'b0;
        data_in = 8'd0;
        data_valid = 1'b0;

        repeat (10) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        repeat (10) @(posedge clk);

        run_uart_test(8'h55);
        run_uart_test(8'hA5);
        run_uart_test(8'h00);
        run_uart_test(8'hFF);
        test_ignore_valid_when_busy;

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

    task test_ignore_valid_when_busy;
        integer start_error_count;
        begin
            start_error_count = error_count;
            $display("Testing handshake: test_ignore_valid_when_busy");

            fork
                send_byte_with_busy_valid_inject(8'h55, 8'hA3);
                check_uart_frame(8'h55);
            join

            run_uart_test(8'hA3);

            if (error_count == start_error_count) begin
                $display("PASS: test_ignore_valid_when_busy");
            end else begin
                $display("FAIL: test_ignore_valid_when_busy. new_errors=%0d",
                         error_count - start_error_count);
            end
        end
    endtask

    task send_byte;
        input [7:0] send_data;
        integer start_cycle;
        integer end_cycle;
        integer actual_cycles;
        begin
            wait_for_busy_low(BUSY_TIMEOUT_CLKS);

            @(negedge clk);
            data_in = send_data;
            data_valid = 1'b1;

            wait_for_busy_high(START_TIMEOUT_CLKS);
            start_cycle = clk_count;
            data_valid = 1'b0;
            data_in = 8'd0;

            while ((busy === 1'b1) &&
                   ((clk_count - start_cycle) <= BUSY_TIMEOUT_CLKS)) begin
                @(posedge clk);
                #1;
            end

            if (busy === 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: busy did not deassert after %0d clocks.", BUSY_TIMEOUT_CLKS);
                $finish;
            end

            if (busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("ERROR: busy should be 0 after transmission, got %b.", busy);
            end

            end_cycle = clk_count;
            actual_cycles = end_cycle - start_cycle;

            if ((actual_cycles < (FRAME_CLKS - FRAME_TOL)) ||
                (actual_cycles > (FRAME_CLKS + FRAME_TOL))) begin
                error_count = error_count + 1;
                $display("FAIL: UART frame duration mismatch. expected_cycles=%0d actual_cycles=%0d tolerance=%0d start_cycle=%0d end_cycle=%0d",
                         FRAME_CLKS, actual_cycles, FRAME_TOL, start_cycle, end_cycle);
            end else begin
                $display("PASS: UART frame duration OK. expected_cycles=%0d actual_cycles=%0d",
                         FRAME_CLKS, actual_cycles);
            end

            repeat (5) @(posedge clk);
        end
    endtask

    task send_byte_with_busy_valid_inject;
        input [7:0] first_data;
        input [7:0] injected_data;
        integer start_cycle;
        integer end_cycle;
        integer actual_cycles;
        integer idle_check_count;
        begin
            wait_for_busy_low(BUSY_TIMEOUT_CLKS);

            @(negedge clk);
            data_in = first_data;
            data_valid = 1'b1;

            wait_for_busy_high(START_TIMEOUT_CLKS);
            start_cycle = clk_count;
            data_valid = 1'b0;
            data_in = 8'd0;

            repeat (CLKS_PER_BIT / 4) @(posedge clk);
            #1;

            if (busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: busy should remain 1 before injected data_valid, got %b.", busy);
            end

            @(negedge clk);
            data_in = injected_data;
            data_valid = 1'b1;

            @(posedge clk);
            #1;

            if (busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL: busy should remain 1 during injected data_valid, got %b.", busy);
            end

            @(negedge clk);
            data_valid = 1'b0;
            data_in = 8'd0;

            while ((busy === 1'b1) &&
                   ((clk_count - start_cycle) <= BUSY_TIMEOUT_CLKS)) begin
                @(posedge clk);
                #1;
            end

            if (busy === 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: busy did not deassert after injected request test.");
                $finish;
            end

            end_cycle = clk_count;
            actual_cycles = end_cycle - start_cycle;

            if ((actual_cycles < (FRAME_CLKS - FRAME_TOL)) ||
                (actual_cycles > (FRAME_CLKS + FRAME_TOL))) begin
                error_count = error_count + 1;
                $display("FAIL: busy-period data_valid affected frame duration. expected_cycles=%0d actual_cycles=%0d",
                         FRAME_CLKS, actual_cycles);
            end else begin
                $display("PASS: busy-period data_valid ignored by duration check. expected_cycles=%0d actual_cycles=%0d",
                         FRAME_CLKS, actual_cycles);
            end

            for (idle_check_count = 0; idle_check_count < 5; idle_check_count = idle_check_count + 1) begin
                @(posedge clk);
                #1;

                if (busy !== 1'b0) begin
                    error_count = error_count + 1;
                    $display("FAIL: busy-period data_valid was not ignored; unexpected busy after frame completion.");
                end
            end
        end
    endtask

    task check_uart_frame;
        input [7:0] expected_data;
        begin
            wait_for_start_bit(START_TIMEOUT_CLKS);

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

    task wait_for_busy_low;
        input integer max_cycles;
        integer wait_count;
        begin
            wait_count = 0;

            while ((busy !== 1'b0) && (wait_count < max_cycles)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (busy !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: busy did not become 0 within %0d clocks.", max_cycles);
                $finish;
            end
        end
    endtask

    task wait_for_busy_high;
        input integer max_cycles;
        integer wait_count;
        begin
            wait_count = 0;

            while ((busy !== 1'b1) && (wait_count < max_cycles)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (busy !== 1'b1) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: busy did not assert within %0d clocks.", max_cycles);
                $finish;
            end
        end
    endtask

    task wait_for_start_bit;
        input integer max_cycles;
        integer wait_count;
        begin
            wait_count = 0;

            while ((tx !== 1'b0) && (wait_count < max_cycles)) begin
                @(posedge clk);
                #1;
                wait_count = wait_count + 1;
            end

            if (tx !== 1'b0) begin
                error_count = error_count + 1;
                $display("FAIL/TIMEOUT: start bit did not appear within %0d clocks.", max_cycles);
                $finish;
            end
        end
    endtask

endmodule
