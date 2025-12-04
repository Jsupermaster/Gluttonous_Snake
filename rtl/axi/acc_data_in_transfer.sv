module ACC_DIN_TRANS #(
    parameter integer DATA_NUM = 768
)
(
    input   wire            clk                         ,
    input   wire            rst_n                       ,
    
    input   wire            stage_start                 ,
    input   wire [31:0]     configs                     ,
    // BRAM interface
    output  wire            in_bram_enb     [15:0]      ,
    output  wire [13:0]     in_bram_addrb   [15:0]      ,
    input   wire [63:0]     in_bram_doutb   [15:0]      ,
    
    // AXI-Stream interface
    output  reg  [63:0]     full_atdata     [7:0]       ,
    output  reg             full_atvalid    [7:0]       ,
    output  reg  [63:0]     tiny_atdata     [7:0]       ,
    output  reg             tiny_atvalid    [7:0]       
);

    wire    init_transfer;
    reg     init_txn_ff;
    assign  init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk) begin                                                                         
        if (!rst_n) begin                                                                    
            init_txn_ff <= 1'b0;    
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    reg                 stage_start_reg             ;
    reg     [9:0]       data_in_counter             ;
    reg                 row_4_done                  ;
    reg     [1:0]       sel_pattern                 ;
    reg     [1:0]       sel_pattern_delay1          ;
    reg     [1:0]       sel_pattern_delay2          ;
    reg     [1:0]       sel_pattern_delay3          ;
    wire    [63:0]      front_a_tdata     [15:0]    ;
    wire    [15:0]      front_a_tvalid              ;

    always @(posedge clk) begin
        if (!rst_n) begin
            stage_start_reg <= 1'b0;
        end
        else begin
            stage_start_reg <= stage_start;
        end
    end

    always @(posedge clk) begin
        if(!rst_n || init_transfer) begin
            data_in_counter <= 10'd0;
            row_4_done <= 1'b0;
        end
        else if(data_in_counter == DATA_NUM) begin
            data_in_counter <= data_in_counter;
        end
        else if(data_in_counter == DATA_NUM - 10'd1)begin
            data_in_counter <= data_in_counter + 10'd1;
            row_4_done <= ~row_4_done;
        end
        else if(stage_start_reg) 
            data_in_counter <= data_in_counter + 10'd1;
        else
            data_in_counter <= data_in_counter;
    end

    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            sel_pattern <= 2'b00;
        end
        else begin
            if ((configs <= 2) && (stage_start_reg)) begin
                if (~row_4_done) begin
                    sel_pattern <= 2'b01;
                end
                else begin
                    sel_pattern <= 2'b10;
                end
            end
            else begin
                sel_pattern <= 2'b11;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            sel_pattern_delay1 <= 1'b0;
            sel_pattern_delay2 <= 1'b0;
            sel_pattern_delay3 <= 1'b0;
        end
        else begin
            sel_pattern_delay1 <= sel_pattern;
            sel_pattern_delay2 <= sel_pattern_delay1;
            sel_pattern_delay3 <= sel_pattern_delay2;
        end
    end

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : BR2AS_array_1
            BR2AS ACC_BR2AS(
                .clk                (clk                                ),
                .rst_n              (rst_n                              ),
                .stage_start        (stage_start_reg && sel_pattern[0]  ),
                .in_bram_enb        (in_bram_enb   [i]                  ),
                .in_bram_addrb      (in_bram_addrb [i]                  ),
                .in_bram_doutb      (in_bram_doutb [i]                  ),
                .a_tdata            (front_a_tdata [i]                  ),
                .a_tvalid           (front_a_tvalid[i]                  )
            );
        end
    endgenerate

    generate
        for (i = 8; i < 16; i = i + 1) begin : BR2AS_array_2
            BR2AS ACC_BR2AS(
                .clk                (clk                                ),
                .rst_n              (rst_n                              ),
                .stage_start        (stage_start_reg && sel_pattern[1]  ),
                .in_bram_enb        (in_bram_enb    [i]                 ),
                .in_bram_addrb      (in_bram_addrb  [i]                 ),
                .in_bram_doutb      (in_bram_doutb  [i]                 ),
                .a_tdata            (front_a_tdata  [i]                 ),
                .a_tvalid           (front_a_tvalid [i]                 )
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin: acc_data_in_array_1
            always @(posedge clk) begin
                if (!rst_n) begin
                    full_atdata [i] <= 64'b0;
                    full_atvalid[i] <= 1'b0;
                end
                else if (configs <= 2) begin
                    if (sel_pattern_delay3[0] && ~sel_pattern_delay3[1]) begin
                        full_atdata [i] <=  front_a_tdata  [i];
                        full_atvalid[i] <=  front_a_tvalid [i];
                    end
                    else if (sel_pattern_delay3[1] && ~sel_pattern_delay3[0]) begin
                        full_atdata [i] <=  front_a_tdata  [i+8];
                        full_atvalid[i] <=  front_a_tvalid [i+8];
                    end
                end
                else begin
                    full_atdata [i] <=  front_a_tdata  [i];
                    full_atvalid[i] <=  front_a_tvalid [i];
                end
            end
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin: acc_data_in_array_2
            always @(posedge clk) begin
                if (!rst_n) begin
                    tiny_atdata [i] <= 64'b0;
                    tiny_atvalid[i] <= 1'b0;
                end
                else if (configs > 2) begin
                    tiny_atdata [i] <=  front_a_tdata  [i+8];
                    tiny_atvalid[i] <=  front_a_tvalid [i+8];
                end
            end
        end
    endgenerate

endmodule