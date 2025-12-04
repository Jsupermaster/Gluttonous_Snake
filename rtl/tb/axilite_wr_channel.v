`timescale 1ns / 1ps

module axilite_wr_channel #(
	parameter USER_WR_DATA_WIDTH    = 32 ,//用户写数据位宽和AXI4—Lite数据位宽保持一致
	parameter AXI_DATA_WIDTH 		= 32, //AXI4_LITE总线规定，数据位宽只支持32Bit或者64bit
	parameter AXI_ADDR_WIDTH        = 32	

)(	input   wire							        clk,     //用户写时钟		
	input   wire									axi_clk,    
	input   wire									reset,

	input   wire								    user_wr_en,
	input   wire  [USER_WR_DATA_WIDTH-1:0]	        user_wr_data,
	input   wire  [AXI_ADDR_WIDTH-1 :0]		        user_wr_addr,
	output  wire                                    user_wr_ready,		
	
	output  reg   [AXI_ADDR_WIDTH -1:0]  	        m_axi_awaddr,
	output  wire  [2:0] 				 	        m_axi_awprot, 
	output  reg   		 				 	        m_axi_awvalid, 
	input   wire    		 			 	        m_axi_awready,

	output  reg   [AXI_DATA_WIDTH-1:0]	 	        m_axi_wdata,   //write data channel
	output  wire  [AXI_DATA_WIDTH/8-1:0] 	        m_axi_wstrb,
	output  reg      					 	        m_axi_wvalid,
	input   wire    					 	        m_axi_wready,

	input   wire  [1:0]	         	                m_axi_bresp,  //wirte response channel
	input   wire	   			         	        m_axi_bvalid,
	output  wire    			         	        m_axi_bready,	

	output  reg							            wr_data_fifo_err,
	output  reg                                     wr_cmd_fifo_err
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
reg 		 data_rden;
wire		 data_wrfull;
wire		 data_rdempty;
wire [4:0]   data_wrcount;
wire [4:0]   data_rdcount;

reg [2 : 0]	 cur_status;
reg [2 : 0]	 nxt_status;

localparam WR_IDLE     = 3'b000;
localparam WR_PRE      = 3'b001;
localparam WR_DATA_EN  = 3'b010;
localparam WR_END      = 3'b100;


assign m_axi_bready  = 1'b1;
assign m_axi_awprot  = 0;
assign m_axi_wstrb   = {AXI_DATA_WIDTH/8{1'b1}};
assign user_wr_ready = reset_sync ? 1'b0 : cmd_wrcount <= 'd12 ; //留一点余量
                                                                 //当user_wr_ready为低的时候，用户发送写是无效的
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
    wirte addr to cmd fifo、write data to data fifo 
\*--------------------------------------------------*/

always @(posedge clk) begin
	if (user_wr_ready) begin
		cmd_wren  <= user_wr_en;
		cmd_din   <= user_wr_addr;
		data_wren <= user_wr_en;
		data_din  <= user_wr_data; 		
	end
	else begin
		cmd_wren  <= 0;
		cmd_din   <= 0;
		data_wren <= 0;
		data_din  <= 0; 		
	end
end


/*--------------------------------------------------*\
	            WR state machine  
\*--------------------------------------------------*/

always @(posedge axi_clk) begin
	if (a_reset_sync) begin
		cur_status <= WR_IDLE;
	end
	else begin
		cur_status <= nxt_status;
	end
end

always @(*) begin
	if (a_reset_sync) begin
		nxt_status <= WR_IDLE;		
	end
	else begin
		case(cur_status)
			WR_IDLE : begin
 				if (~cmd_rdempty)
					nxt_status <= WR_PRE;
				else 
					nxt_status <= cur_status;
			end
			WR_PRE : begin
				nxt_status <= WR_DATA_EN;
			end
			WR_DATA_EN : begin
				if (m_axi_bvalid && m_axi_bready)
					nxt_status <= WR_END;
				else 
					nxt_status <= cur_status;
			end
			WR_END : begin
				nxt_status <= WR_IDLE;
			end
			default : nxt_status <= WR_IDLE;
		endcase	
	end
end

/*-----------------------------------------------------------*\
       read addr from cmd_fifo 、 read data from data_fifo  
\*-----------------------------------------------------------*/
always @(*) begin
	if (a_reset_sync) begin
		cmd_rden   <= 0;
		data_rden  <= 0;
	end
	else begin
		cmd_rden   <= cur_status == WR_PRE;
		data_rden  <= cur_status == WR_PRE;
	end
end

always @(posedge axi_clk) begin
	if (cmd_rden) 
		m_axi_awaddr <= cmd_dout;
	else 
		m_axi_awaddr <= m_axi_awaddr;
end

always @(posedge axi_clk) begin
	if (data_rden) 
		m_axi_wdata <= data_dout;
	else 
		m_axi_wdata <= m_axi_wdata;
end

always @(posedge axi_clk) begin
	if (a_reset_sync) 
		m_axi_awvalid <= 0;
	else if (cur_status == WR_PRE)
		m_axi_awvalid <= 1'b1;
	else if (m_axi_awvalid && m_axi_awready)
		m_axi_awvalid <= 0;
end

always @(posedge axi_clk) begin
	if (a_reset_sync) 
		m_axi_wvalid <= 0;
	else if (cur_status == WR_PRE)
		m_axi_wvalid <= 1'b1;
	else if (m_axi_wvalid && m_axi_wready)
		m_axi_wvalid <= 0;
end

//这些fifo error信号可以不用写，因为有user_wr_ready的信号的存在，data fifo和cmd fifo一定不会爆满
always @(posedge clk) begin
	if (reset_sync) begin
		wr_data_fifo_err <= 1'b0;
	end
	else if (data_wren & data_wrfull) begin
		wr_data_fifo_err <= 1'b1;
	end
end

always @(posedge clk) begin
	if (reset_sync) begin
		wr_cmd_fifo_err <= 1'b0;
	end
	else if (cmd_wren & cmd_wrfull) begin
		wr_cmd_fifo_err <= 1'b1;
	end
end


 //cmd fifo和data fifo的深度大小和宽度大小根据实际项目需求决定                                                                //user_wr_ready信号的作用是防止cmd fifo和data fifo爆满
fifo_w32xd16 wr_cmd_fifo (
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

fifo_w32xd16 wr_data_fifo (
  .rst(reset_sync),                      // input wire rst
  .wr_clk(clk),                // input wire wr_clk
  .rd_clk(axi_clk),                // input wire rd_clk
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
