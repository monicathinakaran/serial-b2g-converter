`timescale 1ns / 1ps

module b2g_top (
    input wire clk,
    input wire rst,
    input wire start,
    input wire convert,
    input wire [7:0] binary_in,
    output wire [7:0] gray_out,
    output wire done
);

    wire [2:0] bit_sel;
    wire r1_out_en, r2_write_en, r3_load, r4_load, xor_out_en;

    control_unit cu (
        .clk(clk),
        .rst(rst),
        .start(start),
        .convert(convert),
        .bit_sel(bit_sel),
        .r1_out_en(r1_out_en),
        .r2_write_en(r2_write_en),
        .r3_load(r3_load),
        .r4_load(r4_load),
        .xor_out_en(xor_out_en),
        .done(done)
    );

    datapath dp (
        .clk(clk),
        .rst(rst),
        .bit_sel(bit_sel),
        .r1_out_en(r1_out_en),
        .r2_write_en(r2_write_en),
        .r3_load(r3_load),
        .r4_load(r4_load),
        .xor_out_en(xor_out_en),
        .data_in(binary_in),
        .r1_load_ext(start),
        .gray_data(gray_out)
    );

endmodule