`timescale 1ns / 1ps

module control_unit (
    input wire clk,
    input wire rst,
    input wire start,
    input wire convert,     // 0 = Binary to Gray, 1 = Gray to Binary
    
    output reg [2:0] bit_sel,
    output reg r1_out_en,
    output reg r2_write_en,
    output reg r3_load,
    output reg r4_load,
    output reg xor_out_en,
    output reg done
);

    parameter S_IDLE     = 4'd0;
    parameter S_MSB      = 4'd1; 
    parameter S_BRANCH   = 4'd2; 
    parameter S_B2G_R3   = 4'd3; 
    parameter S_LOAD_R4  = 4'd4; 
    parameter S_CALC_WR  = 4'd5; 
    parameter S_DEC      = 4'd6; 
    parameter S_DONE     = 4'd7; 

    reg [3:0] state, next_state;
    reg [2:0] bit_counter; 

    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else state <= next_state;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) bit_counter <= 3'd6;
        else if (state == S_IDLE) bit_counter <= 3'd6;
        else if (state == S_DEC && bit_counter != 0) bit_counter <= bit_counter - 1;
    end

    always @(*) begin
        case (state)
            S_IDLE:     next_state = start ? S_MSB : S_IDLE;
            S_MSB:      next_state = S_BRANCH;
            S_BRANCH:   next_state = convert ? S_LOAD_R4 : S_B2G_R3; 
            S_B2G_R3:   next_state = S_LOAD_R4;
            S_LOAD_R4:  next_state = S_CALC_WR;
            S_CALC_WR:  next_state = S_DEC;
            S_DEC:      next_state = (bit_counter == 0) ? S_DONE : S_BRANCH;
            S_DONE:     next_state = S_IDLE;
            default:    next_state = S_IDLE;
        endcase
    end

    always @(*) begin
        r1_out_en = 0; r2_write_en = 0;
        r3_load = 0; r4_load = 0; xor_out_en = 0;
        done = 0; bit_sel = 0;

        case (state)
            S_MSB: begin
                bit_sel = 3'd7;
                r1_out_en = 1;      
                r2_write_en = 1;    
                r3_load = 1;        
            end
            S_B2G_R3: begin
                bit_sel = bit_counter + 1; 
                r1_out_en = 1;
                r3_load = 1;
            end
            S_LOAD_R4: begin
                bit_sel = bit_counter;     
                r1_out_en = 1;
                r4_load = 1;
            end
            S_CALC_WR: begin
                bit_sel = bit_counter;
                xor_out_en = 1;
                r2_write_en = 1;    
                if (convert) r3_load = 1;    
            end
            S_DONE: done = 1;       
        endcase
    end
endmodule