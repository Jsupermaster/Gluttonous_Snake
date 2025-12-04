// A basic block has four ports: East, West, South, and North.
// The East and West ports are unidirectional. The East port is used only for data input, while the West port is used only for data output.
// The South and North ports are bidirectional, with each supporting both input and output.s
// The block can be configured into one of 7 operational modes: ADD, MUL, SQUARE, EXP, REC, RSR or LN.
// The block_en signal indicates whether the incoming data should be processed by this block. If enabled (block_en=1), the computation is performed; if not, the data is bypassed and output after a two-cycle delay.
// The input_sel signal (3-bit one-hot encoded) selects the data source: 001 for East, 010 for North, and 100 for South.
// The output_sel signal (3-bit one-hot encoded) selects the data destination: 001 for West, 010 for North, and 100 for South.
// The "output_sel" can be used to specify the output ports for the valid data. The three digits represent three ports. If it is 1, the valid signal is output; if it is 0, the input signal delayed by two periods is output. 
// For example, 110 means that the north and south ports output the valid signal, and the west port outputs the delayed input signal.
module basic_block_x4 #(
    parameter                   pattern = "ADD"
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input                       block_en            ,
    input           [2:0]       input_sel_a         ,
    input           [2:0]       input_sel_b         ,
    input           [2:0]       output_sel          ,

    // data signals
    input                       east_in_tvalid      ,
    input           [127:0]     east_in_tdata       ,

    output  reg                 west_out_tvalid     ,
    output  reg     [127:0]     west_out_tdata      ,

    input                       north_in_tvalid     ,
    input           [127:0]     north_in_tdata      ,
    output  reg                 north_out_tvalid    ,
    output  reg     [127:0]     north_out_tdata     ,

    input                       south_in_tvalid     ,
    input           [127:0]     south_in_tdata      ,
    output  reg                 south_out_tvalid    ,
    output  reg     [127:0]     south_out_tdata     
);

    reg     [127:0]     input_atdata     ;
    reg                 input_atvalid    ;
    reg     [127:0]     input_btdata     ;
    reg                 input_btvalid    ;

    wire    [127:0]     result_tdata     ;
    wire    [3 : 0]     result_tvalid    ;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_atdata <= 128'b0;
            input_atvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                case (input_sel_a)
                    3'b001: begin // east
                        input_atdata  <= east_in_tdata;
                        input_atvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_atdata  <= north_in_tdata;
                        input_atvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_atdata  <= south_in_tdata;
                        input_atvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_atdata <= 128'b0;
                        input_atvalid <= 1'b0;
                    end
                endcase
            end
            else begin
                input_atdata <= 128'b0;
                input_atvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_btdata <= 128'b0;
            input_btvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                case (input_sel_b)
                    3'b001: begin // east
                        input_btdata  <= east_in_tdata;
                        input_btvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_btdata  <= north_in_tdata;
                        input_btvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_btdata  <= south_in_tdata;
                        input_btvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_btdata <= 128'b0;
                        input_btvalid <= 1'b0;
                    end
                endcase
            end
            else begin
                input_btdata <= 128'b0;
                input_btvalid <= 1'b0;
            end
        end
    end

    genvar i;
    generate
        case(pattern)
            "ADD" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_add_array
                    floating_add block_add (
                        .aclk                       (clk                                ),             
                        .s_axis_a_tvalid            (input_atvalid                      ),        
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]   ),         
                        .s_axis_b_tvalid            (input_btvalid                      ),        
                        .s_axis_b_tdata             (input_btdata[((i<<5)+31) : i<<5]   ),         
                        .m_axis_result_tvalid       (result_tvalid[i]                   ),   
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]   )     
                    );
                end
            end
            
            "MUL" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_mul_array
                    floating_mul block_mul (
                        .aclk                       (clk                                    ), 
                        .s_axis_a_tvalid            (input_atvalid                          ), 
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ), 
                        .s_axis_b_tvalid            (input_btvalid                          ), 
                        .s_axis_b_tdata             (input_btdata[((i<<5)+31) : i<<5]       ), 
                        .m_axis_result_tvalid       (result_tvalid[i]                       ), 
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       )  
                    );
                end
            end

            "SQUARE" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_squ_array
                    floating_mul block_squ (
                        .aclk                       (clk                                    ), 
                        .s_axis_a_tvalid            (input_atvalid                          ), 
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ), 
                        .s_axis_b_tvalid            (input_atvalid                          ), 
                        .s_axis_b_tdata             (input_atdata[((i<<5)+31) : i<<5]       ), 
                        .m_axis_result_tvalid       (result_tvalid[i]                       ), 
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       )  
                    );
                end
            end

            "EXP" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_exp_array
                    floating_exp block_exp (
                        .aclk                       (clk                                    ),
                        .s_axis_a_tvalid            (input_atvalid                          ),
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ),
                        .m_axis_result_tvalid       (result_tvalid[i]                       ),
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       ) 
                    );
                end
            end

            "REC" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_rec_array
                wire    [63:0]      result_tdata_fp16;
                wire    [3:0]       result_tvalid_fp16;
                wire    [63:0]      result_tdata_fp32_16;
                wire    [3:0]       result_tvalid_fp32_16;
                    fp32_2_fp16 rec_fp32_2_fp16 (
                        .aclk                       (clk                                        ),                                
                        .s_axis_a_tvalid            (input_atvalid                              ),          
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]           ),            
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
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]           )  
                    );
                end
            end

            "RSR" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_rsr_array
                    floating_rsr block_rsr (
                        .aclk                       (clk                                    ),
                        .s_axis_a_tvalid            (input_atvalid                          ),
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ),
                        .m_axis_result_tvalid       (result_tvalid[i]                       ),
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       ) 
                    );
                end
            end
            
            "LN" : begin
                for (i = 0; i < 4; i = i + 1) begin : block_ln_array
                    floating_ln block_ln (
                        .aclk                       (clk                                    ),
                        .s_axis_a_tvalid            (input_atvalid                          ),
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ),
                        .m_axis_result_tvalid       (result_tvalid[i]                       ),
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       ) 
                    );
                end
            end
            
            default : begin
                for (i = 0; i < 4; i = i + 1) begin : block_add_array
                    floating_add block_add (
                        .aclk                       (clk                                    ),             
                        .s_axis_a_tvalid            (input_atvalid                          ),        
                        .s_axis_a_tdata             (input_atdata[((i<<5)+31) : i<<5]       ),         
                        .s_axis_b_tvalid            (input_btvalid                          ),        
                        .s_axis_b_tdata             (input_btdata[((i<<5)+31) : i<<5]       ),         
                        .m_axis_result_tvalid       (result_tvalid[i]                       ),   
                        .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]       )     
                    );
                end
            end
        endcase
    endgenerate

    // Finally, we need to determine the destination of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            west_out_tdata   <= 128'b0;
            west_out_tvalid  <= 1'b0;
            // north_out_tdata  <= 128'b0;
            // north_out_tvalid <= 1'b0;
            // south_out_tdata  <= 128'b0;
            // south_out_tvalid <= 1'b0;
        end
        else begin
            if(stage_start && block_en) begin
                west_out_tdata   <= output_sel[0] ?  result_tdata  : input_atdata    ;
                west_out_tvalid  <= output_sel[0] ? &result_tvalid : input_atvalid   ;
                // north_out_tdata  <= output_sel[1] ?  result_tdata  : input_atdata    ;
                // north_out_tvalid <= output_sel[1] ? &result_tvalid : input_atvalid   ;
                // south_out_tdata  <= output_sel[2] ?  result_tdata  : input_atdata    ;
                // south_out_tvalid <= output_sel[2] ? &result_tvalid : input_atvalid   ;
            end
            else if(stage_start && ~block_en)begin
                west_out_tdata   <= input_atdata    ;
                west_out_tvalid  <= input_atvalid   ;
                // north_out_tdata  <= input_atdata    ;
                // north_out_tvalid <= input_atvalid   ;
                // south_out_tdata  <= input_atdata    ;
                // south_out_tvalid <= input_atvalid   ;
            end
            else begin
                west_out_tdata   <= 128'b0;
                west_out_tvalid  <= 1'b0;
                // north_out_tdata  <= 128'b0;
                // north_out_tvalid <= 1'b0;
                // south_out_tdata  <= 128'b0;
                // south_out_tvalid <= 1'b0;
            end
        end
    end

endmodule