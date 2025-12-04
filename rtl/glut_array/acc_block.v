module acc_block #(
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

    reg                         input_atvalid_reg   ;
    reg             [127:0]     input_atdata_reg    ;
    reg             [9:0]       input_cnt           ;
    reg                         input_tlast         ;
    wire            [31:0]      sum_tdata           ;
    wire                        sum_tvalid          ;

    always @(posedge clk) begin
        if(!rst_n) begin
            input_atdata_reg <= 128'b0;
            input_atvalid_reg <= 1'b0;
        end
        else begin
            if(stage_start) begin
                input_atdata_reg  <= input_atdata;
                input_atvalid_reg <= input_atvalid;
            end
            else begin
                input_atdata_reg <= 128'b0;
                input_atvalid_reg <= 1'b0;
            end
        end
    end

    acc_array  block_acc_array (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .a_tvalid       (input_atvalid_reg      ),
        .a_tdata        (input_atdata_reg       ),
        .result_tvalid  (sum_tvalid             ),
        .result_tdata   (sum_tdata              )
    );

    always @(posedge clk) begin
        if(!rst_n) begin
            west_output_atvalid  <= 1'b0;
            west_output_atdata   <= 128'b0;
            south_output_atvalid <= 1'b0;
            south_output_atdata  <= 128'b0;
        end
        else begin
            if(stage_start && block_en) begin
                west_output_atvalid  <= output_sel[0] ? sum_tvalid                                      : input_atvalid_reg   ;
                west_output_atdata   <= output_sel[0] ? {sum_tdata, sum_tdata, sum_tdata, sum_tdata}    : input_atdata_reg    ;
                south_output_atvalid <= output_sel[1] ? sum_tvalid                                      : input_atvalid_reg    ;
                south_output_atdata  <= output_sel[1] ? {sum_tdata, sum_tdata, sum_tdata, sum_tdata}    : input_atdata_reg     ;
            end
            else if(stage_start && ~block_en)begin
                west_output_atvalid  <= input_atvalid_reg    ;
                west_output_atdata   <= input_atdata_reg     ;
                south_output_atvalid <= input_atvalid_reg    ;
                south_output_atdata  <= input_atdata_reg     ;
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

module acc_array (
    input   wire             clk            ,
    input   wire             rst_n          ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [31:0]   result_tdata   
);
    wire        acc_tlast;
    wire        acc_tvalid;
    wire [31:0] a_tdata1;
    wire [31:0] a_tdata2;
    wire [31:0] a_tdata3;
    wire [31:0] a_tdata4;
    
    assign a_tdata1 = a_tdata[31:0];
    assign a_tdata2 = a_tdata[63:32];
    assign a_tdata3 = a_tdata[95:64];
    assign a_tdata4 = a_tdata[127:96];

    wire [31:0] add_tdata1;
    wire        add_tvalid1;
    wire [31:0] add_tdata2;
    wire        add_tvalid2;
    floating_add add1 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata1),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (a_tdata3),
        .m_axis_result_tvalid   (add_tvalid1),
        .m_axis_result_tdata    (add_tdata1)
    );

    floating_add add2 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata2),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (a_tdata4),
        .m_axis_result_tvalid   (add_tvalid2),
        .m_axis_result_tdata    (add_tdata2)
    );
    wire [31:0] add_tdata3;
    wire        add_tvalid3;
    reg  [31:0] add_tdata3_reg;
    reg         add_tvalid3_reg;
    floating_add add3 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (add_tvalid1),
        .s_axis_a_tdata         (add_tdata1),
        .s_axis_b_tvalid        (add_tvalid2),
        .s_axis_b_tdata         (add_tdata2),
        .m_axis_result_tvalid   (add_tvalid3),
        .m_axis_result_tdata    (add_tdata3)
    );
    reg         add_tlast;
    reg [7:0]   add_cnt;
    parameter DATA_NUM = 8'd192;
    
    always @ (posedge clk)  begin
        if (!rst_n) begin
            add_tvalid3_reg <= 1'b0;
        end
        else begin
            add_tvalid3_reg <= add_tvalid3;
        end
    end
    
    always @ (posedge clk)  begin
        if (!rst_n) begin
            add_tdata3_reg <= 1'b0;
        end
        else if (add_tvalid3) begin
            add_tdata3_reg <= add_tdata3;
        end
        else begin
            add_tdata3_reg <= add_tdata3_reg;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            add_cnt <= 8'd0;
            add_tlast   <= 1'b1;
        end 
        else if (add_tvalid3_reg) begin
            if (add_cnt == DATA_NUM - 8'd2) begin
                add_tlast   <= 1'b1;
                add_cnt <= add_cnt + 8'd1;
            end 
            else if (add_cnt == DATA_NUM - 8'd1) begin
                add_tlast   <= 1'b0;
                add_cnt <= 8'd0;
            end 
            else begin
                add_tlast   <= 1'b0;
                add_cnt <= add_cnt + 8'd1;
            end
        end
        else begin
            add_cnt <= add_cnt;
            add_tlast <= 1'b0;
        end
    end
    floating_acc u_acc (
        .aclk                   (clk),
        .s_axis_a_tvalid        (add_tvalid3_reg),
        .s_axis_a_tdata         (add_tdata3_reg),
        .s_axis_a_tlast         (add_tlast),
        .m_axis_result_tvalid   (acc_tvalid),
        .m_axis_result_tdata    (result_tdata),
        .m_axis_result_tlast    (acc_tlast)
    );
    assign result_tvalid = acc_tvalid && acc_tlast;

endmodule