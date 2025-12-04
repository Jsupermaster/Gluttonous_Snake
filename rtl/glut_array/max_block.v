// A max block has two ports: Input and Output(West and South, controling throuth output_sel, 01 is West and 10 is South).
// The block_en signal indicates whether the incoming data should be processed by this block. If enabled (block_en=1), the computation is performed; if not, the data is bypassed and output after a two-cycle delay.
module max_block #(
    parameter                   DATA_NUM = 10'd192
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input                       block_en            ,
    input           [1:0]       output_sel          ,

    // data signals
    input                       input_atvalid       ,
    input           [127:0]     input_atdata        ,

    output  reg                 west_output_atvalid ,
    output  reg     [127:0]     west_output_atdata  , 
    output  reg                 south_output_atvalid,
    output  reg     [127:0]     south_output_atdata       
);
    wire                        init_transfer       ;
    reg                         init_txn_ff         ;

    reg             [9:0]       input_cnt           ;
    reg                         input_tvalid        ;
    reg             [127:0]     input_tdata         ;
    wire            [31:0]      max_tdata           ;
    wire                        max_tvalid          ;
    reg                         max_en              ;
    reg             [9:0]       max_cnt             ;
    reg             [31:0]      max_tdata_out       ;

    always @(posedge clk) begin                                                                          
        if (!rst_n) begin                                                                    
            init_txn_ff <= 1'b0;                                                                                                 
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
    end

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk) begin
        if(!rst_n) begin
            input_tdata <= 128'b0;
            input_tvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                input_tdata  <= input_atdata;
                input_tvalid <= input_atvalid;
            end
            else begin
                input_tdata <= 128'b0;
                input_tvalid <= 1'b0;
            end
        end
    end

    compare_array block_compare_array (
        .clk                    (clk            ),
        .init_transfer          (init_transfer  ),
        .rst_n                  (rst_n          ),
        .a_tvalid               (input_tvalid   ),
        .a_tdata                (input_tdata    ),
        .result_tvalid          (max_tvalid     ),
        .result_tdata           (max_tdata      )
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            max_en <= 1'b0;
        else if (max_tvalid)
            max_en <= 1'b1;
        else if ((max_cnt == DATA_NUM - 10'd1)&&(max_tvalid == 1'b0))
            max_en <= 1'b0;
        else
            max_en <= max_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            max_cnt <= 10'd0;
        else if (max_cnt == DATA_NUM - 10'd1)
            max_cnt <= 10'd0;
        else if (max_en) 
            max_cnt <= max_cnt + 10'd1;
        else
            max_cnt <= max_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            max_tdata_out <= 32'h0;
        else if (max_tvalid)
            max_tdata_out <= max_tdata;
        else
            max_tdata_out <= max_tdata_out;
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            west_output_atvalid  <= 1'b0;
            west_output_atdata   <= 128'b0;
            south_output_atvalid <= 1'b0;
            south_output_atdata  <= 128'b0;
        end
        else begin
            if(stage_start && block_en) begin
                case(output_sel)
                    2'b01: begin
                        west_output_atvalid         <= max_en          ;
                        west_output_atdata          <= {max_tdata_out, max_tdata_out, max_tdata_out, max_tdata_out}   ;
                        south_output_atvalid        <= input_tvalid    ;
                        south_output_atdata         <= input_tdata     ;
                    end
                    2'b10: begin
                        west_output_atvalid         <= input_tvalid    ;
                        west_output_atdata          <= input_tdata     ;
                        south_output_atvalid        <= max_en          ;
                        south_output_atdata         <= {max_tdata_out, max_tdata_out, max_tdata_out, max_tdata_out}   ;
                    end
                    2'b11: begin
                        west_output_atvalid         <= max_en          ;
                        west_output_atdata          <= {max_tdata_out, max_tdata_out, max_tdata_out, max_tdata_out}   ;
                        south_output_atvalid        <= max_en          ;
                        south_output_atdata         <= {max_tdata_out, max_tdata_out, max_tdata_out, max_tdata_out}   ;
                    end
                    default: begin
                        west_output_atvalid  <= 1'b0;
                        west_output_atdata   <= 128'b0;
                        south_output_atvalid <= 1'b0;
                        south_output_atdata  <= 128'b0;
                    end
                endcase
            end
            else if(stage_start && ~block_en)begin
                west_output_atvalid  <= input_tvalid    ;
                west_output_atdata   <= input_tdata     ;
                south_output_atvalid <= input_tvalid    ;
                south_output_atdata  <= input_tdata     ;
            end
            else begin
                west_output_atvalid  <= 1'b0;
                west_output_atdata   <= 128'b0;
                south_output_atvalid <= 1'b0;
                south_output_atdata  <= 128'b0;
            end
        end
    end

endmodule

module compare_array (
    input   wire             clk            ,
    input   wire             init_transfer  ,
    input   wire             rst_n          ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    output  reg              result_tvalid  ,
    output  wire    [31:0]   result_tdata   
);
    parameter       DATA_NUM = 10'd192;

    reg             max_tvalid;
    reg     [9:0]   in0_cnt;
    wire            compare_tvalid [3:0];

    wire    [31:0]  a_tdata1;
    wire    [31:0]  a_tdata2;
    wire    [31:0]  a_tdata3;
    wire    [31:0]  a_tdata4;

    reg     [31:0]  max_tdata1;
    reg     [31:0]  max_tdata2;
    reg     [31:0]  max_tdata3;
    reg     [31:0]  max_tdata4;

    reg     [31:0]  max_tdata1_r;
    reg     [31:0]  max_tdata2_r;
    reg     [31:0]  max_tdata3_r;
    reg     [31:0]  max_tdata4_r;

    wire    [7:0]   compare_code1;
    wire    [7:0]   compare_code2;
    wire    [7:0]   compare_code3;
    wire    [7:0]   compare_code4;

    reg     [31:0]  max_tdata5;
    reg     [31:0]  max_tdata6;
    reg     [31:0]  max_tdata7;

    wire            max_tvalid1;
    wire            max_tvalid2;
    reg             max_tvalid1_r;
    reg             max_tvalid2_r;
    wire            max_tvalid3;
    
    wire    [7:0]   compare_code5;
    wire    [7:0]   compare_code6;
    wire    [7:0]   compare_code7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            in0_cnt <= 10'd0;
        else if (in0_cnt == DATA_NUM - 10'd1)
            in0_cnt <= 10'd0;
        else if (a_tvalid) 
            in0_cnt <= in0_cnt + 10'd1;
        else
            in0_cnt <= in0_cnt;
    end
    
    assign a_tdata1 = a_tdata[31:0];
    assign a_tdata2 = a_tdata[63:32];
    assign a_tdata3 = a_tdata[95:64];
    assign a_tdata4 = a_tdata[127:96];
    
    floating_compare u_compare1 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata1),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata1),
        .m_axis_result_tvalid   (compare_tvalid[0]),
        .m_axis_result_tdata    (compare_code1)
    );

    floating_compare u_compare2 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata2),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata2),
        .m_axis_result_tvalid   (compare_tvalid[1]),
        .m_axis_result_tdata    (compare_code2)
    );

    floating_compare u_compare3 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata3),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata3),
        .m_axis_result_tvalid   (compare_tvalid[2]),
        .m_axis_result_tdata    (compare_code3)
    );

    floating_compare u_compare4 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata4),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata4),
        .m_axis_result_tvalid   (compare_tvalid[3]),
        .m_axis_result_tdata    (compare_code4)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata1 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata1 <= a_tdata1;
        else if (compare_code1[0]&&compare_tvalid[0]) 
            max_tdata1 <= a_tdata1;
        else
            max_tdata1 <= max_tdata1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata2 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata2 <= a_tdata2;
        else if (compare_code2[0]&&compare_tvalid[1]) 
            max_tdata2 <= a_tdata2;
        else
            max_tdata2 <= max_tdata2;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata3 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata3 <= a_tdata3;
        else if (compare_code3[0]&&compare_tvalid[2]) 
            max_tdata3 <= a_tdata3;
        else
            max_tdata3 <= max_tdata3;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata4 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata4 <= a_tdata4;
        else if (compare_code4[0]&&compare_tvalid[3]) 
            max_tdata4 <= a_tdata4;
        else
            max_tdata4 <= max_tdata4;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            max_tvalid <= 1'b0;
        else if (in0_cnt == DATA_NUM - 10'd1)
            max_tvalid <= 1'b1;
        else 
            max_tvalid <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            max_tdata1_r <= 32'b0;
            max_tdata2_r <= 32'b0;
            max_tdata3_r <= 32'b0;
            max_tdata4_r <= 32'b0;
        end
        else begin
            max_tdata1_r <= max_tdata1;
            max_tdata2_r <= max_tdata2;
            max_tdata3_r <= max_tdata3;
            max_tdata4_r <= max_tdata4;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            max_tvalid1_r <= 1'b0;
            max_tvalid2_r <= 1'b0;
        end
        else begin
            max_tvalid1_r <= max_tvalid1;
            max_tvalid2_r <= max_tvalid2;
        end
    end
    
    floating_compare1 u_compare5 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid),
        .s_axis_a_tdata         (max_tdata1),
        .s_axis_b_tvalid        (max_tvalid),
        .s_axis_b_tdata         (max_tdata2),
        .m_axis_result_tvalid   (max_tvalid1),
        .m_axis_result_tdata    (compare_code5)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata5 <= 32'h0;
        else if (compare_code5[0]&&max_tvalid1) 
            max_tdata5 <= max_tdata1_r;
        else if ((~compare_code5[0])&&max_tvalid1) 
            max_tdata5 <= max_tdata2_r;
        else
            max_tdata5 <= max_tdata5;
    end

    floating_compare1 u_compare6 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid),
        .s_axis_a_tdata         (max_tdata3),
        .s_axis_b_tvalid        (max_tvalid),
        .s_axis_b_tdata         (max_tdata4),
        .m_axis_result_tvalid   (max_tvalid2),
        .m_axis_result_tdata    (compare_code6)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata6 <= 32'h0;
        else if (compare_code6[0]&&max_tvalid1) 
            max_tdata6 <= max_tdata3_r;
        else if ((~compare_code6[0])&&max_tvalid1) 
            max_tdata6 <= max_tdata4_r;
        else
            max_tdata6 <= max_tdata6;
    end
    
    floating_compare1 u_compare7 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid1_r),
        .s_axis_a_tdata         (max_tdata5),
        .s_axis_b_tvalid        (max_tvalid2_r),
        .s_axis_b_tdata         (max_tdata6),
        .m_axis_result_tvalid   (max_tvalid3),
        .m_axis_result_tdata    (compare_code7)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata7 <= 32'h0;
        else if (compare_code7[0]&&max_tvalid3) 
            max_tdata7 <= max_tdata5;
        else if ((~compare_code7[0])&&max_tvalid3) 
            max_tdata7 <= max_tdata6;
        else
            max_tdata7 <= max_tdata7;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result_tvalid <= 1'b0;
        else 
            result_tvalid <= max_tvalid3;
    end

    assign result_tdata = max_tdata7;

endmodule