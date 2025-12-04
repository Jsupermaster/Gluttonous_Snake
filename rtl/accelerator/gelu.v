module GELU(
    input   wire            clk             ,
    input   wire            rst_n           ,
    input   wire            stage_start     ,
    input   wire            a_tvalid        ,
    input   wire    [63:0]  a_tdata         ,
    output  wire            result_tvalid   ,
    output  wire    [127:0] result_tdata    ,
    output  wire    [127:0] fifo_din1       ,
    output  wire            fifo_wr_en1     ,
    input   wire    [127:0] fifo_dout1      ,
    output  wire            fifo_rd_en1     
);
    parameter DATA_NUM = 8'd192;

    reg             in0_gelu_tvalid;
    reg     [63:0]  in0_gelu_tdata;
    wire            init_transfer;
    reg             init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            init_txn_ff <= 1'b0;
        end 
        else begin
            init_txn_ff <= stage_start;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            in0_gelu_tvalid <= 1'b0;
            in0_gelu_tdata  <= 64'd0;
        end 
        else begin
            if (stage_start) begin
                in0_gelu_tvalid <= a_tvalid;
                in0_gelu_tdata  <= a_tdata;
            end
            else begin
                in0_gelu_tvalid <= in0_gelu_tvalid;
                in0_gelu_tdata  <= in0_gelu_tdata;
            end
        end
    end
    wire [31:0] in0_gelu_tdata1;
    wire [31:0] in0_gelu_tdata2;
    wire [31:0] in0_gelu_tdata3;
    wire [31:0] in0_gelu_tdata4;
    assign in0_gelu_tdata1 = {in0_gelu_tdata[15:0],16'b0};
    assign in0_gelu_tdata2 = {in0_gelu_tdata[31:16],16'b0};
    assign in0_gelu_tdata3 = {in0_gelu_tdata[47:32],16'b0};
    assign in0_gelu_tdata4 = {in0_gelu_tdata[63:48],16'b0};
    wire        sub_tvalid;
    wire [127:0] sub_tdata;
    assign sub_tvalid = in0_gelu_tvalid;
    assign sub_tdata = {~in0_gelu_tdata4[31],in0_gelu_tdata4[30:0],~in0_gelu_tdata3[31],in0_gelu_tdata3[30:0],~in0_gelu_tdata2[31],in0_gelu_tdata2[30:0],~in0_gelu_tdata1[31],in0_gelu_tdata1[30:0]};

    wire        mul1_tvalid;
    wire [127:0] mul1_tdata;

    mul_array gelu_mul1 (
      .clk(clk),                                   
      .a_tvalid(sub_tvalid),             
      .a_tdata(sub_tdata),               
      .b_tvalid(sub_tvalid),             
      .b_tdata({32'h3FD9D2C7,32'h3FD9D2C7,32'h3FD9D2C7,32'h3FD9D2C7}),          
      .result_tvalid(mul1_tvalid),   
      .result_tdata(mul1_tdata)      
    );
    
    wire        exp_tvalid;
    wire [31:0] exp_tdata;

    exp_array gelu_exp(
        .clk            (clk),
        .a_tvalid       (mul1_tvalid),
        .a_tdata        (mul1_tdata),
        .result_tvalid  (exp_tvalid),
        .result_tdata   (exp_tdata)
    );

    wire         add_tvalid;
    wire [127:0] add_tdata;
    add_array gelu_add (
        .clk             (clk),
        .a_tvalid        (exp_tvalid),
        .a_tdata         (exp_tdata),
        .b_tvalid        (exp_tvalid),
        .b_tdata         ({32'h3F800000,32'h3F800000,32'h3F800000,32'h3F800000}),
        .result_tvalid   (add_tvalid),
        .result_tdata    (add_tdata)
    );

    wire         rec_tvalid;
    wire [127:0] rec_tdata;
    rec_array gelu_rec (
        .clk            (clk),
        .a_tvalid        (add_tvalid),
        .a_tdata         (add_tdata),
        .result_tvalid   (rec_tvalid),
        .result_tdata    (rec_tdata)
    );

    reg         fifo_rd_valid;
    reg [7:0]   batch_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid <= 1'b0;
        else if (rec_tvalid) 
            fifo_rd_valid <= 1'b1;
        else if ((batch_cnt == DATA_NUM - 8'd1)&&(rec_tvalid == 1'b0))
            fifo_rd_valid <= 1'b0;
        else
            fifo_rd_valid <= fifo_rd_valid;
    end
    reg         fifo_rd_valid_r1;
    reg         fifo_rd_valid_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_rd_valid_r1 <= 1'b0;
            fifo_rd_valid_r2 <= 1'b0;
        end
        else begin
            fifo_rd_valid_r1 <= fifo_rd_valid;
            fifo_rd_valid_r2 <= fifo_rd_valid_r1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            batch_cnt <= 8'd0;
        else if (batch_cnt == DATA_NUM - 8'd1)
            batch_cnt <= 8'd0;
        else if (fifo_rd_valid) 
            batch_cnt <= batch_cnt + 8'd1;
        else
            batch_cnt <= batch_cnt;
    end
    
    assign fifo_wr_en1 = in0_gelu_tvalid;
    assign fifo_din1 = {in0_gelu_tdata4,in0_gelu_tdata3,in0_gelu_tdata2,in0_gelu_tdata1};
    assign fifo_rd_en1 = fifo_rd_valid;


    reg [127:0]  rec_valid_data;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            rec_valid_data <= 128'h0;
        else if (rec_tvalid)
            rec_valid_data <= rec_tdata;
        else
            rec_valid_data <= rec_valid_data;
    end
    reg [127:0]  rec_valid_data_r1;
    reg [127:0]  rec_valid_data_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rec_valid_data_r1 <= 128'b0;
            rec_valid_data_r2 <= 128'b0;
        end
        else begin
            rec_valid_data_r1 <= rec_valid_data;
            rec_valid_data_r2 <= rec_valid_data_r1;
        end
    end
    mul_array gelu_mul2 (
        .clk             (clk),
        .a_tvalid        (fifo_rd_valid_r2),
        .a_tdata         (rec_valid_data_r2),
        .b_tvalid        (fifo_rd_valid_r2),
        .b_tdata         (fifo_dout1),
        .result_tvalid   (result_tvalid),
        .result_tdata    (result_tdata)
    );

endmodule