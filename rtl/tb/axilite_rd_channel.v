`timescale 1ns / 1ps

module axilite_rd_channel #(
	parameter USER_RD_DATA_WIDTH    = 32 , //用户读数据位宽和AXI4—Lite数据位宽保持一致
	parameter AXI_DATA_WIDTH 		= 32, 
	parameter AXI_ADDR_WIDTH        = 32		
)(
	input   wire								    clk,  	  
	input   wire								    axi_clk,    
	input   wire								    reset,

	input   wire								    user_rd_en,
	input   wire  [AXI_ADDR_WIDTH-1 :0]		        user_rd_addr,
	output  wire                                    user_rd_ready,	
	output  reg   [USER_RD_DATA_WIDTH-1:0]	        user_rd_data,
	output  reg                                     user_rd_valid,

	output  reg   		 							m_axi_arvalid, // axi read address channel
	input   wire   		 							m_axi_arready, 
	output  reg   [AXI_ADDR_WIDTH-1:0] 				m_axi_araddr,
	output  wire  [2:0] 							m_axi_arprot, 

	input   wire  [AXI_DATA_WIDTH-1:0]	    		m_axi_rdata,   // axi read data channel
	input   wire  [1:0] 				    		m_axi_resp,
	input   wire     					    		m_axi_rvalid,
	output  wire   						   	 		m_axi_rready,

	output  reg							            rd_data_fifo_err,
	output  reg                                     rd_cmd_fifo_err

    );

(* dont_touch = "true"*) reg reset_sync_d0;  //user clk
(* dont_touch = "true"*) reg reset_sync_d1;
(* dont_touch = "true"*) reg reset_sync;
(* dont_touch = "true"*) reg a_reset_sync_d0; //axi clk
(* dont_touch = "true"*) reg a_reset_sync_d1;
(* dont_touch = "true"*) reg a_reset_sync;

reg	 [31:0]  cmd_din;
reg          cmd_wren;
wire [31:0]  cmd_dout;
reg 		 cmd_rden;
wire		 cmd_wrfull;
wire		 cmd_rdempty;
wire [4:0]   cmd_wrcount;
wire [4:0]   cmd_rdcount;

reg	 [31:0]  data_din;
reg          data_wren;
wire [31:0]  data_dout;
wire 		 data_rden;
wire		 data_wrfull;
wire		 data_rdempty;
wire [4:0]   data_wrcount;
wire [4:0]   data_rdcount;


reg [2 : 0]	 cur_status;
reg [2 : 0]	 nxt_status;

localparam RD_IDLE     = 3'b000;
localparam RD_PRE      = 3'b001;
localparam RD_DATA_EN  = 3'b010;
localparam RD_END      = 3'b100;

assign m_axi_rready  = 1'b1;
assign m_axi_arprot  = 0;
assign user_rd_ready = reset_sync ? 1'b0 : cmd_wrcount <= 'd12 ; 

/*--------------------------------------------------*\
				     CDC process
\*--------------------------------------------------*/
always @(posedge clk) begin
	reset_sync_d0   <= reset;
	reset_sync_d1   <= reset_sync_d0;
	reset_sync      <= reset_sync_d1;
end

always @(posedge axi_clk) begin
	a_reset_sync_d0 <= reset;
	a_reset_sync_d1 <= a_reset_sync_d0;
	a_reset_sync    <= a_reset_sync_d1;
end

/*--------------------------------------------------*\
               wirte addr to cmd fifo
\*--------------------------------------------------*/
always @(posedge clk) begin
	if (user_rd_ready) begin
		cmd_wren  <= user_rd_en;
		cmd_din   <= user_rd_addr;	
	end
	else begin
		cmd_wren  <= 0;
		cmd_din   <= 0;			
	end
end

/*--------------------------------------------------*\
	            RD state machine  
\*--------------------------------------------------*/
always @(posedge axi_clk) begin
	if (a_reset_sync) begin
		cur_status <= RD_IDLE;
	end
	else begin
		cur_status <= nxt_status;
	end
end

always @(*) begin
	if (a_reset_sync) begin
		nxt_status <= RD_IDLE;		
	end
	else begin
		case(cur_status)
			RD_IDLE : begin
 				if (~cmd_rdempty)
					nxt_status <= RD_PRE;
				else 
					nxt_status <= cur_status;
			end
			RD_PRE : begin
				nxt_status <= RD_DATA_EN;
			end
			RD_DATA_EN : begin
				if (m_axi_rvalid && m_axi_rready)
					nxt_status <= RD_END;
				else 
					nxt_status <= cur_status;
			end
			RD_END : begin
				nxt_status <= RD_IDLE;
			end
			default : nxt_status <= RD_IDLE;
		endcase	
	end
end

/*-----------------------------------------------------------*\
                  read addr from cmd_fifo 
\*-----------------------------------------------------------*/

always @(*) begin
	if (a_reset_sync) 
		cmd_rden   <= 0;
	else 
		cmd_rden   <= cur_status == RD_PRE;
end

always @(posedge axi_clk) begin
	if (cmd_rden) 
		m_axi_araddr <= cmd_dout;
	else 
		m_axi_araddr <= m_axi_araddr;
end

always @(posedge axi_clk) begin
	if (a_reset_sync) 
		m_axi_arvalid <= 0;
	else if (cur_status == RD_PRE)
		m_axi_arvalid <= 1'b1;
	else if (m_axi_arvalid && m_axi_arready)
		m_axi_arvalid <= 0;
end

/*-----------------------------------------------------------*\
                  read user data from data fifo
\*-----------------------------------------------------------*/
always @(posedge axi_clk) begin
	data_din  <= m_axi_rdata;
	data_wren <= m_axi_rvalid;
end         

assign data_rden = reset_sync ? 1'b0 : ~data_rdempty;

always @(posedge clk) begin
	user_rd_valid  <= data_rden;
	user_rd_data   <= data_dout;
end

// 这个信号可写，也可不写
reg resp_err;
always @(posedge axi_clk) begin
	if (m_axi_arvalid && m_axi_arready && m_axi_resp != 0)
		resp_err <= 1'b1;
	else 
		resp_err <= resp_err;
end

//这些fifo error信号可以不用写，因为有user_wr_ready的信号的存在，data fifo和cmd fifo一定不会爆满
always @(posedge clk) begin
	if (reset_sync) begin
		rd_data_fifo_err <= 1'b0;
	end
	else if (data_wren & data_wrfull) begin
		rd_data_fifo_err <= 1'b1;
	end
end

always @(posedge clk) begin
	if (reset_sync) begin
		rd_cmd_fifo_err <= 1'b0;
	end
	else if (cmd_wren & cmd_wrfull) begin
		rd_cmd_fifo_err <= 1'b1;
	end
end

 //cmd fifo和data fifo的深度大小和宽度大小根据实际项目需求决定    
fifo_w32xd16 rd_cmd_fifo (
  .rst(reset_sync),                      // input wire rst
  .wr_clk(clk),                // input wire wr_clk
  .rd_clk(axi_clk),                // input wire rd_clk
  .din(cmd_din),                      // input wire [31 : 0] din
  .wr_en(cmd_wren),                  // input wire wr_en
  .rd_en(cmd_rden),                  // input wire rd_en
  .dout(cmd_dout),                    // output wire [31 : 0] dout
  .full(cmd_wrfull),                    // output wire full
  .empty(cmd_rdempty),                  // output wire empty
  .rd_data_count(cmd_rdcount),  // output wire [4 : 0] rd_data_count
  .wr_data_count(cmd_wrcount)  // output wire [4 : 0] wr_data_count
);

fifo_w32xd16 rd_data_fifo (
  .rst(a_reset_sync),                      // input wire rst
  .wr_clk(axi_clk),                // input wire wr_clk
  .rd_clk(clk),                // input wire rd_clk
  .din(data_din),                      // input wire [31 : 0] din
  .wr_en(data_wren),                  // input wire wr_en
  .rd_en(data_rden),                  // input wire rd_en
  .dout(data_dout),                    // output wire [31 : 0] dout
  .full(data_wrfull),                    // output wire full
  .empty(data_rdempty),                  // output wire empty
  .rd_data_count(data_rdcount),  // output wire [4 : 0] rd_data_count
  .wr_data_count(data_wrcount)  // output wire [4 : 0] wr_data_count
);


endmodule
