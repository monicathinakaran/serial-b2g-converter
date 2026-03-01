`timescale 1ns / 1ps

module datapath (
    input wire clk,
    input wire rst,
    input wire [2:0] bit_sel,      
    input wire r1_out_en,          
    input wire r2_write_en,        
    input wire r3_load,            
    input wire r4_load,            
    input wire xor_out_en,         
    input wire [7:0] data_in,      
    input wire r1_load_ext,        
    output wire [7:0] gray_data    
);

    reg [7:0] R1; // Binary Storage
    reg [7:0] R2; // Gray Storage
    reg R3;       // XOR Operand 1
    reg R4;       // XOR Operand 2

    wire one_bit_bus; // Shared Interconnect

    // R1 Logic (PIPO with MUX)
    always @(posedge clk or posedge rst) begin
        if (rst) R1 <= 8'b0;
        else if (r1_load_ext) R1 <= data_in; 
    end

    wire r1_selected_bit = R1[bit_sel];
    assign one_bit_bus = (r1_out_en) ? r1_selected_bit : 1'bz;

    // R3 & R4 Logic
    always @(posedge clk or posedge rst) begin
        if (rst) R3 <= 1'b0;
        else if (r3_load) R3 <= one_bit_bus; 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) R4 <= 1'b0;
        else if (r4_load) R4 <= one_bit_bus; 
    end

    // ALU (Single XOR Gate)
    wire xor_result = R3 ^ R4;
    assign one_bit_bus = (xor_out_en) ? xor_result : 1'bz;

    // R2 Logic (PIPO with DEMUX) - FIXED FOR VIVADO SIMULATION
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R2 <= 8'b0; 
        end else if (r2_write_en) begin
            // Direct dynamic indexing prevents the Vivado latching issue
            R2[bit_sel] <= one_bit_bus;
        end
    end

    assign gray_data = R2;

endmodule
