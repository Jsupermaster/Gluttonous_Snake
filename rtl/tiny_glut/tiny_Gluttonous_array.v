// This module is the top-level control module for the Gluttonous snake game, and it supports three types of calculations.
module tiny_GLUT_SNAKE_array #(
    parameter                   DATA_NUM = 10'd192
)
(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    input   wire            stage_start         ,
    input   wire            input_atvalid       ,
    input   wire    [63:0]  input_atdata        ,
    input   wire            input_btvalid       ,
    input   wire    [63:0]  input_btdata        ,
    input   wire    [3:0]   configs             ,

    output  reg     [63:0]  fifo1_din           ,
    output  reg             fifo1_wr_en         ,
    input   wire    [63:0]  fifo1_dout          ,
    output  wire            fifo1_rd_en         ,

    output  wire            result_tvalid       ,
    output  wire    [63:0]  result_tdata        
);
    wire            init_transfer                       ;
    reg             init_txn_ff                         ;
    (*MAX_FANOUT = 30 *)reg     [3:0]   configs_reg                         ;
    (*MAX_FANOUT = 30 *)reg     [3:0]   configs_reg2                        ;
    (*MAX_FANOUT = 30 *)reg             stage_start_reg                     ;
    reg             input_atvalid_reg                   ;
    reg     [63:0]  input_atdata_reg                    ;
    reg             input_btvalid_reg                   ;
    reg     [63:0]  input_btdata_reg                    ;
    reg             input_atvalid_reg2                  ;
    reg     [63:0]  input_atdata_reg2                   ;
    reg             input_btvalid_reg2                  ;
    reg     [63:0]  input_btdata_reg2                   ;

    reg             fifo1_rden_reg_delay1               ;

    // block_01 signals
    reg             block_01_en                         ;
    wire            block_01_east_in_tvalid             ;
    wire    [63:0]  block_01_east_in_tdata              ;
    wire            block_01_north_in_tvalid            ;
    wire    [63:0]  block_01_north_in_tdata             ;
    wire            block_01_west_out_tvalid            ;
    wire    [63:0]  block_01_west_out_tdata             ;

    // block_02 signals
    reg             block_02_en                         ;
    wire            block_02_east_in_tvalid             ;
    wire    [63:0]  block_02_east_in_tdata              ;
    wire            block_02_north_in_tvalid            ;
    wire    [63:0]  block_02_north_in_tdata             ;
    wire            block_02_west_out_tvalid            ;
    wire    [63:0]  block_02_west_out_tdata             ;

    reg             block_02_cal_tvalid                 ;
    reg     [63:0]  block_02_cal_tdata                  ;

    // block_03 signals
    reg             block_03_en                         ;
    wire            block_03_east_in_tvalid             ;
    wire    [63:0]  block_03_east_in_tdata              ;
    wire            block_03_north_in_tvalid            ;
    wire    [63:0]  block_03_north_in_tdata             ;
    wire            block_03_west_out_tvalid            ;
    wire    [63:0]  block_03_west_out_tdata             ;

    reg             block_03_west_out_tvalid_delay1     ;
    reg     [63:0]  block_03_west_out_tdata_delay1      ;

    // block_04 signals
    reg             block_04_en                         ;
    wire            block_04_east_in_tvalid             ;
    wire    [63:0]  block_04_east_in_tdata              ;
    wire            block_04_north_in_tvalid            ;
    wire    [63:0]  block_04_north_in_tdata             ;
    wire            block_04_west_out_tvalid            ;
    wire    [63:0]  block_04_west_out_tdata             ;

    always @(posedge clk) begin                                                                          
        if (!rst_n) begin                                                                    
            init_txn_ff <= 1'b0;   
            stage_start_reg <= 1'b0;                                                                                              
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;     
            stage_start_reg <= stage_start;                                                     
        end                                                                      
    end

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk) begin                                                                          
        if (!rst_n || init_transfer) begin                                                                    
            input_atvalid_reg   <= 1'b0;   
            input_atdata_reg    <= 64'b0;
            input_btvalid_reg   <= 1'b0;   
            input_btdata_reg    <= 64'b0;
            input_atvalid_reg2  <= 1'b0;   
            input_atdata_reg2   <= 64'b0;
            input_btvalid_reg2  <= 1'b0;   
            input_btdata_reg2   <= 64'b0;
            configs_reg         <= 4'b0;    
            configs_reg2        <= 4'b0;
            fifo1_din           <= 64'b0;
            fifo1_wr_en         <= 1'b0;                                                                           
        end                                                                               
        else begin  
            input_atvalid_reg   <= input_atvalid        ;
            input_atdata_reg    <= input_atdata         ;
            input_btvalid_reg   <= input_btvalid        ;
            input_btdata_reg    <= input_btdata         ;
            input_atvalid_reg2  <= input_atvalid_reg    ;
            input_atdata_reg2   <= input_atdata_reg     ;
            input_btvalid_reg2  <= input_btvalid_reg    ;
            input_btdata_reg2   <= input_btdata_reg     ;
            fifo1_wr_en         <= input_atvalid        ;
            fifo1_din           <= input_atdata         ;
            configs_reg         <= configs[3:0]         ;
            configs_reg2        <= configs[3:0]         ;                                     
        end                                                                      
    end

    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            block_01_en             <= 1'b0             ;
            block_02_en             <= 1'b0             ;
            block_02_cal_tvalid     <= 1'b0             ;
            block_02_cal_tdata      <= 64'b00000000     ;
            block_03_en             <= 1'b0             ;
            block_04_en             <= 1'b0             ;
        end
        else begin
            case (configs_reg)
                4'd3: begin    // SILU
                    block_01_en             <= 1'b1             ;
                    
                    block_02_en             <= 1'b1             ;
                    block_02_cal_tvalid     <= 1'b1             ;
                    block_02_cal_tdata      <= {16'h3F80, 16'h3F80, 16'h3F80, 16'h3F80}; // 1

                    block_03_en             <= 1'b1             ;
                    block_04_en             <= 1'b1             ;
                end
                4'd4: begin    // GELU
                    block_01_en             <= 1'b1             ;
                    
                    block_02_en             <= 1'b1             ;
                    block_02_cal_tvalid     <= 1'b1             ;
                    block_02_cal_tdata      <= {16'h3F80, 16'h3F80, 16'h3F80, 16'h3F80}; // 1

                    block_03_en             <= 1'b1             ;
                    block_04_en             <= 1'b1             ;
                end
                4'd5: begin    // ADD
                    block_01_en             <= 1'b0             ;
                    
                    block_02_en             <= 1'b1             ;
                    block_02_cal_tvalid     <= 1'b0             ;
                    block_02_cal_tdata      <= 64'b0            ;

                    block_03_en             <= 1'b0             ;
                    block_04_en             <= 1'b0             ;
                end
                4'd6: begin    // MUL
                    block_01_en             <= 1'b0             ;
                    
                    block_02_en             <= 1'b0             ;
                    block_02_cal_tvalid     <= 1'b0             ;
                    block_02_cal_tdata      <= 64'b0            ;

                    block_03_en             <= 1'b0             ;
                    block_04_en             <= 1'b1             ;
                end
            default: begin
                block_01_en             <= 1'b0             ;
                block_02_en             <= 1'b0             ;
                block_02_cal_tvalid     <= 1'b0             ;
                block_02_cal_tdata      <= 64'b00000000     ;
                block_03_en             <= 1'b0             ;
                block_04_en             <= 1'b0             ;
            end
            endcase
        end
    end

    //============================ BLOCK 01 ============================
    assign block_01_east_in_tvalid  = input_atvalid_reg2      ;
    assign block_01_east_in_tdata   = {~input_atdata_reg2[63], input_atdata_reg2[62:48], ~input_atdata_reg2[47], input_atdata_reg2[46:32], ~input_atdata_reg2[31], input_atdata_reg2[30:16], ~input_atdata_reg2[15], input_atdata_reg2[14:0]}       ;
    assign block_01_north_in_tvalid = 1'b0                          ;
    assign block_01_north_in_tdata  = 64'b0                         ;

    tiny_basic_block_x4 #(
        .pattern        ("EXP")
    )
    block_01
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_01_en                   ),
        .east_in_tvalid      (block_01_east_in_tvalid       ),
        .east_in_tdata       (block_01_east_in_tdata        ),
        .north_in_tvalid     (block_01_north_in_tvalid      ),
        .north_in_tdata      (block_01_north_in_tdata       ),
        .west_out_tvalid     (block_01_west_out_tvalid      ),
        .west_out_tdata      (block_01_west_out_tdata       )
    );

    //============================ BLOCK 02 ============================
    assign block_02_east_in_tvalid  = (configs_reg == 4'd5) ? input_atvalid_reg2 : block_01_west_out_tvalid  ;
    assign block_02_east_in_tdata   = (configs_reg == 4'd5) ? input_atdata_reg2  : block_01_west_out_tdata   ;
    assign block_02_north_in_tvalid = (configs_reg == 4'd5) ? input_btvalid_reg2 : block_02_cal_tvalid       ;
    assign block_02_north_in_tdata  = (configs_reg == 4'd5) ? input_btdata_reg2  : block_02_cal_tdata        ;

    tiny_basic_block_x4 #(
        .pattern        ("ADD")
    )
    block_02
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_02_en                   ),
        .east_in_tvalid      (block_02_east_in_tvalid       ),
        .east_in_tdata       (block_02_east_in_tdata        ),
        .north_in_tvalid     (block_02_north_in_tvalid      ),
        .north_in_tdata      (block_02_north_in_tdata       ),
        .west_out_tvalid     (block_02_west_out_tvalid      ),
        .west_out_tdata      (block_02_west_out_tdata       )
    );

    //============================ BLOCK 03 ============================
    assign block_03_east_in_tvalid  = block_02_west_out_tvalid  ;
    assign block_03_east_in_tdata   = block_02_west_out_tdata   ;
    assign block_03_north_in_tvalid = 1'b0                      ;
    assign block_03_north_in_tdata  = 64'b0                     ;

    tiny_basic_block_x4 #(
        .pattern        ("REC")
    )
    block_03
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_03_en                   ),
        .east_in_tvalid      (block_03_east_in_tvalid       ),
        .east_in_tdata       (block_03_east_in_tdata        ),
        .north_in_tvalid     (block_03_north_in_tvalid      ),
        .north_in_tdata      (block_03_north_in_tdata       ),
        .west_out_tvalid     (block_03_west_out_tvalid      ),
        .west_out_tdata      (block_03_west_out_tdata       )
    );

    // ================ Read FIFO 1 and MAX out counter ================
    assign fifo1_rd_en = block_03_west_out_tvalid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            fifo1_rden_reg_delay1 <= 1'b0;
            block_03_west_out_tvalid_delay1 <= 1'b0;
            block_03_west_out_tdata_delay1 <= 64'b0;
        end
        else begin
            fifo1_rden_reg_delay1 <= fifo1_rd_en;
            block_03_west_out_tvalid_delay1 <= block_03_west_out_tvalid;
            block_03_west_out_tdata_delay1  <= block_03_west_out_tdata;
        end
    end

    //============================ BLOCK 04 ============================
    assign block_04_east_in_tvalid  = (configs_reg == 4'd6) ? input_atvalid_reg2 : block_03_west_out_tvalid_delay1   ;
    assign block_04_east_in_tdata   = (configs_reg == 4'd6) ? input_atdata_reg2  : block_03_west_out_tdata_delay1    ;
    assign block_04_north_in_tvalid = (configs_reg == 4'd6) ? input_btvalid_reg2 : fifo1_rden_reg_delay1 ;
    assign block_04_north_in_tdata  = (configs_reg == 4'd6) ? input_btdata_reg2  : fifo1_dout            ;

    tiny_basic_block_x4 #(
        .pattern        ("MUL")
    )
    block_04
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_04_en                   ),
        .east_in_tvalid      (block_04_east_in_tvalid       ),
        .east_in_tdata       (block_04_east_in_tdata        ),
        .north_in_tvalid     (block_04_north_in_tvalid      ),
        .north_in_tdata      (block_04_north_in_tdata       ),
        .west_out_tvalid     (block_04_west_out_tvalid      ),
        .west_out_tdata      (block_04_west_out_tdata       )
    );

    assign result_tvalid = block_04_west_out_tvalid;
    assign result_tdata = block_04_west_out_tdata;

endmodule