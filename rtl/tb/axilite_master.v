`timescale 1ns / 1ps

module axilite_master #(
	parameter USER_WR_DATA_WIDTH    = 32 , //用户写数据位宽和AXI4—Lite数据位宽保持一致
    parameter USER_RD_DATA_WIDTH    = 32 , //用户读数据位宽和AXI4—Lite数据位宽保持一致
	parameter AXI_DATA_WIDTH 		= 32,  //AXI4_LITE总线规定，数据位宽只支持32Bit或者64bit
	parameter AXI_ADDR_WIDTH        = 32	
)(
	input   wire								    user_wr_clk,  	  
	input   wire								    user_rd_clk,  
	input   wire								    axi_clk,    
	input   wire								    reset,

	input   wire								    user_wr_en,
	input   wire  [USER_WR_DATA_WIDTH-1:0]	        user_wr_data,
	input   wire  [AXI_ADDR_WIDTH-1 :0]		        user_wr_addr,
	output  wire                                    user_wr_ready,	//当user_wr_ready为高时候，用户发起的写操作才是有效的

	input   wire								    user_rd_en,
	input   wire  [AXI_ADDR_WIDTH-1 :0]		        user_rd_addr,
	output  wire                                    user_rd_ready, //当user_rd_ready为高时候，用户发起的读操作才是有效的	
	output  wire  [USER_RD_DATA_WIDTH-1:0]	        user_rd_data,
	output  wire                                    user_rd_valid,

	output  wire  [AXI_ADDR_WIDTH -1:0]  	        m_axi_awaddr, //axi write address channel
	output  wire  [2:0] 				 	        m_axi_awprot, 
	output  wire   		 				 	        m_axi_awvalid, 
	input   wire    		 			 	        m_axi_awready,

	output  wire  [AXI_DATA_WIDTH-1:0]	 	        m_axi_wdata,   //axi write data channel
	output  wire  [AXI_DATA_WIDTH/8-1:0] 	        m_axi_wstrb,
	output  wire      					 	        m_axi_wvalid,
	input   wire    					 	        m_axi_wready,

	input   wire  [1:0]	         	                m_axi_bresp,  //axi wirte response channel
	input   wire	   			         	        m_axi_bvalid,
	output  wire    			         	        m_axi_bready,

	output  wire   		 							m_axi_arvalid, // axi read address channel
	input   wire   		 							m_axi_arready, 
	output  wire  [AXI_ADDR_WIDTH-1:0] 			    m_axi_araddr,
	output  wire  [2:0] 							m_axi_arprot, 

	input   wire  [AXI_DATA_WIDTH-1:0]	    		m_axi_rdata,   // axi read data channel
	input   wire  [1:0] 				    		m_axi_resp,
	input   wire     					    		m_axi_rvalid,
	output  wire   						   	 		m_axi_rready
    );

	wire							        wr_data_fifo_err;
	wire                                    wr_cmd_fifo_err;
	wire							        rd_data_fifo_err;
	wire                                    rd_cmd_fifo_err;


	axilite_wr_channel #(
			.USER_WR_DATA_WIDTH(USER_WR_DATA_WIDTH),
			.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
			.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
		) axilite_wr_channel (
			.clk              (user_wr_clk),
			.axi_clk          (axi_clk),
			.reset            (reset),

			.user_wr_en       (user_wr_en),
			.user_wr_data     (user_wr_data),
			.user_wr_addr     (user_wr_addr),
			.user_wr_ready    (user_wr_ready),

			.m_axi_awaddr     (m_axi_awaddr),
			.m_axi_awprot     (m_axi_awprot),
			.m_axi_awvalid    (m_axi_awvalid),
			.m_axi_awready    (m_axi_awready),
			.m_axi_wdata      (m_axi_wdata),
			.m_axi_wstrb      (m_axi_wstrb),
			.m_axi_wvalid     (m_axi_wvalid),
			.m_axi_wready     (m_axi_wready),
			.m_axi_bresp      (m_axi_bresp),
			.m_axi_bvalid     (m_axi_bvalid),
			.m_axi_bready     (m_axi_bready),

			.wr_data_fifo_err (wr_data_fifo_err),
			.wr_cmd_fifo_err  (wr_cmd_fifo_err)
		);

	axilite_rd_channel #(
			.USER_RD_DATA_WIDTH(USER_RD_DATA_WIDTH),
			.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
			.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
		) axilite_rd_channel (
			.clk              (user_rd_clk),
			.axi_clk          (axi_clk),
			.reset            (reset),

			.user_rd_en       (user_rd_en),
			.user_rd_addr     (user_rd_addr),
			.user_rd_ready    (user_rd_ready),
			.user_rd_data     (user_rd_data),
			.user_rd_valid    (user_rd_valid),

			.m_axi_arvalid    (m_axi_arvalid),
			.m_axi_arready    (m_axi_arready),
			.m_axi_araddr     (m_axi_araddr),
			.m_axi_arprot     (m_axi_arprot),
			.m_axi_rdata      (m_axi_rdata),
			.m_axi_resp       (m_axi_resp),
			.m_axi_rvalid     (m_axi_rvalid),
			.m_axi_rready     (m_axi_rready),
			
			.rd_data_fifo_err (rd_data_fifo_err),
			.rd_cmd_fifo_err  (rd_cmd_fifo_err)
		);








endmodule
