module EMUL (
    input  wire                 clk             ,
    input  wire                 rst_n           ,
    input  wire                 stage_start     ,

    // in0_port
    input  wire                 a_tvalid        ,
    input  wire     [63:0]      a_tdata         ,

    // in1_port 
    input  wire                 b_tvalid        ,
    input  wire     [63:0]      b_tdata         ,

    // out_port
    output wire                 result_tvalid   ,
    output wire     [127:0]     result_tdata    
);

    reg             in0_mul_tvalid              ;
    reg     [63:0]  in0_mul_tdata               ;
    reg             in1_mul_tvalid              ;
    reg     [63:0]  in1_mul_tdata               ;

    wire            init_transfer               ;
    reg             init_txn_ff                 ;

    wire    [3:0]   individual_result_tvalid    ;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk or negedge rst_n)										      
        begin                                                                        
        // Initiates AXI transaction delay    
        if (!rst_n)                                                   
            begin                                                                    
            init_txn_ff <= 1'b0;                                                                                                 
            end                                                                               
        else                                                                       
            begin  
            init_txn_ff <= stage_start;                                                          
            end                                                                      
        end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            in0_mul_tvalid <= 1'b0;
            in0_mul_tdata  <= 128'd0;
            in1_mul_tvalid <= 1'b0;
            in1_mul_tdata  <= 128'd0;
        end 
        else begin
            if (stage_start) begin
                in0_mul_tvalid <= a_tvalid;
                in0_mul_tdata  <= a_tdata;
                in1_mul_tvalid <= b_tvalid;
                in1_mul_tdata  <= b_tdata;
            end
            else begin
                in0_mul_tvalid  <= in0_mul_tvalid;
                in0_mul_tdata   <= in0_mul_tdata ;
                in1_mul_tvalid  <= in1_mul_tvalid;
                in1_mul_tdata   <= in1_mul_tdata ;
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : eadd_array
            floating_mul emul_mul (
                .aclk                       (clk                                        ),
                .s_axis_a_tvalid            (in0_mul_tvalid                             ),
                .s_axis_a_tdata             ({in0_mul_tdata[((i<<4)+15) : i<<4], 16'b0} ),
                .s_axis_b_tvalid            (in1_mul_tvalid                             ),
                .s_axis_b_tdata             ({in1_mul_tdata[((i<<4)+15) : i<<4], 16'b0} ),
                .m_axis_result_tvalid       (individual_result_tvalid[i]                ),
                .m_axis_result_tdata        (result_tdata[((i<<5)+31) : i<<5]           ) 
            );
        end
    endgenerate

    assign result_tvalid = &individual_result_tvalid;

endmodule