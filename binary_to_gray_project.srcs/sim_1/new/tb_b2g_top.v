`timescale 1ns / 1ps

module tb_b2g_top;

    reg clk, rst, start, convert;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire done;

    reg [7:0] expected_data;
    integer i, b2g_errors, g2b_errors;

    b2g_top dut (
        .clk(clk), .rst(rst), .start(start), .convert(convert),
        .binary_in(data_in), .gray_out(data_out), .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // GOLDEN MODEL 1: Binary to Gray
    function [7:0] calc_gray;
        input [7:0] bin;
        begin
            calc_gray = (bin >> 1) ^ bin;
        end
    endfunction

    // GOLDEN MODEL 2: Gray to Binary
    function [7:0] calc_binary;
        input [7:0] gray;
        integer k;
        begin
            calc_binary[7] = gray[7];
            for (k = 6; k >= 0; k = k - 1) begin
                calc_binary[k] = calc_binary[k+1] ^ gray[k];
            end
        end
    endfunction

    initial begin
        rst = 1; start = 0; convert = 0; data_in = 0; 
        b2g_errors = 0; g2b_errors = 0;
        #20 rst = 0;

        // TEST PHASE 1: Binary to Gray
        $display("--- Starting Binary to Gray Verification ---");
        convert = 0;
        for (i = 0; i < 1000; i = i + 1) begin
            data_in = $random;
            expected_data = calc_gray(data_in);

            @(posedge clk); start = 1;
            @(posedge clk); start = 0;
            wait(done); @(posedge clk);

            if (data_out !== expected_data) b2g_errors = b2g_errors + 1;
        end
        if (b2g_errors == 0) $display("[PASS] 1000 B2G Vectors verified!");
        else $display("[FAIL] %d B2G errors found.", b2g_errors);

        // TEST PHASE 2: Gray to Binary
        $display("--- Starting Gray to Binary Verification ---");
        convert = 1; 
        for (i = 0; i < 1000; i = i + 1) begin
            data_in = $random;
            expected_data = calc_binary(data_in);

            @(posedge clk); start = 1;
            @(posedge clk); start = 0;
            wait(done); @(posedge clk);

            if (data_out !== expected_data) g2b_errors = g2b_errors + 1;
        end
        if (g2b_errors == 0) $display("[PASS] 1000 G2B Vectors verified!");
        else $display("[FAIL] %d G2B errors found.", g2b_errors);

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule