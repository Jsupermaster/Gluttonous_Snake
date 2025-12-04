module ACC_DOUT_TRANS #(
    parameter integer DATA_NUM = 768
)
(
    input   wire                clk                     ,
    input   wire                rst_n                   ,
    input   wire                stage_start             ,
    input   wire    [31:0]      configs                 ,

    // AXI-Stream interface
    input   wire    [63:0]      full_atdata     [7:0]   ,
    input   wire                full_atvalid    [7:0]   ,
    input   wire    [63:0]      tiny_atdata     [7:0]   ,
    input   wire                tiny_atvalid    [7:0]   , 

    // BRAM interface
    output  wire                out_bram_wea    [15:0]  ,
    output  wire    [13:0]      out_bram_addra  [15:0]  ,
    output  wire    [63:0]      out_bram_dina   [15:0]  ,
    output  wire                stage_done
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
    reg     [1:0]       sel_pattern_reg             ;
    reg     [1:0]       sel_pattern_reg2            ;
    reg     [63:0]      front_a_tdata     [15:0]    ;
    reg     [15:0]      front_a_tvalid              ;

    wire    [15:0]      out_bram_wdone              ;

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
        else if(data_in_counter == DATA_NUM - 10'd2)begin
            data_in_counter <= data_in_counter + 10'd1;
            row_4_done <= ~row_4_done;
        end
        else if(full_atvalid[0]) 
            data_in_counter <= data_in_counter + 10'd1;
        else
            data_in_counter <= data_in_counter;
    end

    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            sel_pattern <= 2'b00;
        end
        else begin
            if ((configs <= 6) && (stage_start_reg)) begin
                if (~row_4_done) begin
                    sel_pattern <= 2'b01;
                end
                else begin
                    sel_pattern <= 2'b10;
                end
            end
            else begin
                sel_pattern <= sel_pattern;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            sel_pattern_reg <= 1'b0;
        end
        else begin
            sel_pattern_reg <= sel_pattern;
        end
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : out_AS2BW_array_1
            AS2BW out_AS2BW(
                .clk            (clk                                ),
                .rst_n          (rst_n                              ),
                .stage_start    (stage_start_reg                    ),
                .a_tdata        (front_a_tdata [i]                  ),
                .a_tvalid       (front_a_tvalid[i]                  ),
                .out_bram_wea   (out_bram_wea[i]                    ),
                .out_bram_addra (out_bram_addra[i]                  ),
                .out_bram_dina  (out_bram_dina[i]                   ),
                .stage_done     (out_bram_wdone[i]                  )
            );
        end
    endgenerate

    generate
        for (i = 8; i < 16; i = i + 1) begin : out_AS2BW_array_2
            AS2BW out_AS2BW(
                .clk            (clk                                ),
                .rst_n          (rst_n                              ),
                .stage_start    (stage_start_reg                    ),
                .a_tdata        (front_a_tdata [i]                  ),
                .a_tvalid       (front_a_tvalid[i]                  ),
                .out_bram_wea   (out_bram_wea[i]                    ),
                .out_bram_addra (out_bram_addra[i]                  ),
                .out_bram_dina  (out_bram_dina[i]                   ),
                .stage_done     (out_bram_wdone[i]                  )
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin: acc_data_in_array_1
            always @(posedge clk) begin
                if (!rst_n) begin
                    front_a_tdata [i] <= 64'b0;
                    front_a_tvalid[i] <= 1'b0;
                end
                else begin
                    if ((configs <= 2) && sel_pattern[0]) begin
                        front_a_tdata [i] <= full_atdata  [i];
                        front_a_tvalid[i] <= full_atvalid [i];
                    end
                    else if ((configs <= 2) && sel_pattern[1]) begin
                        front_a_tdata [i] <= 64'b0;
                        front_a_tvalid[i] <= 1'b0;
                    end
                    else if (configs > 2) begin
                        front_a_tdata [i] <= full_atdata  [i];
                        front_a_tvalid[i] <= full_atvalid [i];
                    end
                end
            end
        end
    endgenerate

    generate
        for (i = 8; i < 16; i = i + 1) begin: acc_data_in_array_2
            always @(posedge clk) begin
                if (!rst_n) begin
                    front_a_tdata [i] <= 64'b0;
                    front_a_tvalid[i] <= 1'b0;
                end
                else begin
                    if ((configs <= 2) && sel_pattern[1]) begin
                        front_a_tdata [i] <= full_atdata  [i-8];
                        front_a_tvalid[i] <= full_atvalid [i-8];
                    end
                    else if (configs >2) begin
                        front_a_tdata [i] <= tiny_atdata [i-8];
                        front_a_tvalid[i] <= tiny_atvalid[i-8];
                    end
                end
            end
        end
    endgenerate

    assign stage_done = &out_bram_wdone;

endmodule