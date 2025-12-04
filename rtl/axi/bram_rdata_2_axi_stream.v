// this module is for BRAM to AXI-Stream conversion
// It read data from BRAM and output AXI-Stream data(TO ACCELERATOR)

module BR2AS #(
    parameter integer TOTAL_NUM = 768
)
(
    input   wire            clk             ,
    input   wire            rst_n           ,
    
    input   wire            stage_start     ,
    // BRAM interface
    output  wire            in_bram_enb     ,
    output  wire [13:0]     in_bram_addrb   ,
    input   wire [63:0]     in_bram_doutb   ,
    
    // AXI-Stream interface
    output  wire [63:0]     a_tdata         ,
    output  reg             a_tvalid
);

    reg [13:0] addr_counter;   // BRAM addr counter

    wire init_transfer;

    reg init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    reg stage_start_reg;

    reg in_bram_enb_reg;

    always @(posedge clk) begin                                                                        
        // Initiates AXI transaction delay    
        if (rst_n == 0) begin                                                                    
            init_txn_ff <= 1'b0;                                                                                 
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end
    
    always@(posedge clk) begin
        if (!rst_n) begin
            stage_start_reg <= 1'b0;
        end 
        else begin
            if (stage_start) begin
                stage_start_reg <= 1'b1;
            end
            else begin
                stage_start_reg <= 1'b0;
            end
        end
    end

    // addr counter
    always @(posedge clk) begin
        if (!rst_n || init_transfer) begin
            addr_counter <= 14'b0;
        end 
        else begin
            if(addr_counter <= TOTAL_NUM - 1) begin
                if (stage_start) begin
                    addr_counter <= addr_counter + 1;
                end
            end
            else begin
                addr_counter <= addr_counter;
            end
        end
    end

    assign in_bram_addrb = addr_counter;
    assign in_bram_enb = stage_start_reg && (addr_counter <= TOTAL_NUM - 1);

    always@(posedge clk) begin
        if (!rst_n) begin
            in_bram_enb_reg <= 1'b0;
            a_tvalid <= 1'b0;
        end 
        else begin
            in_bram_enb_reg <= in_bram_enb;
            a_tvalid <= in_bram_enb_reg;
        end
    end

    assign a_tdata = in_bram_doutb;

endmodule