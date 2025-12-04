// This module converts parallel input data into serial output data.

module DOUT_TRANS #(
    parameter integer DATA_NUM = 192
)
(
    // Global Signals
    input  wire         axi_ACLK                ,
    input  wire         axi_ARESETN             ,
    input  wire         stage_start             ,
    // AXI4-FULL Write DATA Channel
    output wire [31:0]  write_data              ,
    output wire         write_enable            ,
    input  wire         write_ready             ,
    // BRAM Write DATA Port
    output wire         bram_enb    [15:0]      ,
    output wire [13:0]  bram_addrb  [15:0]      ,
    input  wire [63:0]  bram_doutb  [15:0]      
);

    reg     [8:0]       data_out_counter;
    reg     [3:0]       bram_sel;
    reg     [3:0]       bram_sel_reg;
    reg     [6:0]       row_num;

    wire    [31:0]      axi_write_data      [15:0]      ;
    wire    [15:0]      axi_write_enable                ;

    wire init_transfer;
    wire axi_write_enable_total;

    reg init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    assign axi_write_enable_total = |axi_write_enable;

    always @(posedge axi_ACLK) begin                                                                        
        // Initiates AXI transaction delay    
        if (axi_ARESETN == 0) begin                                                                    
            init_txn_ff <= 1'b0;                                                                    
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    always @(posedge axi_ACLK) begin
        if(!axi_ARESETN || init_transfer) begin
            data_out_counter <= 9'd0;
            row_num <= 7'b0;
        end
        else if((data_out_counter + 1)>>1 == DATA_NUM)begin
            data_out_counter <= 9'd0;
            row_num <= row_num + 1'b1;
        end
        else if(axi_write_enable_total)
            data_out_counter <= data_out_counter + 9'd1;
        else
            data_out_counter <= data_out_counter;
    end

    always @(posedge axi_ACLK) begin
        if(!axi_ARESETN || init_transfer)
            bram_sel <= 4'd0;
        else if(row_num < 7'd4)
            bram_sel <= 4'd0;
        else if((row_num >= 7'd4) && (row_num < 7'd8))
            bram_sel <= 4'd1;
        else if((row_num >= 7'd8) && (row_num < 7'd12))
            bram_sel <= 4'd2;
        else if((row_num >= 7'd12) && (row_num < 7'd16))
            bram_sel <= 4'd3;
        else if((row_num >= 7'd16) && (row_num < 7'd20))
            bram_sel <= 4'd4;
        else if((row_num >= 7'd20) && (row_num < 7'd24))
            bram_sel <= 4'd5;
        else if((row_num >= 7'd24) && (row_num < 7'd28))
            bram_sel <= 4'd6;
        else if((row_num >= 7'd28) && (row_num < 7'd32))
            bram_sel <= 4'd7;
        else if((row_num >= 7'd32) && (row_num < 7'd36))
            bram_sel <= 4'd8;
        else if((row_num >= 7'd36) && (row_num < 7'd40))
            bram_sel <= 4'd9;
        else if((row_num >= 7'd40) && (row_num < 7'd44))
            bram_sel <= 4'd10;
        else if((row_num >= 7'd44) && (row_num < 7'd48))
            bram_sel <= 4'd11;
        else if((row_num >= 7'd48) && (row_num < 7'd52))
            bram_sel <= 4'd12;
        else if((row_num >= 7'd52) && (row_num < 7'd56))
            bram_sel <= 4'd13;
        else if((row_num >= 7'd56) && (row_num < 7'd60))
            bram_sel <= 4'd14;
        else if((row_num >= 7'd60) && (row_num < 7'd64))
            bram_sel <= 4'd15;
        else
            bram_sel <= bram_sel;
    end

    always @(posedge axi_ACLK) begin                                                                          
        if (axi_ARESETN == 0) begin                                                                    
            bram_sel_reg <= 4'b0;                                                                          
        end                                                                               
        else begin  
            bram_sel_reg <= bram_sel;                                                          
        end                                                                      
	end

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin: gen_bram_interface
            BR2AW out_BR2AW (
                .axi_ACLK        (axi_ACLK                          ),
                .axi_ARESETN     (axi_ARESETN                       ),
                .stage_start     (stage_start && (bram_sel == i)    ),
                .write_data      (axi_write_data[i]                 ),
                .write_enable    (axi_write_enable[i]               ),
                .write_ready     (write_ready                       ),
                .bram_enb        (bram_enb[i]                       ),
                .bram_addrb      (bram_addrb[i]                     ),
                .bram_doutb      (bram_doutb[i]                     )
            );
        end
    endgenerate

    assign write_data   = axi_write_data[bram_sel_reg];
    assign write_enable = axi_write_enable[bram_sel_reg];


endmodule