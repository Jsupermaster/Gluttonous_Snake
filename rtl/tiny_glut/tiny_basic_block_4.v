module tiny_basic_block_x4 #(
    parameter                   pattern = "ADD"
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input                       block_en            ,

    // data signals
    input                       east_in_tvalid      ,
    input           [63:0]      east_in_tdata       ,

    input                       north_in_tvalid     ,
    input           [63:0]      north_in_tdata      ,

    output  reg                 west_out_tvalid     ,
    output  reg     [63:0]      west_out_tdata      
);

    reg     [63:0]      input_atdata     ;
    reg                 input_atvalid    ;
    reg     [63:0]      input_btdata     ;
    reg                 input_btvalid    ;

    wire    [127:0]     result_tdata_fp32;
    wire    [63:0]      result_tdata_fp16;
    wire    [3:0]       result_tvalid_fp16;
    wire    [63:0]      result_tdata_fp32_16;
    wire    [3:0]       result_tvalid_fp32_16;
    wire    [63:0]      result_tdata_bf16;
    wire    [3 : 0]     result_tvalid    ;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_atdata <= 64'b0;
            input_atvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                input_atdata  <= east_in_tdata;
                input_atvalid <= east_in_tvalid;
            end
            else begin
                input_atdata <= 64'b0;
                input_atvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_btdata <= 64'b0;
            input_btvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                input_btdata  <= north_in_tdata     ;
                input_btvalid <= north_in_tvalid    ;
            end
            else begin
                input_btdata <= 64'b0;
                input_btvalid <= 1'b0;
            end
        end
    end

    genvar i;
    generate
        case(pattern)
            "ADD" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_add_array
                    fadd_bf16 block_add(
                        .clk              (clk                                      ),
                        .rst_n            (rst_n                                    ),
                        .a          (input_atdata[((i<<4)+15) : i<<4]         ),
                        .a_tvalid         (input_atvalid                            ),
                        .b         (input_btdata[((i<<4)+15) : i<<4]         ),
                        .b_tvalid         (input_btvalid                            ),
                        .y     (result_tdata_bf16[((i<<4)+15) : i<<4]    ), 
                        .result_tvalid    (result_tvalid[i]                         )
                    );
                end
            end
            
            "MUL" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_mul_array
                    fmul_bf16 block_mul(
                        .clk                (clk                                    ),
                        .atdata             (input_atdata[((i<<4)+15) : i<<4]       ),
                        .a_tvalid           (input_atvalid                          ),
                        .btdata             (input_btdata[((i<<4)+15) : i<<4]       ),
                        .b_tvalid           (input_btvalid                          ),
                        .result_tdata       (result_tdata_bf16[((i<<4)+15) : i<<4]  ),
                        .result_tvalid      (result_tvalid[i]                       )
                    );
                end
            end

            "SQUARE" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_squ_array
                    fmul_bf16 block_mul(
                        .clk                (clk                                    ),
                        .atdata             (input_atdata[((i<<4)+15) : i<<4]       ),
                        .a_tvalid           (input_atvalid                          ),
                        .btdata             (input_atdata[((i<<4)+15) : i<<4]       ),
                        .b_tvalid           (input_atvalid                          ),
                        .result_tdata       (result_tdata_bf16[((i<<4)+15) : i<<4]  ),
                        .result_tvalid      (result_tvalid[i]                       )
                    );
                end
            end

            "EXP" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_exp_array
                    fp32_2_fp16 exp_fp32_2_fp16 (
                        .aclk                       (clk                                        ),                                
                        .s_axis_a_tvalid            (input_atvalid                              ),          
                        .s_axis_a_tdata             ({input_atdata[((i<<4)+15) : i<<4], 16'b0}  ),            
                        .m_axis_result_tvalid       (result_tvalid_fp32_16[i]                   ),
                        .m_axis_result_tdata        (result_tdata_fp32_16[((i<<4)+15) : i<<4]   )   
                    );
                    floating_exp_fp16 block_exp (
                        .aclk                       (clk                                        ),
                        .s_axis_a_tvalid            (&result_tvalid_fp32_16[i]                  ),
                        .s_axis_a_tdata             (result_tdata_fp32_16[((i<<4)+15) : i<<4]   ),
                        .m_axis_result_tvalid       (result_tvalid_fp16[i]                      ),
                        .m_axis_result_tdata        (result_tdata_fp16[((i<<4)+15) : i<<4]      ) 
                    );
                    fp16_2_fp32 exp_fp16_2_fp32 (
                        .aclk                       (clk                                        ),                
                        .s_axis_a_tvalid            (&result_tvalid_fp16[i]                     ),     
                        .s_axis_a_tdata             (result_tdata_fp16[((i<<4)+15) : i<<4]      ),      
                        .m_axis_result_tvalid       (result_tvalid[i]                           ),
                        .m_axis_result_tdata        (result_tdata_fp32[((i<<5)+31) : i<<5]      )  
                    );
                    FP32_2_BF16 EXP_FP32_2_BF16(
                        .fp32_in                    (result_tdata_fp32[((i<<5)+31) : i<<5]      ),
                        .bf16_out                   (result_tdata_bf16[((i<<4)+15) : i<<4]      ) 
                    );
                end
            end

            "REC" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_rec_array
                    fp32_2_fp16 rec_fp32_2_fp16 (
                        .aclk                       (clk                                        ),                                
                        .s_axis_a_tvalid            (input_atvalid                              ),          
                        .s_axis_a_tdata             ({input_atdata[((i<<4)+15) : i<<4], 16'b0}  ),            
                        .m_axis_result_tvalid       (result_tvalid_fp32_16[i]                   ),
                        .m_axis_result_tdata        (result_tdata_fp32_16[((i<<4)+15) : i<<4]   )   
                    );
                    floating_rec block_rec (
                        .aclk                       (clk                                        ),
                        .s_axis_a_tvalid            (&result_tvalid_fp32_16[i]                  ),
                        .s_axis_a_tdata             (result_tdata_fp32_16[((i<<4)+15) : i<<4]   ),
                        .m_axis_result_tvalid       (result_tvalid_fp16[i]                      ),
                        .m_axis_result_tdata        (result_tdata_fp16[((i<<4)+15) : i<<4]      ) 
                    );
                    fp16_2_fp32 rec_fp16_2_fp32 (
                        .aclk                       (clk                                        ),                
                        .s_axis_a_tvalid            (&result_tvalid_fp16[i]                     ),     
                        .s_axis_a_tdata             (result_tdata_fp16[((i<<4)+15) : i<<4]      ),      
                        .m_axis_result_tvalid       (result_tvalid[i]                           ),
                        .m_axis_result_tdata        (result_tdata_fp32[((i<<5)+31) : i<<5]      )  
                    );
                    FP32_2_BF16 REC_FP32_2_BF16(
                        .fp32_in                    (result_tdata_fp32[((i<<5)+31) : i<<5]      ),
                        .bf16_out                   (result_tdata_bf16[((i<<4)+15) : i<<4]      ) 
                    );
                end
            end

            "RSR" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_rsr_array
                    floating_rsr block_rsr (
                        .aclk                       (clk                                        ),
                        .s_axis_a_tvalid            (input_atvalid                              ),
                        .s_axis_a_tdata             ({input_atdata[((i<<4)+15) : i<<4], 16'b0}  ),
                        .m_axis_result_tvalid       (result_tvalid[i]                           ),
                        .m_axis_result_tdata        (result_tdata_fp32[((i<<5)+31) : i<<5]      ) 
                    );
                    FP32_2_BF16 RSR_FP32_2_BF16(
                        .fp32_in      (result_tdata_fp32[((i<<5)+31) : i<<5]        ),
                        .bf16_out     (result_tdata_bf16[((i<<4)+15) : i<<4]        ) 
                    );
                end
            end
            
            "LN" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_ln_array
                    floating_ln block_ln (
                        .aclk                       (clk                                        ),
                        .s_axis_a_tvalid            (input_atvalid                              ),
                        .s_axis_a_tdata             ({input_atdata[((i<<4)+15) : i<<4], 16'b0}  ),
                        .m_axis_result_tvalid       (result_tvalid[i]                           ),
                        .m_axis_result_tdata        (result_tdata_fp32[((i<<5)+31) : i<<5]      ) 
                    );
                    FP32_2_BF16 LN_FP32_2_BF16(
                        .fp32_in      (result_tdata_fp32[((i<<5)+31) : i<<5]        ),
                        .bf16_out     (result_tdata_bf16[((i<<4)+15) : i<<4]        ) 
                    );
                end
            end
            
            default : begin
                for (i = 0; i < 4; i = i + 1) begin : block_add_array
                    fadd_bf16 block_add(
                        .clk              (clk                                      ),
                        .rst_n            (rst_n                                    ),
                        .a          (input_atdata[((i<<4)+15) : i<<4]         ),
                        .a_tvalid         (input_atvalid                            ),
                        .b         (input_btdata[((i<<4)+15) : i<<4]         ),
                        .b_tvalid         (input_btvalid                            ),
                        .y     (result_tdata_bf16[((i<<4)+15) : i<<4]    ), 
                        .result_tvalid    (result_tvalid[i]                         )
                    );
                end
            end
        endcase
    endgenerate

    // Finally, we need to determine the destination of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            west_out_tdata   <= 64'b0;
            west_out_tvalid  <= 1'b0;
        end
        else begin
            if(stage_start && block_en) begin
                west_out_tdata   <=  result_tdata_bf16  ;
                west_out_tvalid  <= &result_tvalid      ;
            end
            else if(stage_start && ~block_en)begin
                west_out_tdata   <= input_atdata    ;
                west_out_tvalid  <= input_atvalid   ;
            end
            else begin
                west_out_tdata   <= 64'b0;
                west_out_tvalid  <= 1'b0;
            end
        end
    end

endmodule