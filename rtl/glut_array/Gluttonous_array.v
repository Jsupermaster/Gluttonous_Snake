// This module is the top-level control module for the Gluttonous snake game, and it supports three types of calculations.
module GLUT_SNAKE_array #(
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

    output  reg     [127:0] fifo1_din           ,
    output  reg             fifo1_wr_en         ,
    input   wire    [127:0] fifo1_dout          ,
    output  wire            fifo1_rd_en         ,
    output  wire    [127:0] fifo2_din           ,
    output  wire            fifo2_wr_en         ,
    input   wire    [127:0] fifo2_dout          ,
    output  wire            fifo2_rd_en         ,

    output  wire            result_tvalid       ,
    output  wire    [127:0] result_tdata        
);
    wire            init_transfer                       ;
    reg             init_txn_ff                         ;
    reg     [3:0]   configs_reg                         ;
    reg     [3:0]   configs_reg2                        ;
    (*MAX_FANOUT = 30 *)reg             stage_start_reg                     ;
    reg             input_atvalid_reg                   ;
    reg     [127:0] input_atdata_reg                    ;
    reg             input_btvalid_reg                   ;
    reg     [127:0] input_btdata_reg                    ;

    reg             fifo1_rden_reg_delay1               ;
    reg             fifo2_rden_reg_delay1               ;

    // block_00 signals
    reg             block_00_en                         ;
    reg     [1:0]   block_00_output_sel                 ;

    wire            block_00_in_tvalid                  ;
    wire    [127:0] block_00_in_tdata                   ;
    wire            block_00_west_out_tvalid            ;
    wire    [127:0] block_00_west_out_tdata             ;
    wire            block_00_south_out_tvalid           ;
    wire    [127:0] block_00_south_out_tdata            ;

    // block_01 signals
    reg     [1:0]   block_01_en                         ;
    reg     [2:0]   block_01_input_sel_a                ;
    reg     [2:0]   block_01_input_sel_b                ;
    reg     [2:0]   block_01_squ_output_sel             ;
    reg     [2:0]   block_01_exp_output_sel             ;

    wire            block_01_east_in_tvalid             ;
    wire    [127:0] block_01_east_in_tdata              ;
    wire            block_01_south_in_tvalid            ;
    wire    [127:0] block_01_south_in_tdata             ;

    wire            block_01_west_out_tvalid            ;
    wire    [127:0] block_01_west_out_tdata             ;
    wire            block_01_north_out_tvalid           ;
    wire    [127:0] block_01_north_out_tdata            ;
    wire            block_01_south_out_tvalid           ;
    wire    [127:0] block_01_south_out_tdata            ;

    reg             block_01_cal_tvalid                 ;
    reg     [127:0] block_01_cal_tdata                  ;

    // block_02 signals
    reg             block_02_en                         ;
    reg     [1:0]   block_02_output_sel                 ;

    wire            block_02_in_tvalid                  ;
    wire    [127:0] block_02_in_tdata                   ;
    wire            block_02_west_out_tvalid            ;
    wire    [127:0] block_02_west_out_tdata             ;
    wire            block_02_south_out_tvalid           ;
    wire    [127:0] block_02_south_out_tdata            ;

    reg             block_02_sum_en                     ;
    reg     [9:0]   block_02_sum_cnt                    ;
    reg     [127:0] block_02_sum_tdata_out              ;

    // block_03 signals
    reg             block_03_en                         ;
    reg     [2:0]   block_03_input_sel_a                ;
    reg     [2:0]   block_03_input_sel_b                ;
    reg     [2:0]   block_03_output_sel                 ;

    wire            block_03_east_in_tvalid             ;
    wire    [127:0] block_03_east_in_tdata              ;
    wire            block_03_north_in_tvalid            ;
    wire    [127:0] block_03_north_in_tdata             ;
    wire            block_03_south_in_tvalid            ;
    wire    [127:0] block_03_south_in_tdata             ;

    wire            block_03_west_out_tvalid            ;
    wire    [127:0] block_03_west_out_tdata             ;
    wire            block_03_north_out_tvalid           ;
    wire    [127:0] block_03_north_out_tdata            ;
    wire            block_03_south_out_tvalid           ;
    wire    [127:0] block_03_south_out_tdata            ;

    reg             block_03_west_out_tvalid_delay1     ;
    reg     [127:0] block_03_west_out_tdata_delay1      ;

    // block_10 signals
    reg             block_10_en                         ;
    reg     [1:0]   block_10_output_sel                 ;

    wire            block_10_in_tvalid                  ;
    wire    [127:0] block_10_in_tdata                   ;
    wire            block_10_west_out_tvalid            ;
    wire    [127:0] block_10_west_out_tdata             ;
    wire            block_10_south_out_tvalid           ;
    wire    [127:0] block_10_south_out_tdata            ;
    reg             block_10_west_out_tvalid_delay1     ;
    reg     [127:0] block_10_west_out_tdata_delay1      ;
    
    // block_11 signals
    reg     [1:0]   block_11_en                         ;
    reg     [3:0]   block_11_input_sel_a                ;
    reg     [2:0]   block_11_input_sel_b                ;
    reg     [2:0]   block_11_add_output_sel             ;
    reg     [2:0]   block_11_mul_output_sel             ;

    wire            block_11_fifo_read_en               ;
    wire            block_11_fifo_in_tvalid             ;
    wire    [127:0] block_11_fifo_in_tdata              ;
    reg             block_11_cal_tvalid                 ;
    reg     [127:0] block_11_cal_tdata                  ;

    wire            block_11_east_in_tvalid             ;
    wire    [127:0] block_11_east_in_tdata              ;
    wire            block_11_north_in_tvalid            ;
    wire    [127:0] block_11_north_in_tdata             ;
    wire            block_11_south_in_tvalid            ;
    wire    [127:0] block_11_south_in_tdata             ;

    wire            block_11_west_out_tvalid            ;
    wire    [127:0] block_11_west_out_tdata             ;
    wire            block_11_north_out_tvalid           ;
    wire    [127:0] block_11_north_out_tdata            ;

    // block_12 signals
    reg     [2:0]   block_12_en                         ;
    reg     [2:0]   block_12_input_sel_a                ;
    reg     [2:0]   block_12_input_sel_b                ;
    reg     [2:0]   block_12_add_output_sel             ;
    reg     [2:0]   block_12_mul_output_sel             ;

    reg             block_12_cal_tvalid                 ;
    reg     [31:0]  block_12_cal_tdata                  ;
    reg             block_12_cal2_tvalid                ;
    reg     [31:0]  block_12_cal2_tdata                 ;

    wire            block_12_east_in_tvalid             ;
    wire    [127:0] block_12_east_in_tdata              ;
    wire            block_12_north_in_tvalid            ;
    wire    [127:0] block_12_north_in_tdata             ;
    wire            block_12_south_in_tvalid            ;
    wire    [127:0] block_12_south_in_tdata             ;

    wire            block_12_west_out_tvalid            ;
    wire    [127:0] block_12_west_out_tdata             ;
    wire            block_12_north_out_tvalid           ;
    wire    [127:0] block_12_north_out_tdata            ;

    // block_13 signals
    reg             block_13_en                         ;
    reg     [2:0]   block_13_input_sel_a                ;
    reg     [2:0]   block_13_input_sel_b                ;
    reg     [2:0]   block_13_output_sel                 ;

    wire            block_13_east_in_tvalid             ;
    wire    [31:0]  block_13_east_in_tdata              ;
    wire            block_13_north_in_tvalid            ;
    wire    [31:0]  block_13_north_in_tdata             ;
    wire            block_13_south_in_tvalid            ;
    wire    [31:0]  block_13_south_in_tdata             ;

    wire            block_13_west_out_tvalid            ;
    wire    [31:0]  block_13_west_out_tdata             ;
    wire            block_13_north_out_tvalid           ;
    wire    [31:0]  block_13_north_out_tdata            ;
    wire            block_13_south_out_tvalid           ;
    wire    [31:0]  block_13_south_out_tdata            ;

    reg             block_13_west_out_tvalid_delay1     ;
    reg     [31:0]  block_13_west_out_tdata_delay1      ;

    // block_14 signals
    reg             block_14_en                         ;
    reg     [2:0]   block_14_input_sel_a                ;
    reg     [2:0]   block_14_input_sel_b                ;
    reg     [2:0]   block_14_output_sel                 ;

    wire            block_14_east_in_tvalid             ;
    wire    [127:0] block_14_east_in_tdata              ;
    wire            block_14_north_in_tvalid            ;
    wire    [127:0] block_14_north_in_tdata             ;
    wire            block_14_south_in_tvalid            ;
    wire    [127:0] block_14_south_in_tdata             ;

    wire            block_14_west_out_tvalid            ;
    wire    [127:0] block_14_west_out_tdata             ;
    wire            block_14_north_out_tvalid           ;
    wire    [127:0] block_14_north_out_tdata            ;
    wire            block_14_south_out_tvalid           ;
    wire    [127:0] block_14_south_out_tdata            ;

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
            input_atvalid_reg <= 1'b0;   
            input_atdata_reg  <= 128'b0;
            input_btvalid_reg <= 1'b0;   
            input_btdata_reg  <= 128'b0;
            configs_reg      <= 4'b0;    
            configs_reg2     <= 4'b0;
            fifo1_din        <= 128'b0;
            fifo1_wr_en      <= 1'b0;                                                                           
        end                                                                               
        else begin  
            input_atvalid_reg <= input_atvalid    ;
            input_atdata_reg  <= {input_atdata[63:48], 16'b0, input_atdata[47:32], 16'b0, input_atdata[31:16], 16'b0, input_atdata[15:0], 16'b0}     ;
            input_btvalid_reg <= input_btvalid    ;
            input_btdata_reg  <= {input_btdata[63:48], 16'b0, input_btdata[47:32], 16'b0, input_btdata[31:16], 16'b0, input_btdata[15:0], 16'b0}     ;
            fifo1_wr_en       <= input_atvalid    ;
            fifo1_din         <= {input_atdata[63:48], 16'b0, input_atdata[47:32], 16'b0, input_atdata[31:16], 16'b0, input_atdata[15:0], 16'b0}     ;
            configs_reg       <= configs[3:0]         ;
            configs_reg2      <= configs[3:0]         ;                                     
        end                                                                      
    end

    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            block_00_en             <= 1'b0             ;
            block_00_output_sel     <= 2'b00            ;
            block_01_en             <= 2'b00            ;
            block_01_input_sel_a    <= 3'b000           ;
            block_01_input_sel_b    <= 3'b000           ;
            block_01_squ_output_sel <= 3'b000           ;
            block_01_exp_output_sel <= 3'b000           ;
            block_01_cal_tvalid     <= 1'b0             ;
            block_01_cal_tdata      <= 128'b00000000    ;
            block_02_en             <= 1'b0             ;
            block_02_output_sel     <= 2'b00            ;
            block_03_en             <= 1'b0             ;
            block_03_input_sel_a    <= 3'b000           ;
            block_03_input_sel_b    <= 3'b000           ;
            block_03_output_sel     <= 3'b000           ;
        end
        else begin
            case (configs_reg)
                4'd0: begin    // Softmax
                    block_00_en             <= 1'b1             ;
                    block_00_output_sel     <= 2'b10            ; // To South (block_10)

                    block_01_en             <= 2'b01            ; // Normal-cal
                    block_01_input_sel_a    <= 3'b100           ; // From South (block_11)
                    block_01_input_sel_b    <= 3'b000           ; // Not Use
                    block_01_squ_output_sel <= 3'b000           ; // Not Use
                    block_01_exp_output_sel <= 3'b011           ; // To West and North
                    block_01_cal_tvalid     <= 1'b0             ; // Not Use
                    block_01_cal_tdata      <= {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};

                    block_02_en             <= 1'b1             ;
                    block_02_output_sel     <= 2'b01            ; // To West (block_02)

                    block_03_en             <= 1'b1             ;
                    block_03_input_sel_a    <= 3'b001           ; // From East
                    block_03_input_sel_b    <= 3'b000           ; // Not Use
                    block_03_output_sel     <= 3'b001           ; // To West
                end
                4'd1: begin    // LayerNorm
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ; // To South (block_10) and West (block_01) after 2 cycles

                    block_01_en             <= 2'b01            ; // Normal-cal
                    block_01_input_sel_a    <= 3'b001           ; // From West (block_00)
                    block_01_input_sel_b    <= 3'b001           ; // From West (block_00)
                    block_01_squ_output_sel <= 3'b001           ; // To West (block_02)
                    block_01_exp_output_sel <= 3'b000           ; // Not Use
                    block_01_cal_tvalid     <= 1'b0             ; // Not Use
                    block_01_cal_tdata      <= {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};

                    block_02_en             <= 1'b1             ;
                    block_02_output_sel     <= 2'b10            ; // To South (block_12)

                    block_03_en             <= 1'b0             ; // Not Use
                    block_03_input_sel_a    <= 3'b000           ;
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b000           ;
                end
                4'd2: begin    // RMSNorm
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ; // To South (block_10) and West (block_01)

                    block_01_en             <= 2'b01            ; // Normal-cal
                    block_01_input_sel_a    <= 3'b001           ; // From West (block_00)
                    block_01_input_sel_b    <= 3'b001           ; // From West (block_00)
                    block_01_squ_output_sel <= 3'b001           ; // To West (block_02)
                    block_01_exp_output_sel <= 3'b000           ; // Not Use
                    block_01_cal_tvalid     <= 1'b0             ; // Not Use
                    block_01_cal_tdata      <= {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};

                    block_02_en             <= 1'b1             ;
                    block_02_output_sel     <= 2'b10            ; // To South (block_12)

                    block_03_en             <= 1'b0             ; // Not Use
                    block_03_input_sel_a    <= 3'b000           ;
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b000           ;
                end
                4'd3: begin    // SILU
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ; // To South (block_10) and West (block_01)

                    block_01_en             <= 2'b10            ; // Self-cal
                    block_01_input_sel_a    <= 3'b001           ; // From East (block_00)
                    block_01_input_sel_b    <= 3'b010           ; // From North (cal data)
                    block_01_squ_output_sel <= 3'b000           ; // Not Use
                    block_01_exp_output_sel <= 3'b100           ; // To South (block_11)
                    block_01_cal_tvalid     <= 1'b1             ;
                    block_01_cal_tdata      <= {32'hBF800000, 32'hBF800000, 32'hBF800000, 32'hBF800000}; // -1

                    block_02_en             <= 1'b0             ; // Not Use
                    block_02_output_sel     <= 2'b00            ; // To West (block_03)

                    block_03_en             <= 1'b1             ;
                    block_03_input_sel_a    <= 3'b001           ; // From East (block_02)
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b001           ; // To West (block_14)
                end
                4'd4: begin    // GELU
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ; // To South (block_10) and West (block_01)

                    block_01_en             <= 2'b10            ; // Self-cal
                    block_01_input_sel_a    <= 3'b001           ; // From East (block_00)
                    block_01_input_sel_b    <= 3'b010           ; // From North (cal data)
                    block_01_squ_output_sel <= 3'b000           ; // Not Use
                    block_01_exp_output_sel <= 3'b100           ; // To South (block_11)
                    block_01_cal_tvalid     <= 1'b1             ;
                    block_01_cal_tdata      <= {32'hBFD9D2C7, 32'hBFD9D2C7, 32'hBFD9D2C7, 32'hBFD9D2C7}    ; // -1.7017449140548706

                    block_02_en             <= 1'b0             ; // Not Use
                    block_02_output_sel     <= 2'b00            ; // To West (block_03)

                    block_03_en             <= 1'b1             ;
                    block_03_input_sel_a    <= 3'b001           ; // From East (block_02)
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b001           ; // To West (block_14)
                end
                4'd5: begin    // ADD
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ;

                    block_01_en             <= 2'b00            ; // By Pass
                    block_01_input_sel_a    <= 3'b100           ; // From South
                    block_01_input_sel_b    <= 3'b000           ;
                    block_01_squ_output_sel <= 3'b000           ;
                    block_01_exp_output_sel <= 3'b000           ;
                    block_01_cal_tvalid     <= 1'b0             ;
                    block_01_cal_tdata      <= 128'b0           ;

                    block_02_en             <= 1'b0             ;
                    block_02_output_sel     <= 2'b00            ;

                    block_03_en             <= 1'b0             ; // By Pass
                    block_03_input_sel_a    <= 3'b001           ; // From East
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b000           ;
                end
                4'd6: begin    // MUL
                    block_00_en             <= 1'b0             ; // Not Use
                    block_00_output_sel     <= 2'b00            ;

                    block_01_en             <= 2'b01            ; // Normal-cal
                    block_01_input_sel_a    <= 3'b001           ; // From East
                    block_01_input_sel_b    <= 3'b100           ; // From South
                    block_01_squ_output_sel <= 3'b001           ; // To West
                    block_01_exp_output_sel <= 3'b000           ;
                    block_01_cal_tvalid     <= 1'b0             ;
                    block_01_cal_tdata      <= 128'b0           ;

                    block_02_en             <= 1'b0             ;
                    block_02_output_sel     <= 2'b00            ;

                    block_03_en             <= 1'b0             ; // By Pass
                    block_03_input_sel_a    <= 3'b001           ; // From East
                    block_03_input_sel_b    <= 3'b000           ;
                    block_03_output_sel     <= 3'b000           ;
                end
            default: begin
                block_00_en             <= 1'b0             ;
                block_00_output_sel     <= 2'b00            ;
                block_01_en             <= 2'b00            ;
                block_01_input_sel_a    <= 3'b000           ;
                block_01_input_sel_b    <= 3'b000           ;
                block_01_squ_output_sel <= 3'b000           ;
                block_01_exp_output_sel <= 3'b000           ;
                block_01_cal_tvalid     <= 1'b0             ;
                block_01_cal_tdata      <= 128'b00000000    ;
                block_02_en             <= 1'b0             ;
                block_02_output_sel     <= 2'b00            ;
                block_03_en             <= 1'b0             ;
                block_03_input_sel_a    <= 3'b000           ;
                block_03_input_sel_b    <= 3'b000           ;
                block_03_output_sel     <= 3'b000           ;
            end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            block_10_en             <= 1'b0             ;
            block_10_output_sel     <= 2'b00            ;
            block_11_en             <= 2'b00            ;
            block_11_input_sel_a    <= 4'b0000          ;
            block_11_input_sel_b    <= 3'b000           ;
            block_11_add_output_sel <= 3'b000           ;
            block_11_mul_output_sel <= 3'b000           ;
            block_11_cal_tvalid     <= 1'b0             ;
            block_11_cal_tdata      <= 128'b00000000    ;
            block_12_en             <= 3'b000           ;
            block_12_input_sel_a    <= 3'b000           ;
            block_12_input_sel_b    <= 3'b000           ;
            block_12_add_output_sel <= 3'b000           ;
            block_12_mul_output_sel <= 3'b000           ;
            block_12_cal_tvalid     <= 1'b0             ;
            block_12_cal_tdata      <= 128'b00000000    ;
            block_12_cal2_tvalid    <= 1'b0             ;
            block_12_cal2_tdata     <= 128'b00000000    ;
            block_13_en             <= 1'b0             ;
            block_13_input_sel_a    <= 3'b000           ;
            block_13_input_sel_b    <= 3'b000           ;
            block_13_output_sel     <= 3'b000           ;
            block_14_en             <= 1'b0             ;
            block_14_input_sel_a    <= 3'b000           ;
            block_14_input_sel_b    <= 3'b000           ;
            block_14_output_sel     <= 3'b000           ;
        end
        else begin
            case (configs_reg2)
                4'd0: begin    // Softmax
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ; // To West (block_11)

                    block_11_en             <= 2'b01            ; // Normal-cal
                    block_11_input_sel_a    <= 4'b1000          ; // From FIFO
                    block_11_input_sel_b    <= 3'b001           ; // From East
                    block_11_add_output_sel <= 3'b010           ; // To North (block_01)
                    block_11_mul_output_sel <= 3'b000           ; // Not Use
                    block_11_cal_tvalid     <= 1'b0             ; // Not Use
                    block_11_cal_tdata      <= 128'h00000000    ;

                    block_12_en             <= 3'b000           ; // Not Use
                    block_12_input_sel_a    <= 3'b000           ;
                    block_12_input_sel_b    <= 3'b000           ;
                    block_12_add_output_sel <= 3'b000           ;
                    block_12_mul_output_sel <= 3'b000           ;
                    block_12_cal_tvalid     <= 1'b0             ;
                    block_12_cal_tdata      <= 32'h00000000     ;
                    block_12_cal2_tvalid    <= 1'b0             ;
                    block_12_cal2_tdata     <= 32'h00000000     ;

                    block_13_en             <= 1'b0             ; // Not Use
                    block_13_input_sel_a    <= 3'b000           ;
                    block_13_input_sel_b    <= 3'b000           ;
                    block_13_output_sel     <= 3'b000           ;

                    block_14_en             <= 1'b1             ;
                    block_14_input_sel_a    <= 3'b001           ; // From East (block_03)
                    block_14_input_sel_b    <= 3'b010           ; // From North (FIFO2)
                    block_14_output_sel     <= 3'b001           ; // To West (Outside)
                end
                4'd1: begin    // LayerNorm
                    block_10_en             <= 1'b1             ;
                    block_10_output_sel     <= 2'b01            ; // To West (block_11)

                    block_11_en             <= 2'b10            ; // Self-cal
                    block_11_input_sel_a    <= 4'b0000          ; // Not Use
                    block_11_input_sel_b    <= 3'b000           ; // Not Use
                    block_11_add_output_sel <= 3'b010           ; // To North (block_01)
                    block_11_mul_output_sel <= 3'b001           ; // To West (block_12)
                    block_11_cal_tvalid     <= 1'b1             ;
                    block_11_cal_tdata      <= {32'h3AAAAAAB, 32'h3AAAAAAB, 32'h3AAAAAAB, 32'h3AAAAAAB}     ; // 1/768

                    block_12_en             <= 3'b010           ; // Self-cal-1
                    block_12_input_sel_a    <= 3'b000           ; // Not Use
                    block_12_input_sel_b    <= 3'b000           ; // Not Use
                    block_12_add_output_sel <= 3'b001           ; // To West (block_13)
                    block_12_mul_output_sel <= 3'b000           ; // Not Use
                    block_12_cal_tvalid     <= 1'b1             ;
                    block_12_cal_tdata      <= 32'h3AAAAAAB     ; // 1/768
                    block_12_cal2_tvalid    <= 1'b1             ;
                    block_12_cal2_tdata     <= 32'h3727C5AC     ; // 10e-6

                    block_13_en             <= 1'b1             ;
                    block_13_input_sel_a    <= 3'b001           ; // From East (block_12)
                    block_13_input_sel_b    <= 3'b000           ; // Not Use
                    block_13_output_sel     <= 3'b001           ; // To West (block_14)

                    block_14_en             <= 1'b1             ;
                    block_14_input_sel_a    <= 3'b100           ; // From South (block_13)
                    block_14_input_sel_b    <= 3'b010           ; // From North (FIFO2)
                    block_14_output_sel     <= 3'b001           ; // To West (Outside)
                end
                4'd2: begin    // RMSNorm
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ; // To West (block_11)

                    block_11_en             <= 2'b00            ; // Not Use
                    block_11_input_sel_a    <= 4'b0000          ; // Not Use
                    block_11_input_sel_b    <= 3'b000           ; // Not Use
                    block_11_add_output_sel <= 3'b000           ; // Not Use
                    block_11_mul_output_sel <= 3'b000           ; // Not Use
                    block_11_cal_tvalid     <= 1'b0             ;
                    block_11_cal_tdata      <= 32'h00000000     ;

                    block_12_en             <= 3'b100           ; // Self-cal-2
                    block_12_input_sel_a    <= 3'b000           ; // Not Use
                    block_12_input_sel_b    <= 3'b000           ; // Not Use
                    block_12_add_output_sel <= 3'b001           ; // To West (block_13)
                    block_12_mul_output_sel <= 3'b000           ; // Not Use
                    block_12_cal_tvalid     <= 1'b1             ;
                    block_12_cal_tdata      <= 32'h3AAAAAAB     ; // 1/768
                    block_12_cal2_tvalid    <= 1'b1             ;
                    block_12_cal2_tdata     <= 32'h3727C5AC     ; // 10e-6

                    block_13_en             <= 1'b1             ;
                    block_13_input_sel_a    <= 3'b001           ; // From East (block_12)
                    block_13_input_sel_b    <= 3'b000           ; // Not Use
                    block_13_output_sel     <= 3'b001           ; // To West (block_14)

                    block_14_en             <= 1'b1             ;
                    block_14_input_sel_a    <= 3'b100           ; // From South (block_13)
                    block_14_input_sel_b    <= 3'b010           ; // From North (FIFO2)
                    block_14_output_sel     <= 3'b001           ; // To West (Outside)
                end
                4'd3: begin    // SILU
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ; // To West (block_11)

                    block_11_en             <= 2'b01            ; // Normal-cal
                    block_11_input_sel_a    <= 4'b0010          ; // From North
                    block_11_input_sel_b    <= 3'b100           ; // From South
                    block_11_add_output_sel <= 3'b001           ; // To West (block_12)
                    block_11_mul_output_sel <= 3'b000           ; // Not Use
                    block_11_cal_tvalid     <= 1'b1             ;
                    block_11_cal_tdata      <= {32'h3F800000, 32'h3F800000, 32'h3F800000, 32'h3F800000}     ; // 1

                    block_12_en             <= 3'b000           ; // By Pass
                    block_12_input_sel_a    <= 3'b001           ; // From East
                    block_12_input_sel_b    <= 3'b000           ; // Not Use
                    block_12_add_output_sel <= 3'b000           ; // Not Use
                    block_12_mul_output_sel <= 3'b000           ; // Not Use
                    block_12_cal_tvalid     <= 1'b0             ;
                    block_12_cal_tdata      <= 32'h00000000     ;
                    block_12_cal2_tvalid    <= 1'b0             ;
                    block_12_cal2_tdata     <= 32'h00000000     ;

                    block_13_en             <= 1'b0             ; // Not Use
                    block_13_input_sel_a    <= 3'b000           ;
                    block_13_input_sel_b    <= 3'b000           ;
                    block_13_output_sel     <= 3'b000           ;

                    block_14_en             <= 1'b1             ;
                    block_14_input_sel_a    <= 3'b001           ; // From East (block_03)
                    block_14_input_sel_b    <= 3'b010           ; // From North (FIFO1)
                    block_14_output_sel     <= 3'b001           ; // To West (Outside)
                end
                4'd4: begin    // GELU
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ; // To West (block_11)

                    block_11_en             <= 2'b01            ; // Normal-cal
                    block_11_input_sel_a    <= 3'b010           ; // From North
                    block_11_input_sel_b    <= 3'b100           ; // From South
                    block_11_add_output_sel <= 3'b001           ; // To West (block_12)
                    block_11_mul_output_sel <= 3'b000           ; // Not Use
                    block_11_cal_tvalid     <= 1'b1             ;
                    block_11_cal_tdata      <= {32'h3F800000, 32'h3F800000, 32'h3F800000, 32'h3F800000}     ; // 1

                    block_12_en             <= 3'b000           ; // By Pass
                    block_12_input_sel_a    <= 3'b001           ; // From East
                    block_12_input_sel_b    <= 3'b000           ; // Not Use
                    block_12_add_output_sel <= 3'b000           ; // Not Use
                    block_12_mul_output_sel <= 3'b000           ; // Not Use
                    block_12_cal_tvalid     <= 1'b0             ;
                    block_12_cal_tdata      <= 32'h00000000     ;
                    block_12_cal2_tvalid    <= 1'b0             ;
                    block_12_cal2_tdata     <= 32'h00000000     ;

                    block_13_en             <= 1'b0             ; // Not Use
                    block_13_input_sel_a    <= 3'b000           ;
                    block_13_input_sel_b    <= 3'b000           ;
                    block_13_output_sel     <= 3'b000           ;

                    block_14_en             <= 1'b1             ;
                    block_14_input_sel_a    <= 3'b001           ; // From East (block_03)
                    block_14_input_sel_b    <= 3'b010           ; // From North (FIFO1)
                    block_14_output_sel     <= 3'b001           ; // To West (Outside)
                end
                4'd5: begin    // ADD
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ;

                    block_11_en             <= 2'b01            ; // Normal-cal
                    block_11_input_sel_a    <= 3'b010           ; // From North
                    block_11_input_sel_b    <= 3'b100           ; // From South
                    block_11_add_output_sel <= 3'b010           ; // To North (block_01)
                    block_11_mul_output_sel <= 3'b000           ;
                    block_11_cal_tvalid     <= 1'b0             ;
                    block_11_cal_tdata      <= 128'b0           ;

                    block_12_en             <= 3'b000           ; // Not Use
                    block_12_input_sel_a    <= 3'b000           ;
                    block_12_input_sel_b    <= 3'b000           ;
                    block_12_add_output_sel <= 3'b000           ;
                    block_12_mul_output_sel <= 3'b000           ;
                    block_12_cal_tvalid     <= 1'b0             ;
                    block_12_cal_tdata      <= 32'h00000000     ;
                    block_12_cal2_tvalid    <= 1'b0             ;
                    block_12_cal2_tdata     <= 32'h00000000     ;

                    block_13_en             <= 1'b0             ; // Not Use
                    block_13_input_sel_a    <= 3'b000           ;
                    block_13_input_sel_b    <= 3'b000           ;
                    block_13_output_sel     <= 3'b000           ;

                    block_14_en             <= 1'b0             ; // By Pass
                    block_14_input_sel_a    <= 3'b001           ; // From East (block_03)
                    block_14_input_sel_b    <= 3'b000           ;
                    block_14_output_sel     <= 3'b000           ;
                end
                4'd6: begin    // MUL
                    block_10_en             <= 1'b0             ; // Not Use
                    block_10_output_sel     <= 2'b00            ;

                    block_11_en             <= 2'b01            ; // Not Use
                    block_11_input_sel_a    <= 3'b000           ;
                    block_11_input_sel_b    <= 3'b000           ;
                    block_11_add_output_sel <= 3'b000           ;
                    block_11_mul_output_sel <= 3'b000           ;
                    block_11_cal_tvalid     <= 1'b0             ;
                    block_11_cal_tdata      <= 128'b0           ;

                    block_12_en             <= 3'b000           ; // Not Use
                    block_12_input_sel_a    <= 3'b000           ;
                    block_12_input_sel_b    <= 3'b000           ;
                    block_12_add_output_sel <= 3'b000           ;
                    block_12_mul_output_sel <= 3'b000           ;
                    block_12_cal_tvalid     <= 1'b0             ;
                    block_12_cal_tdata      <= 32'h00000000     ;
                    block_12_cal2_tvalid    <= 1'b0             ;
                    block_12_cal2_tdata     <= 32'h00000000     ;

                    block_13_en             <= 1'b0             ; // Not Use
                    block_13_input_sel_a    <= 3'b000           ;
                    block_13_input_sel_b    <= 3'b000           ;
                    block_13_output_sel     <= 3'b000           ;

                    block_14_en             <= 1'b0             ; // By Pass
                    block_14_input_sel_a    <= 3'b001           ; // From East (block_03)
                    block_14_input_sel_b    <= 3'b000           ;
                    block_14_output_sel     <= 3'b000           ;
                end
            default: begin
                block_10_en             <= 1'b0             ;
                block_10_output_sel     <= 2'b00            ;
                block_11_en             <= 2'b00            ;
                block_11_input_sel_a    <= 3'b000           ;
                block_11_input_sel_b    <= 3'b000           ;
                block_11_add_output_sel <= 3'b000           ;
                block_11_mul_output_sel <= 3'b000           ;
                block_11_cal_tvalid     <= 1'b0             ;
                block_11_cal_tdata      <= 128'b00000000    ;
                block_12_en             <= 3'b000           ;
                block_12_input_sel_a    <= 3'b000           ;
                block_12_input_sel_b    <= 3'b000           ;
                block_12_add_output_sel <= 3'b000           ;
                block_12_mul_output_sel <= 3'b000           ;
                block_12_cal_tvalid     <= 1'b0             ;
                block_12_cal_tdata      <= 128'b00000000    ;
                block_12_cal2_tvalid    <= 1'b0             ;
                block_12_cal2_tdata     <= 128'b00000000    ;
                block_13_en             <= 1'b0             ;
                block_13_input_sel_a    <= 3'b000           ;
                block_13_input_sel_b    <= 3'b000           ;
                block_13_output_sel     <= 3'b000           ;
                block_14_en             <= 1'b0             ;
                block_14_input_sel_a    <= 3'b000           ;
                block_14_input_sel_b    <= 3'b000           ;
                block_14_output_sel     <= 3'b000           ;
            end
            endcase
        end
    end

    //============================ BLOCK 00 ============================
    assign block_00_in_tvalid = input_atvalid_reg            ;
    assign block_00_in_tdata  = input_atdata_reg             ;

    // Input : From Outside.
    // Output: South(10)(Softmax/LayerNorm/SiLu/Gelu) or West(01)(LayerNorm/RMSNorm).
    max_block block_00
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_00_en                   ),
        .output_sel          (block_00_output_sel           ),
        .input_atvalid       (block_00_in_tvalid            ),
        .input_atdata        (block_00_in_tdata             ),
        .west_output_atvalid (block_00_west_out_tvalid      ),
        .west_output_atdata  (block_00_west_out_tdata       ),
        .south_output_atvalid(block_00_south_out_tvalid     ),
        .south_output_atdata (block_00_south_out_tdata      )
    );

    //============================ BLOCK 01 ============================
    assign block_01_east_in_tvalid  = (configs_reg <= 4'd5) ? block_00_west_out_tvalid  : (configs_reg == 4'd6) ? input_atvalid_reg : 1'b0 ;
    assign block_01_east_in_tdata   = (configs_reg <= 4'd5) ? block_00_west_out_tdata   : (configs_reg == 4'd6) ? input_atdata_reg  : 128'b0 ;
    assign block_01_south_in_tvalid = (configs_reg <= 4'd5) ? block_11_north_out_tvalid : (configs_reg == 4'd6) ? input_btvalid_reg : 1'b0 ;
    assign block_01_south_in_tdata  = (configs_reg <= 4'd5) ? block_11_north_out_tdata  : (configs_reg == 4'd6) ? input_btdata_reg  : 128'b0 ;
    // Input : From block_00/block_11.
    // Output: North(FIFO)(Softmax/LayerNorm) and West(02)(Softmax/LayerNorm/RMSNorm/SILU/GELU).
    squre_exp_block block_01
    (
        .clk                 (clk                       ),
        .rst_n               (rst_n && ~init_transfer   ),
        .stage_start         (stage_start_reg           ),
        .block_en            (block_01_en               ),
        .input_sel_a         (block_01_input_sel_a      ),
        .input_sel_b         (block_01_input_sel_b      ),
        .squ_output_sel      (block_01_squ_output_sel   ),
        .exp_output_sel      (block_01_exp_output_sel   ),
        .east_in_tvalid      (block_01_east_in_tvalid   ) ,
        .east_in_tdata       (block_01_east_in_tdata    ) ,
        .west_out_tvalid     (block_01_west_out_tvalid  ) ,
        .west_out_tdata      (block_01_west_out_tdata   ) ,
        .mul_tvalid          (block_01_cal_tvalid       ) ,
        .mul_tdata           (block_01_cal_tdata        ) ,
        .north_out_tvalid    (block_01_north_out_tvalid ) ,
        .north_out_tdata     (block_01_north_out_tdata  ) ,
        .south_in_tvalid     (block_01_south_in_tvalid  ) ,
        .south_in_tdata      (block_01_south_in_tdata   ) ,
        .south_out_tvalid    (block_01_south_out_tvalid ) ,
        .south_out_tdata     (block_01_south_out_tdata  ) 
    );

    // ========================= Write FIFO 2 ==========================
    assign fifo2_wr_en = (configs_reg == 0) ? block_01_north_out_tvalid : (configs_reg == 1) ? block_11_north_out_tvalid : 1'b0;
    assign fifo2_din   = (configs_reg == 0) ? block_01_north_out_tdata  : (configs_reg == 1) ? block_11_north_out_tdata  : 128'b0;

    //============================ BLOCK 02 ============================
    assign block_02_in_tvalid  = ((configs_reg == 3) || (configs_reg == 4)) ? block_12_north_out_tvalid : block_01_west_out_tvalid       ;
    assign block_02_in_tdata   = ((configs_reg == 3) || (configs_reg == 4)) ? block_12_north_out_tdata : block_01_west_out_tdata        ;
    // Input : From block_01.
    // Output: South(12)(Softmax/LayerNorm/RMSNorm/SILU/GELU).
    acc_block block_02
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_02_en                   ),
        .output_sel          (block_02_output_sel           ),
        .input_atvalid       (block_02_in_tvalid            ),
        .input_atdata        (block_02_in_tdata             ),
        .west_output_atvalid (block_02_west_out_tvalid      ),
        .west_output_atdata  (block_02_west_out_tdata       ),
        .south_output_atvalid(block_02_south_out_tvalid     ),
        .south_output_atdata (block_02_south_out_tdata      )
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) 
            block_02_sum_en <= 1'b0;
        else if (block_02_west_out_tvalid)
            block_02_sum_en <= 1'b1;
        else if ((block_02_sum_cnt == DATA_NUM - 10'd1)&&(block_02_west_out_tvalid == 1'b0))
            block_02_sum_en <= 1'b0;
        else
            block_02_sum_en <= block_02_sum_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) 
            block_02_sum_cnt <= 10'd0;
        else if (block_02_sum_cnt == DATA_NUM - 10'd1)
            block_02_sum_cnt <= 10'd0;
        else if (block_02_sum_en) 
            block_02_sum_cnt <= block_02_sum_cnt + 10'd1;
        else
            block_02_sum_cnt <= block_02_sum_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) 
            block_02_sum_tdata_out <= 128'h0;
        else if (block_02_west_out_tvalid)
            block_02_sum_tdata_out <= block_02_west_out_tdata;
        else
            block_02_sum_tdata_out <= block_02_sum_tdata_out;
    end

    //============================ BLOCK 03 ============================
    assign block_03_east_in_tvalid  = block_02_sum_en               ;
    assign block_03_east_in_tdata   = block_02_sum_tdata_out        ;
    assign block_03_north_in_tvalid = 1'b0                          ;
    assign block_03_north_in_tdata  = 128'b0                        ;
    assign block_03_south_in_tvalid = block_13_north_out_tvalid     ;
    assign block_03_south_in_tdata  = {block_13_north_out_tdata, block_13_north_out_tdata, block_13_north_out_tdata, block_13_north_out_tdata}      ;
    // Input : From block_02/block_13.
    // Output: West(14)(Softmax/SILU/GELU).
    basic_block_x4 #(
        .pattern            ("REC")
    )
    block_03
    (
        .clk                (clk                        ) ,
        .rst_n              (rst_n && ~init_transfer    ) ,
        .stage_start        (stage_start_reg            ) ,
        .block_en           (block_03_en                ) ,
        .input_sel_a        (block_03_input_sel_a       ) ,
        .input_sel_b        (block_03_input_sel_b       ) ,
        .output_sel         (block_03_output_sel        ) ,
        .east_in_tvalid     (block_03_east_in_tvalid    ) ,
        .east_in_tdata      (block_03_east_in_tdata     ) ,
        .west_out_tvalid    (block_03_west_out_tvalid   ) ,
        .west_out_tdata     (block_03_west_out_tdata    ) ,
        .north_in_tvalid    (block_03_north_in_tvalid   ) ,
        .north_in_tdata     (block_03_north_in_tdata    ) ,
        .north_out_tvalid   (block_03_north_out_tvalid  ) ,
        .north_out_tdata    (block_03_north_out_tdata   ) ,
        .south_in_tvalid    (block_03_south_in_tvalid   ) ,
        .south_in_tdata     (block_03_south_in_tdata    ) ,
        .south_out_tvalid   (block_03_south_out_tvalid  ) ,
        .south_out_tdata    (block_03_south_out_tdata   ) 
    );

    // ================ Read FIFO 1 and MAX out counter ================
    assign fifo1_rd_en = (configs_reg == 0) ? block_10_west_out_tvalid : (configs_reg == 1) ? block_11_fifo_read_en : (configs_reg == 2) ? block_13_west_out_tvalid : block_03_west_out_tvalid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            fifo1_rden_reg_delay1 <= 1'b0;   
            block_10_west_out_tvalid_delay1 <= 1'b0;
            block_10_west_out_tdata_delay1  <= 128'b0;
        end
        else begin
            fifo1_rden_reg_delay1 <= fifo1_rd_en;
            block_10_west_out_tvalid_delay1 <= block_10_west_out_tvalid;
            block_10_west_out_tdata_delay1 <= block_10_west_out_tdata;
        end
    end

    //============================ BLOCK 10 ============================
    assign block_10_in_tvalid  = block_00_south_out_tvalid   ;
    assign block_10_in_tdata   = block_00_south_out_tdata    ;
    // Input : From block_00.
    // Output: West(11)(Softmax/SILU/GELU), South(LayerNorm).
    acc_block block_10
    (
        .clk                 (clk                           ),
        .rst_n               (rst_n && ~init_transfer       ),
        .stage_start         (stage_start_reg               ),
        .block_en            (block_10_en                   ),
        .output_sel          (block_10_output_sel           ),
        .input_atvalid       (block_10_in_tvalid            ),
        .input_atdata        (block_10_in_tdata             ),
        .west_output_atvalid (block_10_west_out_tvalid      ),
        .west_output_atdata  (block_10_west_out_tdata       ),
        .south_output_atvalid(block_10_south_out_tvalid     ),
        .south_output_atdata (block_10_south_out_tdata      )
    );

    //============================ BLOCK 11 ============================
    assign block_11_east_in_tvalid  = block_10_west_out_tvalid_delay1   ;
    assign block_11_east_in_tdata   = (configs_reg == 0) ? {~block_10_west_out_tdata_delay1[127], block_10_west_out_tdata_delay1[126:96], ~block_10_west_out_tdata_delay1[95], block_10_west_out_tdata_delay1[94:64], ~block_10_west_out_tdata_delay1[63], block_10_west_out_tdata_delay1[62:32], ~block_10_west_out_tdata_delay1[31], block_10_west_out_tdata_delay1[30:0]} : block_10_west_out_tdata_delay1 ;
    assign block_11_north_in_tvalid = (configs_reg <= 4'd4) ? block_01_south_out_tvalid : (configs_reg == 4'd5) ? input_atvalid_reg : 1'b0 ;
    assign block_11_north_in_tdata  = (configs_reg <= 4'd4) ? block_01_south_out_tdata  : (configs_reg == 4'd5) ? input_atdata_reg  : 128'b0 ;
    assign block_11_south_in_tvalid = (configs_reg <= 4'd4) ? block_11_cal_tvalid       : (configs_reg == 4'd5) ? input_btvalid_reg : 1'b0 ;
    assign block_11_south_in_tdata  = (configs_reg <= 4'd4) ? block_11_cal_tdata        : (configs_reg == 4'd5) ? input_btdata_reg  : 128'b0 ;
    assign block_11_fifo_in_tvalid  = fifo1_rden_reg_delay1             ;
    assign block_11_fifo_in_tdata   = fifo1_dout                        ;
    // Input : From block_10/block_21 and FIFO.
    // Output: North(01)(LayerNorm).
    add_mul_block_x4 block_11
    (
        .clk                (clk                            ) ,
        .rst_n              (rst_n && ~init_transfer        ) ,
        .stage_start        (stage_start_reg                ) ,
        .block_en           (block_11_en                    ) ,
        .input_sel_a        (block_11_input_sel_a           ) ,
        .input_sel_b        (block_11_input_sel_b           ) ,
        .add_output_sel     (block_11_add_output_sel        ),
        .mul_output_sel     (block_11_mul_output_sel        ),
        .east_in_tvalid     (block_11_east_in_tvalid        ) ,
        .east_in_tdata      (block_11_east_in_tdata         ) ,
        .west_out_tvalid    (block_11_west_out_tvalid       ) ,
        .west_out_tdata     (block_11_west_out_tdata        ) ,
        .north_in_tvalid    (block_11_north_in_tvalid       ) ,
        .north_in_tdata     (block_11_north_in_tdata        ) ,
        .north_out_tvalid   (block_11_north_out_tvalid      ) ,
        .north_out_tdata    (block_11_north_out_tdata       ) ,
        .south_in_tvalid    (block_11_south_in_tvalid       ) ,
        .south_in_tdata     (block_11_south_in_tdata        ) ,
        .fifo_read_en       (block_11_fifo_read_en          ),
        .fifo_in_tvalid     (block_11_fifo_in_tvalid        ),
        .fifo_in_tdata      (block_11_fifo_in_tdata         )
    );

    //============================ BLOCK 12 ============================
    assign block_12_north_in_tvalid  = block_02_south_out_tvalid    ;
    assign block_12_north_in_tdata   = block_02_south_out_tdata     ;
    assign block_12_east_in_tvalid   = block_11_west_out_tvalid     ;
    assign block_12_east_in_tdata    = block_11_west_out_tdata      ;
    assign block_12_south_in_tvalid  = 1'b0                         ;
    assign block_12_south_in_tdata   = 128'b0                       ;
    add_mul_block block_12
    (
        .clk                (clk                            ) ,
        .rst_n              (rst_n && ~init_transfer        ) ,
        .stage_start        (stage_start_reg                ) ,
        .block_en           (block_12_en                    ) ,
        .input_sel_a        (block_12_input_sel_a           ) ,
        .input_sel_b        (block_12_input_sel_b           ) ,
        .add_output_sel     (block_12_add_output_sel        ),
        .mul_output_sel     (block_12_mul_output_sel        ),
        .east_in_tvalid     (block_12_east_in_tvalid        ) ,
        .east_in_tdata      (block_12_east_in_tdata         ) ,
        .west_out_tvalid    (block_12_west_out_tvalid       ) ,
        .west_out_tdata     (block_12_west_out_tdata        ) ,
        .north_in_tvalid    (block_12_north_in_tvalid       ) ,
        .north_in_tdata     (block_12_north_in_tdata        ) ,
        .north_out_tvalid   (block_12_north_out_tvalid      ) ,
        .north_out_tdata    (block_12_north_out_tdata       ) ,
        .south_in_tvalid    (block_12_south_in_tvalid       ) ,
        .south_in_tdata     (block_12_south_in_tdata        ) ,
        .mul_tvalid         (block_12_cal_tvalid            ),
        .mul_tdata          (block_12_cal_tdata             ),
        .add_tvalid         (block_12_cal2_tvalid           ),
        .add_tdata          (block_12_cal2_tdata            )
    );

    //============================ BLOCK 13 ============================
    assign block_13_east_in_tvalid  = block_12_west_out_tvalid          ;
    assign block_13_east_in_tdata   = block_12_west_out_tdata           ;
    assign block_13_north_in_tvalid = block_03_south_out_tvalid         ;
    assign block_13_north_in_tdata  = block_03_south_out_tdata[127:96]  ;
    assign block_13_south_in_tvalid = 1'b0                              ;
    assign block_13_south_in_tdata  = 32'b0                             ;
    // Input : From block_12/block_03.
    // Output: North(14)(LayerNorm/RMSNorm).
    basic_block #(
        .pattern            ("RSR")
    )
    block_13
    (
        .clk                (clk                            ) ,
        .rst_n              (rst_n && ~init_transfer        ) ,
        .stage_start        (stage_start_reg                ) ,
        .block_en           (block_13_en                    ) ,
        .input_sel_a        (block_13_input_sel_a           ) ,
        .input_sel_b        (block_13_input_sel_b           ) ,
        .output_sel         (block_13_output_sel            ) ,
        .east_in_tvalid     (block_13_east_in_tvalid        ) ,
        .east_in_tdata      (block_13_east_in_tdata         ) ,
        .west_out_tvalid    (block_13_west_out_tvalid       ) ,
        .west_out_tdata     (block_13_west_out_tdata        ) ,
        .north_in_tvalid    (block_13_north_in_tvalid       ) ,
        .north_in_tdata     (block_13_north_in_tdata        ) ,
        .north_out_tvalid   (block_13_north_out_tvalid      ) ,
        .north_out_tdata    (block_13_north_out_tdata       ) ,
        .south_in_tvalid    (block_13_south_in_tvalid       ) ,
        .south_in_tdata     (block_13_south_in_tdata        ) ,
        .south_out_tvalid   (block_13_south_out_tvalid      ) ,
        .south_out_tdata    (block_13_south_out_tdata       ) 
    );
    
    // ======================== Read FIFO 2 ============================
    assign fifo2_rd_en = (configs_reg == 0) ? block_03_west_out_tvalid: (configs_reg == 1) ? block_13_west_out_tvalid : 1'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            fifo2_rden_reg_delay1 <= 1'b0;
            block_03_west_out_tvalid_delay1 <= 1'b0;
            block_03_west_out_tdata_delay1 <= 128'b0;
            block_13_west_out_tvalid_delay1 <= 1'b0;
            block_13_west_out_tdata_delay1 <= 32'b0;
        end
        else begin
            fifo2_rden_reg_delay1 <= fifo2_rd_en;
            block_03_west_out_tvalid_delay1 <= block_03_west_out_tvalid;
            block_03_west_out_tdata_delay1  <= block_03_west_out_tdata;
            block_13_west_out_tvalid_delay1 <= block_13_west_out_tvalid;
            block_13_west_out_tdata_delay1  <= block_13_west_out_tdata;
        end
    end

    //============================ BLOCK 14 ============================
    assign block_14_east_in_tvalid  = block_03_west_out_tvalid_delay1                                       ;
    assign block_14_east_in_tdata   = block_03_west_out_tdata_delay1                                        ;
    assign block_14_north_in_tvalid = (configs_reg <= 1) ? fifo2_rden_reg_delay1 : fifo1_rden_reg_delay1    ;
    assign block_14_north_in_tdata  = (configs_reg <= 1) ? fifo2_dout            : fifo1_dout               ;
    assign block_14_south_in_tvalid = block_13_west_out_tvalid_delay1                                       ;
    assign block_14_south_in_tdata  = {block_13_west_out_tdata_delay1, block_13_west_out_tdata_delay1, block_13_west_out_tdata_delay1, block_13_west_out_tdata_delay1}  ;
    // Input : From block_02/block_13.
    // Output: North(03)(Softmax/LayerNorm/SILU/GELU).
    basic_block_x4 #(
        .pattern            ("MUL")
    )
    block_14
    (
        .clk                (clk                        ) ,
        .rst_n              (rst_n && ~init_transfer    ) ,
        .stage_start        (stage_start_reg            ) ,
        .block_en           (block_14_en                ) ,
        .input_sel_a        (block_14_input_sel_a       ) ,
        .input_sel_b        (block_14_input_sel_b       ) ,
        .output_sel         (block_14_output_sel        ) ,
        .east_in_tvalid     (block_14_east_in_tvalid    ) ,
        .east_in_tdata      (block_14_east_in_tdata     ) ,
        .west_out_tvalid    (block_14_west_out_tvalid   ) ,
        .west_out_tdata     (block_14_west_out_tdata    ) ,
        .north_in_tvalid    (block_14_north_in_tvalid   ) ,
        .north_in_tdata     (block_14_north_in_tdata    ) ,
        .north_out_tvalid   (block_14_north_out_tvalid  ) ,
        .north_out_tdata    (block_14_north_out_tdata   ) ,
        .south_in_tvalid    (block_14_south_in_tvalid   ) ,
        .south_in_tdata     (block_14_south_in_tdata    ) ,
        .south_out_tvalid   (block_14_south_out_tvalid  ) ,
        .south_out_tdata    (block_14_south_out_tdata   ) 
    );

    assign result_tvalid = block_14_west_out_tvalid;
    assign result_tdata = block_14_west_out_tdata;

endmodule