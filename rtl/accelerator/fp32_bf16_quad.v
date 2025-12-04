`timescale 1ns / 1ps
module FP32_2_BF16_QUAD (
    input   wire [255:0]     fp32_in      ,
    output  wire [127:0]     bf16_out      
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : ACC_FP32_2_BF16_array
            FP32_2_BF16 ACC_FP32_2_BF16(
                .fp32_in      (fp32_in[((i<<5)+31) : i<<5]      ),
                .bf16_out     (bf16_out[((i<<4)+15) : i<<4]     ) 
            );
        end
    endgenerate

endmodule
