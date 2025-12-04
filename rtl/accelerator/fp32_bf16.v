`timescale 1ns / 1ps
module FP32_2_BF16 (
    input   wire [31:0]     fp32_in      ,
    output  wire [15:0]     bf16_out      
);

    wire fp32_sign = fp32_in[31];
    wire [7:0] fp32_exp = fp32_in[30:23];
    wire [22:0] fp32_frac = fp32_in[22:0];
    
    wire fp32_is_nan = (fp32_exp == 8'hFF) && (fp32_frac != 0);
    wire fp32_is_inf = (fp32_exp == 8'hFF) && (fp32_frac == 0);
    wire fp32_is_zero = (fp32_exp == 0) && (fp32_frac == 0);
    wire fp32_is_denormal = (fp32_exp == 0) && (fp32_frac != 0);
    
    wire [15:0] special_case_bf16;
    assign special_case_bf16 = 
        fp32_is_nan ? {fp32_sign, 8'hFF, 7'h7F} : 
        fp32_is_inf ? {fp32_sign, 8'hFF, 7'h00} : 
        fp32_is_zero ? {fp32_sign, 8'h00, 7'h00} :
        {fp32_sign, 8'h00, 7'h00};                

    wire [7:0] bf16_exp;
    wire [6:0] bf16_frac;
    wire normal_overflow, normal_underflow;
    
    assign bf16_exp = fp32_exp;
    
    wire [22:0] frac_extended = {1'b1, fp32_frac}; 
    wire guard_bit = frac_extended[15];            
    wire round_bit = frac_extended[14];            
    wire sticky_bit = |frac_extended[13:0];        
    
    wire [6:0] truncated_frac = frac_extended[22:16];
    
    wire round_up;
    assign round_up = 
        (guard_bit & round_bit) |                   
        (guard_bit & ~round_bit & sticky_bit) |     
        (guard_bit & ~round_bit & ~sticky_bit & truncated_frac[0]);
    
    wire [7:0] rounded_frac_extended = {1'b0, truncated_frac} + round_up;
    wire frac_overflow = rounded_frac_extended[7];
    
    wire [7:0] final_exp = bf16_exp + frac_overflow;
    wire [6:0] final_frac = rounded_frac_extended[6:0];
    
    assign normal_overflow = (fp32_exp > 8'hFE) || 
                           (final_exp == 8'hFF && !fp32_is_inf && !fp32_is_nan);
    assign normal_underflow = (fp32_exp < 8'h01) && (fp32_exp != 0);
    
    wire [15:0] normal_bf16 = 
        normal_overflow ? {fp32_sign, 8'hFF, 7'h00} : 
        normal_underflow ? {fp32_sign, 8'h00, 7'h00} :
        {fp32_sign, final_exp, final_frac};
    
    assign bf16_out = 
        (fp32_is_nan | fp32_is_inf | fp32_is_zero | fp32_is_denormal) ? 
        special_case_bf16 : normal_bf16;

endmodule
