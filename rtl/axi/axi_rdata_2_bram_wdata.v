// this module is for AXI-FULL Read DATA Channel to BRAM write data
// It gets data from AXI4-FULL Read DATA Channel and writes to BRAM interface

module AR2BW #(
    parameter integer TOTAL_NUM = 1536
)
(
    // Global Signals
    input  wire         axi_ACLK    ,
    input  wire         axi_ARESETN ,
    input  wire         stage_start ,
    // AXI4-FULL Read DATA Channel
    input  wire [31:0]  axi_RDATA   ,
    input  wire         axi_RLAST   ,
    input  wire         axi_SHAKE   ,
    // BRAM Write DATA Port
    output wire [0:0]   bram_wea    ,
    output wire [13:0]  bram_addra  ,
    output wire [63:0]  bram_dina   ,
    output reg          bram_wdone  
);

    reg     [13:0]  addr_counter    ;   // BRAM addr counter

    wire            init_transfer   ;
    reg             init_txn_ff     ;

    wire    [63:0]  fifo_dout       ;
    reg             fifo_counter    ;

    reg     [31:0]  axi_rdata_reg   ;
    reg             axi_last_reg    ;
    reg             axi_last_reg2   ;
    reg             axi_shake_reg   ;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge axi_ACLK) begin                                                                        
        // Initiates AXI transaction delay    
        if (axi_ARESETN == 0) begin                                                                    
            init_txn_ff <= 1'b0;                                                                                       
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    always@(posedge axi_ACLK) begin
        if (!axi_ARESETN) begin
            axi_last_reg <= 1'b0;
            axi_last_reg2 <= 1'b0;
            axi_shake_reg <= 1'b0;
        end 
        else begin
            axi_last_reg <= axi_RLAST;
            axi_last_reg2 <= axi_last_reg;
            axi_shake_reg <= axi_SHAKE;
        end
    end

    always@(posedge axi_ACLK) begin
        if (!axi_ARESETN) begin
            axi_rdata_reg <= 32'b0;
        end 
        else begin
            axi_rdata_reg <= axi_RDATA;
        end
    end

    bram_in_fifo  data_32_64
    (
        .clk     (axi_ACLK      ),
        .din     (axi_rdata_reg ),
        .wr_en   (axi_shake_reg ), 
        .rd_en   (fifo_rd_en    ), 
        .dout    (fifo_dout     )
    );

    // addr counter
    always @(posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            addr_counter <= 13'b0;
        end 
        else begin
            if(addr_counter <= TOTAL_NUM - 1) begin
                if (axi_shake_reg && stage_start) begin
                    if (~axi_last_reg2) begin
                        addr_counter <= addr_counter + 1;
                    end 
                    else begin
                        addr_counter <= addr_counter;
                    end
                end
            end
            else begin
                addr_counter <= 13'b0;
            end
        end
    end

    always @(posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            fifo_counter <= 1'b0;
        end
        else begin
            if (axi_shake_reg && stage_start)
                fifo_counter <= fifo_counter + 1;
            else
                fifo_counter <= 1'b0;
        end
    end

    assign fifo_rd_en = (stage_start && fifo_counter && (addr_counter <= TOTAL_NUM - 1));

    always @(posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            bram_wdone <= 1'b0;
        end 
        else begin
            if(addr_counter == TOTAL_NUM - 1 && axi_shake_reg) begin
                bram_wdone <= 1'b1;
            end 
            else begin
                bram_wdone <= bram_wdone;
            end
        end
    end

    // output to BRAM
    assign bram_wea = fifo_rd_en;
    assign bram_addra = addr_counter >> 1;
    assign bram_dina = fifo_dout;

endmodule