`timescale 1ns / 1ps

module tb_top();
	parameter USER_WR_DATA_WIDTH = 32;
	parameter USER_RD_DATA_WIDTH = 32;
	parameter     AXI_DATA_WIDTH = 32;
	parameter     AXI_ADDR_WIDTH = 32;

	reg                          	user_wr_clk;
	reg                          	user_rd_clk;
	reg                          	axi_clk;
	reg                          	ap_rst_n;

	reg                          	user_wr_en;
	reg [USER_WR_DATA_WIDTH-1:0] 	user_wr_data;
	reg    [AXI_ADDR_WIDTH-1 :0] 	user_wr_addr;
	wire                          	user_wr_ready;

	reg                          	user_rd_en;
	reg    [AXI_ADDR_WIDTH-1 :0] 	user_rd_addr;
	wire                          	user_rd_ready;
	wire [USER_RD_DATA_WIDTH-1:0] 	user_rd_data;
	wire                          	user_rd_valid;

	wire    [AXI_ADDR_WIDTH -1:0] 	m_axi_awaddr;
	wire                    [2:0] 	m_axi_awprot;
	wire                          	m_axi_awvalid;
	wire                          	m_axi_awready;
	wire     [AXI_DATA_WIDTH-1:0] 	m_axi_wdata;
	wire   [AXI_DATA_WIDTH/8-1:0] 	m_axi_wstrb;
	wire                          	m_axi_wvalid;
	wire                          	m_axi_wready;
	wire                    [1:0] 	m_axi_bresp;
	wire                          	m_axi_bvalid;
	wire                          	m_axi_bready;
	wire                          	m_axi_arvalid;
	wire                          	m_axi_arready;
	wire     [AXI_ADDR_WIDTH-1:0] 	m_axi_araddr;
	wire                    [2:0] 	m_axi_arprot;
	wire     [AXI_DATA_WIDTH-1:0] 	m_axi_rdata;
	wire                    [1:0] 	m_axi_resp;
	wire                          	m_axi_rvalid;
	wire                          	m_axi_rready;

	wire 	[0:0]  					m_axi_gmem0_AWID;
	wire 	[63:0] 					m_axi_gmem0_AWADDR;
	wire 	[7:0]  					m_axi_gmem0_AWLEN;
	wire 	[2:0]  					m_axi_gmem0_AWSIZE;
	wire 	[1:0]  					m_axi_gmem0_AWBURST;
	wire 	[1:0]  					m_axi_gmem0_AWLOCK;
	wire 	[3:0]  					m_axi_gmem0_AWREGION;
	wire 	[3:0]  					m_axi_gmem0_AWCACHE;
	wire 	[2:0]  					m_axi_gmem0_AWPROT;
	wire 	[3:0]  					m_axi_gmem0_AWQOS;
	wire 	       					m_axi_gmem0_AWVALID;
	wire 	       					m_axi_gmem0_AWREADY;
	wire 	[0:0]  					m_axi_gmem0_WID;
	wire 	[31:0] 					m_axi_gmem0_WDATA;
	wire 	[3:0]  					m_axi_gmem0_WSTRB;
	wire 	       					m_axi_gmem0_WLAST;
	wire 	       					m_axi_gmem0_WVALID;
	wire 	       					m_axi_gmem0_WREADY;
	wire 	[0:0]  					m_axi_gmem0_BID;
	wire 	[1:0]  					m_axi_gmem0_BRESP;
	wire 	       					m_axi_gmem0_BVALID;
	wire 	       					m_axi_gmem0_BREADY;
	wire 	[0:0]  					m_axi_gmem0_ARID;
	wire 	[63:0] 					m_axi_gmem0_ARADDR;
	wire 	[7:0]  					m_axi_gmem0_ARLEN;
	wire 	[2:0]  					m_axi_gmem0_ARSIZE;
	wire 	[1:0]  					m_axi_gmem0_ARBURST;
	wire 	[1:0]  					m_axi_gmem0_ARLOCK;
	wire 	[3:0]  					m_axi_gmem0_ARREGION;
	wire 	[3:0]  					m_axi_gmem0_ARCACHE;
	wire 	[2:0]  					m_axi_gmem0_ARPROT;
	wire 	[3:0]  					m_axi_gmem0_ARQOS;
	wire 	       					m_axi_gmem0_ARVALID;
	wire 	       					m_axi_gmem0_ARREADY;
	wire 	[0:0]  					m_axi_gmem0_RID;
	wire 	[31:0] 					m_axi_gmem0_RDATA;
	wire 	[1:0]  					m_axi_gmem0_RRESP;
	wire 	       					m_axi_gmem0_RLAST;
	wire 	       					m_axi_gmem0_RVALID;
	wire 	       					m_axi_gmem0_RREADY;

	wire 	[0:0]  					m_axi_gmem1_AWID;
	wire 	[63:0] 					m_axi_gmem1_AWADDR;
	wire 	[7:0]  					m_axi_gmem1_AWLEN;
	wire 	[2:0]  					m_axi_gmem1_AWSIZE;
	wire 	[1:0]  					m_axi_gmem1_AWBURST;
	wire 	[1:0]  					m_axi_gmem1_AWLOCK;
	wire 	[3:0]  					m_axi_gmem1_AWREGION;
	wire 	[3:0]  					m_axi_gmem1_AWCACHE;
	wire 	[2:0]  					m_axi_gmem1_AWPROT;
	wire 	[3:0]  					m_axi_gmem1_AWQOS;
	wire 	       					m_axi_gmem1_AWVALID;
	wire 	       					m_axi_gmem1_AWREADY;
	wire 	[0:0]  					m_axi_gmem1_WID;
	wire 	[31:0] 					m_axi_gmem1_WDATA;
	wire 	[3:0]  					m_axi_gmem1_WSTRB;
	wire 	       					m_axi_gmem1_WLAST;
	wire 	       					m_axi_gmem1_WVALID;
	wire 	       					m_axi_gmem1_WREADY;
	wire 	[0:0]  					m_axi_gmem1_BID;
	wire 	[1:0]  					m_axi_gmem1_BRESP;
	wire 	       					m_axi_gmem1_BVALID;
	wire 	       					m_axi_gmem1_BREADY;
	wire 	[0:0]  					m_axi_gmem1_ARID;
	wire 	[63:0] 					m_axi_gmem1_ARADDR;
	wire 	[7:0]  					m_axi_gmem1_ARLEN;
	wire 	[2:0]  					m_axi_gmem1_ARSIZE;
	wire 	[1:0]  					m_axi_gmem1_ARBURST;
	wire 	[1:0]  					m_axi_gmem1_ARLOCK;
	wire 	[3:0]  					m_axi_gmem1_ARREGION;
	wire 	[3:0]  					m_axi_gmem1_ARCACHE;
	wire 	[2:0]  					m_axi_gmem1_ARPROT;
	wire 	[3:0]  					m_axi_gmem1_ARQOS;
	wire 	       					m_axi_gmem1_ARVALID;
	wire 	       					m_axi_gmem1_ARREADY;
	wire 	[0:0]  					m_axi_gmem1_RID;
	wire 	[31:0] 					m_axi_gmem1_RDATA;
	wire 	[1:0]  					m_axi_gmem1_RRESP;
	wire 	       					m_axi_gmem1_RLAST;
	wire 	       					m_axi_gmem1_RVALID;
	wire 	       					m_axi_gmem1_RREADY;

	wire 	[0:0]  					m_axi_gmem2_AWID;
	wire 	[63:0] 					m_axi_gmem2_AWADDR;
	wire 	[7:0]  					m_axi_gmem2_AWLEN;
	wire 	[2:0]  					m_axi_gmem2_AWSIZE;
	wire 	[1:0]  					m_axi_gmem2_AWBURST;
	wire 	[1:0]  					m_axi_gmem2_AWLOCK;
	wire 	[3:0]  					m_axi_gmem2_AWREGION;
	wire 	[3:0]  					m_axi_gmem2_AWCACHE;
	wire 	[2:0]  					m_axi_gmem2_AWPROT;
	wire 	[3:0]  					m_axi_gmem2_AWQOS;
	wire 	       					m_axi_gmem2_AWVALID;
	wire 	       					m_axi_gmem2_AWREADY;
	wire 	[0:0]  					m_axi_gmem2_WID;
	wire 	[31:0] 					m_axi_gmem2_WDATA;
	wire 	[3:0]  					m_axi_gmem2_WSTRB;
	wire 	       					m_axi_gmem2_WLAST;
	wire 	       					m_axi_gmem2_WVALID;
	wire 	       					m_axi_gmem2_WREADY;
	wire 	[0:0]  					m_axi_gmem2_BID;
	wire 	[1:0]  					m_axi_gmem2_BRESP;
	wire 	       					m_axi_gmem2_BVALID;
	wire 	       					m_axi_gmem2_BREADY;
	wire 	[0:0]  					m_axi_gmem2_ARID;
	wire 	[63:0] 					m_axi_gmem2_ARADDR;
	wire 	[7:0]  					m_axi_gmem2_ARLEN;
	wire 	[2:0]  					m_axi_gmem2_ARSIZE;
	wire 	[1:0]  					m_axi_gmem2_ARBURST;
	wire 	[1:0]  					m_axi_gmem2_ARLOCK;
	wire 	[3:0]  					m_axi_gmem2_ARREGION;
	wire 	[3:0]  					m_axi_gmem2_ARCACHE;
	wire 	[2:0]  					m_axi_gmem2_ARPROT;
	wire 	[3:0]  					m_axi_gmem2_ARQOS;
	wire 	       					m_axi_gmem2_ARVALID;
	wire 	       					m_axi_gmem2_ARREADY;
	wire 	[0:0]  					m_axi_gmem2_RID;
	wire 	[31:0] 					m_axi_gmem2_RDATA;
	wire 	[1:0]  					m_axi_gmem2_RRESP;
	wire 	       					m_axi_gmem2_RLAST;
	wire 	       					m_axi_gmem2_RVALID;
	wire 	       					m_axi_gmem2_RREADY;

	wire 							bram_rst_a;
	wire 							bram_clk_a;
	wire 							bram_en_a;
	wire 	[3:0] 					bram_we_a;
	wire 	[16:0] 					bram_addr_a;
	wire 	[31:0] 					bram_wrdata_a;
	wire 	[31:0] 					bram_rddata_a;

	integer 						add_file_out;
	reg 	[15:0] 					add_out_count;
	reg								add_start;
	integer 						mul_file_out;
	reg 	[15:0] 					mul_out_count;
	reg								mul_start;
	integer 						softmax_file_out;
	reg 	[15:0] 					softmax_out_count;
	reg								softmax_start;
	integer 						silu_file_out;
	reg 	[15:0] 					silu_out_count;
	reg								silu_start;
	integer 						gelu_file_out;
	reg 	[15:0] 					gelu_out_count;
	reg								gelu_start;
	integer 						rms_file_out;
	reg 	[15:0] 					rms_out_count;
	reg								rms_start;
	integer 						layer_file_out;
	reg 	[15:0] 					layer_out_count;
	reg								layer_start;

	initial begin
		add_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_add_out.bin", "wb");
		mul_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_mul_out.bin", "wb");
		softmax_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_softmax_out.bin", "wb");
		silu_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_silu_out.bin", "wb");
		gelu_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_gelu_out.bin", "wb");
		rms_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_rms_out.bin", "wb");
		layer_file_out = $fopen("D:\\Study\\FPT_2025\\python\\fpga_result\\acc_layer_out.bin", "wb");
	end

	initial begin //100M
		axi_clk = 0;
		forever 
		#5 axi_clk = ~axi_clk;
	end

	initial begin
		ap_rst_n = 0;
		#100;
		ap_rst_n = 1;
	end

	// test for axi-lite

	// write addr to in0,in1,out
	// write 0x0000_1000 to 0x10 ==> in0 low
	// write 0x0000_0000 to 0x14 ==> in0 high
	// write 0x0000_1000 to 0x1C ==> in1 low
	// write 0x0000_0000 to 0x20 ==> in1 high
	// write 0x0000_0000 to 0x28 ==> out low
	// write 0x0000_0000 to 0x2C ==> out high

	// start stage 0
	// write 0 to 0x34 ==> stage == 0
	// write 1 to 0x0 ==> start accelerator
	// read from 0x0 ==> check ap_done signal

	//start stage 1
	// write 0~7 to 0x3C ==> configs[0]~configs[7]
	// write 1 to 0x34 ==> stage == 1
	// write 1 to 0x0 ==> start accelerator
	// read from 0x0 ==> check ap_done signal

	//start stage 2
	// write 1 to 0x34 ==> stage == 2
	// write 1 to 0x0 ==> start accelerator
	// read from 0x0 ==> check ap_done signal

	initial begin
        user_wr_en = 1'b0;
        user_wr_data = 32'h0;
        user_wr_addr = 32'h0;
        user_rd_en = 1'b0;
        user_rd_addr = 32'h0;

		add_start = 1'b0;
		mul_start = 1'b0;
		softmax_start = 1'b0;
		silu_start = 1'b0;
		gelu_start = 1'b0;
		rms_start = 1'b0;
		layer_start = 1'b0;
        
		#405;
		// write addr to in0,in1,out
		// write 0x0000_1000 to 0x10 ==> in0 low
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0010;
        user_wr_data = 32'h0000_1000;
		#10
		user_wr_en = 1'b0;
		#20;

		// write 0x0000_0000 to 0x14 ==> in0 high
		user_wr_en = 1'b1;
		user_wr_addr = 32'h0000_0014;
		user_wr_data = 32'h0000_0000;
		#10
		user_wr_en = 1'b0;
		#20;

		// write 0x0000_1000 to 0x1C ==> in1 low
		user_wr_en = 1'b1;
		user_wr_addr = 32'h0000_001C;
		user_wr_data = 32'h0000_1000;
		#10
		user_wr_en = 1'b0;
		#20;

		// write 0x0000_0000 to 0x20 ==> in1 high
		user_wr_en = 1'b1;
		user_wr_addr = 32'h0000_0020;
		user_wr_data = 32'h0000_0000;
		#10
		user_wr_en = 1'b0;
		#20;

		// write 0x0000_0000 to 0x28 ==> out low
		user_wr_en = 1'b1;
		user_wr_addr = 32'h0000_0028;
		user_wr_data = 32'h0000_0000;
		#10
		user_wr_en = 1'b0;
		#20;

		// write 0x0001_0000 to 0x2C ==> out high
		user_wr_en = 1'b1;
		user_wr_addr = 32'h0000_002C;
		user_wr_data = 32'h0000_0000;
		#10
		user_wr_en = 1'b0;
		#20;

		// start stage 0
		// write 0 to 0x34 ==> stage == 0
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0000;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		#20;

		// // start stage 1

        // // write 0 to 0x3C ==> configs[0] : SOFTMAX
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_003C;
        // user_wr_data = 32'h0000_0000;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x34 ==> stage == 1
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0001;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// #20;

		// // start stage 2
		
		// // write 2 to 0x34 ==> stage == 2
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0002;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// softmax_start = 1'b1;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// $fclose(softmax_file_out);
        // $display("SOFTMAX Test Finished.");

		// #20;

		// // start stage 1

        // // write 1 to 0x3C ==> configs[1] : LAYERNORM
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_003C;
        // user_wr_data = 32'h0000_0001;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x34 ==> stage == 1
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0001;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// #20;

		// // start stage 2
		
		// // write 2 to 0x34 ==> stage == 2
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0002;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// layer_start = 1'b1;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// $fclose(layer_file_out);
        // $display("LAYERNORM Test Finished.");

		// #20;

		// // start stage 1

        // // write 2 to 0x3C ==> configs[2] : RMSNORM
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_003C;
        // user_wr_data = 32'h0000_0002;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x34 ==> stage == 1
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0001;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// #20;

		// // start stage 2
		
		// // write 2 to 0x34 ==> stage == 2
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0002;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// rms_start = 1'b1;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// $fclose(rms_file_out);
        // $display("RMSNORM Test Finished.");

		// #20;

		// start stage 1

        // write 3 to 0x3C ==> configs[3] : SILU
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_003C;
        user_wr_data = 32'h0000_0003;
		#10 
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x34 ==> stage == 1
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0001;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		#20;

		// start stage 2
		
		// write 2 to 0x34 ==> stage == 2
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0002;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		silu_start = 1'b1;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		$fclose(silu_file_out);
        $display("SILU Test Finished.");

		#20;

		// // start stage 1

        // // write 4 to 0x3C ==> configs[4] : GELU
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_003C;
        // user_wr_data = 32'h0000_0004;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x34 ==> stage == 1
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0001;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// #20;

		// // start stage 2
		
		// // write 2 to 0x34 ==> stage == 2
        // user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0034;
        // user_wr_data = 32'h0000_0002;

		// #10
		// user_wr_en = 1'b0;
		// #20;

		// // write 1 to 0x0 ==> start accelerator
		// user_wr_en = 1'b1;
        // user_wr_addr = 32'h0000_0000;
        // user_wr_data = 32'h0000_0001;
		// gelu_start = 1'b1;
		// #10 
		// user_wr_en = 1'b0;
		// #20;

		// // read from 0x0 ==> check ap_done signal
		// user_rd_en = 1'b1;
		// user_rd_addr = 32'h0000_0000;
		
		// wait(user_rd_data[1] == 1'b0);
		
		// #20;
		
		// wait(user_rd_data[1] == 1'b1);
		// user_rd_en = 1'b0;
		// $fclose(gelu_file_out);
        // $display("GELU Test Finished.");

		// #20;

		// start stage 1

        // write 5 to 0x3C ==> configs[5] : ADD
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_003C;
        user_wr_data = 32'h0000_0005;
		#10 
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x34 ==> stage == 1
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0001;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		#20;

		// start stage 2

		// write 2 to 0x34 ==> stage == 2
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0002;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		add_start = 1'b1;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		$fclose(add_file_out);
        $display("ADD Test Finished.");

		#20;

		// start stage 1

        // write 6 to 0x3C ==> configs[6] : MUL
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_003C;
        user_wr_data = 32'h0000_0006;
		#10 
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x34 ==> stage == 1
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0001;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		#20;

		// start stage 2
		
		// write 2 to 0x34 ==> stage == 2
        user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0034;
        user_wr_data = 32'h0000_0002;

		#10
		user_wr_en = 1'b0;
		#20;

		// write 1 to 0x0 ==> start accelerator
		user_wr_en = 1'b1;
        user_wr_addr = 32'h0000_0000;
        user_wr_data = 32'h0000_0001;
		mul_start = 1'b1;
		#10 
		user_wr_en = 1'b0;
		#20;

		// read from 0x0 ==> check ap_done signal
		user_rd_en = 1'b1;
		user_rd_addr = 32'h0000_0000;
		
		wait(user_rd_data[1] == 1'b0);
		
		#20;
		
		wait(user_rd_data[1] == 1'b1);
		user_rd_en = 1'b0;
		$fclose(mul_file_out);
        $display("MUL Test Finished.");

		#20;

		$finish;

	end

	axilite_master #(
			.USER_WR_DATA_WIDTH(USER_WR_DATA_WIDTH),
			.USER_RD_DATA_WIDTH(USER_RD_DATA_WIDTH),
			.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
			.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
	) 
	axilite_master (
		.user_wr_clk   (axi_clk),
		.user_rd_clk   (axi_clk),
		.axi_clk       (axi_clk),
		.reset         (~ap_rst_n),

		.user_wr_en    (user_wr_en),
		.user_wr_data  (user_wr_data),
		.user_wr_addr  (user_wr_addr),
		.user_wr_ready (user_wr_ready),
		.user_rd_en    (user_rd_en),
		.user_rd_addr  (user_rd_addr),
		.user_rd_ready (user_rd_ready),
		.user_rd_data  (user_rd_data),
		.user_rd_valid (user_rd_valid),

		.m_axi_awaddr  (m_axi_awaddr),
		.m_axi_awprot  (m_axi_awprot),
		.m_axi_awvalid (m_axi_awvalid),
		.m_axi_awready (m_axi_awready),
		.m_axi_wdata   (m_axi_wdata),
		.m_axi_wstrb   (m_axi_wstrb),
		.m_axi_wvalid  (m_axi_wvalid),
		.m_axi_wready  (m_axi_wready),
		.m_axi_bresp   (m_axi_bresp),
		.m_axi_bvalid  (m_axi_bvalid),
		.m_axi_bready  (m_axi_bready),
		.m_axi_arvalid (m_axi_arvalid),
		.m_axi_arready (m_axi_arready),
		.m_axi_araddr  (m_axi_araddr),
		.m_axi_arprot  (m_axi_arprot),
		.m_axi_rdata   (m_axi_rdata),
		.m_axi_resp    (m_axi_resp),
		.m_axi_rvalid  (m_axi_rvalid),
		.m_axi_rready  (m_axi_rready)
	);

	accelerator_control test_accelerator(
    	.ap_clk					(axi_clk		),
    	.ap_resetn				(ap_rst_n		),
    	.s_axi_control_AWADDR	(m_axi_awaddr	),
    	.s_axi_control_AWVALID	(m_axi_awvalid	),
    	.s_axi_control_AWREADY	(m_axi_awready	),
    	.s_axi_control_WDATA	(m_axi_wdata	),
    	.s_axi_control_WSTRB	(m_axi_wstrb	),
    	.s_axi_control_WVALID	(m_axi_wvalid	),
    	.s_axi_control_WREADY	(m_axi_wready	),
    	.s_axi_control_BRESP	(m_axi_bresp	),
    	.s_axi_control_BVALID	(m_axi_bvalid	),
    	.s_axi_control_BREADY	(m_axi_bready	),
    	.s_axi_control_ARADDR	(m_axi_araddr	),
    	.s_axi_control_ARVALID	(m_axi_arvalid	),
    	.s_axi_control_ARREADY	(m_axi_arready	),
    	.s_axi_control_RDATA	(m_axi_rdata	),
    	.s_axi_control_RRESP	(m_axi_resp		),
    	.s_axi_control_RVALID	(m_axi_rvalid	),
    	.s_axi_control_RREADY	(m_axi_rready	),
    	// .interrupt,
		.m_axi_gmem0_AWID    	(m_axi_gmem0_AWID       ),
    	.m_axi_gmem0_AWADDR		(m_axi_gmem0_AWADDR		),
    	.m_axi_gmem0_AWLEN		(m_axi_gmem0_AWLEN		),
    	.m_axi_gmem0_AWSIZE		(m_axi_gmem0_AWSIZE		),
    	.m_axi_gmem0_AWBURST	(m_axi_gmem0_AWBURST	),
    	.m_axi_gmem0_AWLOCK		(m_axi_gmem0_AWLOCK		),
    	.m_axi_gmem0_AWREGION	(m_axi_gmem0_AWREGIO	),
    	.m_axi_gmem0_AWCACHE	(m_axi_gmem0_AWCACHE	),
    	.m_axi_gmem0_AWPROT		(m_axi_gmem0_AWPROT		),
    	.m_axi_gmem0_AWQOS		(m_axi_gmem0_AWQOS		),
    	.m_axi_gmem0_AWVALID	(m_axi_gmem0_AWVALID	),
    	.m_axi_gmem0_AWREADY	(m_axi_gmem0_AWREADY	),
		.m_axi_gmem0_WID		(m_axi_gmem0_WID		),
    	.m_axi_gmem0_WDATA		(m_axi_gmem0_WDATA		),
    	.m_axi_gmem0_WSTRB		(m_axi_gmem0_WSTRB		),
    	.m_axi_gmem0_WLAST		(m_axi_gmem0_WLAST		),
    	.m_axi_gmem0_WVALID		(m_axi_gmem0_WVALID		),
    	.m_axi_gmem0_WREADY		(m_axi_gmem0_WREADY		),
		.m_axi_gmem0_BID		(m_axi_gmem0_BID		),
    	.m_axi_gmem0_BRESP		(m_axi_gmem0_BRESP		),
    	.m_axi_gmem0_BVALID		(m_axi_gmem0_BVALID		),
    	.m_axi_gmem0_BREADY		(m_axi_gmem0_BREADY		),
		.m_axi_gmem0_ARID		(m_axi_gmem0_ARID		),
    	.m_axi_gmem0_ARADDR		(m_axi_gmem0_ARADDR		),
    	.m_axi_gmem0_ARLEN		(m_axi_gmem0_ARLEN		),
    	.m_axi_gmem0_ARSIZE		(m_axi_gmem0_ARSIZE		),
    	.m_axi_gmem0_ARBURST	(m_axi_gmem0_ARBURST	),
    	.m_axi_gmem0_ARLOCK		(m_axi_gmem0_ARLOCK		),
    	.m_axi_gmem0_ARREGION	(m_axi_gmem0_ARREGIO	),
    	.m_axi_gmem0_ARCACHE	(m_axi_gmem0_ARCACHE	),
    	.m_axi_gmem0_ARPROT		(m_axi_gmem0_ARPROT		),
    	.m_axi_gmem0_ARQOS		(m_axi_gmem0_ARQOS		),
    	.m_axi_gmem0_ARVALID	(m_axi_gmem0_ARVALID	),
    	.m_axi_gmem0_ARREADY	(m_axi_gmem0_ARREADY	),
		.m_axi_gmem0_RID		(m_axi_gmem0_RID		),
    	.m_axi_gmem0_RDATA		(m_axi_gmem0_RDATA		),
    	.m_axi_gmem0_RRESP		(m_axi_gmem0_RRESP		),
    	.m_axi_gmem0_RLAST		(m_axi_gmem0_RLAST		),
    	.m_axi_gmem0_RVALID		(m_axi_gmem0_RVALID		),
    	.m_axi_gmem0_RREADY		(m_axi_gmem0_RREADY		),
    	.m_axi_gmem1_AWID		(m_axi_gmem1_AWID		),
    	.m_axi_gmem1_AWADDR		(m_axi_gmem1_AWADDR		),
    	.m_axi_gmem1_AWLEN		(m_axi_gmem1_AWLEN		),
    	.m_axi_gmem1_AWSIZE		(m_axi_gmem1_AWSIZE		),
    	.m_axi_gmem1_AWBURST	(m_axi_gmem1_AWBURST	),
    	.m_axi_gmem1_AWLOCK		(m_axi_gmem1_AWLOCK		),
    	.m_axi_gmem1_AWREGION	(m_axi_gmem1_AWREGION	),
    	.m_axi_gmem1_AWCACHE	(m_axi_gmem1_AWCACHE	),
    	.m_axi_gmem1_AWPROT		(m_axi_gmem1_AWPROT		),
    	.m_axi_gmem1_AWQOS		(m_axi_gmem1_AWQOS		),
    	.m_axi_gmem1_AWVALID	(m_axi_gmem1_AWVALID	),
    	.m_axi_gmem1_AWREADY	(m_axi_gmem1_AWREADY	),
    	.m_axi_gmem1_WID		(m_axi_gmem1_WID		),
    	.m_axi_gmem1_WDATA		(m_axi_gmem1_WDATA		),
    	.m_axi_gmem1_WSTRB		(m_axi_gmem1_WSTRB		),
    	.m_axi_gmem1_WLAST		(m_axi_gmem1_WLAST		),
    	.m_axi_gmem1_WVALID		(m_axi_gmem1_WVALID		),
    	.m_axi_gmem1_WREADY		(m_axi_gmem1_WREADY		),
    	.m_axi_gmem1_BID		(m_axi_gmem1_BID		),
    	.m_axi_gmem1_BRESP		(m_axi_gmem1_BRESP		),
    	.m_axi_gmem1_BVALID		(m_axi_gmem1_BVALID		),
    	.m_axi_gmem1_BREADY		(m_axi_gmem1_BREADY		),
    	.m_axi_gmem1_ARID		(m_axi_gmem1_ARID		),
    	.m_axi_gmem1_ARADDR		(m_axi_gmem1_ARADDR		),
    	.m_axi_gmem1_ARLEN		(m_axi_gmem1_ARLEN		),
    	.m_axi_gmem1_ARSIZE		(m_axi_gmem1_ARSIZE		),
    	.m_axi_gmem1_ARBURST	(m_axi_gmem1_ARBURST	),
    	.m_axi_gmem1_ARLOCK		(m_axi_gmem1_ARLOCK		),
    	.m_axi_gmem1_ARREGION	(m_axi_gmem1_ARREGION	),
    	.m_axi_gmem1_ARCACHE	(m_axi_gmem1_ARCACHE	),
    	.m_axi_gmem1_ARPROT		(m_axi_gmem1_ARPROT		),
    	.m_axi_gmem1_ARQOS		(m_axi_gmem1_ARQOS		),
    	.m_axi_gmem1_ARVALID	(m_axi_gmem1_ARVALID	),
    	.m_axi_gmem1_ARREADY	(m_axi_gmem1_ARREADY	),
    	.m_axi_gmem1_RID		(m_axi_gmem1_RID		),
    	.m_axi_gmem1_RDATA		(m_axi_gmem1_RDATA		),
    	.m_axi_gmem1_RRESP		(m_axi_gmem1_RRESP		),
    	.m_axi_gmem1_RLAST		(m_axi_gmem1_RLAST		),
    	.m_axi_gmem1_RVALID		(m_axi_gmem1_RVALID		),
    	.m_axi_gmem1_RREADY		(m_axi_gmem1_RREADY		),
    	.m_axi_gmem2_AWID		(m_axi_gmem2_AWID		),
    	.m_axi_gmem2_AWADDR		(m_axi_gmem2_AWADDR		),
    	.m_axi_gmem2_AWLEN		(m_axi_gmem2_AWLEN		),
    	.m_axi_gmem2_AWSIZE		(m_axi_gmem2_AWSIZE		),
    	.m_axi_gmem2_AWBURST	(m_axi_gmem2_AWBURST	),
    	.m_axi_gmem2_AWLOCK		(m_axi_gmem2_AWLOCK		),
    	.m_axi_gmem2_AWREGION	(m_axi_gmem2_AWREGION	),
    	.m_axi_gmem2_AWCACHE	(m_axi_gmem2_AWCACHE	),
    	.m_axi_gmem2_AWPROT		(m_axi_gmem2_AWPROT		),
    	.m_axi_gmem2_AWQOS		(m_axi_gmem2_AWQOS		),
    	.m_axi_gmem2_AWVALID	(m_axi_gmem2_AWVALID	),
    	.m_axi_gmem2_AWREADY	(m_axi_gmem2_AWREADY	),
    	.m_axi_gmem2_WID		(m_axi_gmem2_WID		),
    	.m_axi_gmem2_WDATA		(m_axi_gmem2_WDATA		),
    	.m_axi_gmem2_WSTRB		(m_axi_gmem2_WSTRB		),
    	.m_axi_gmem2_WLAST		(m_axi_gmem2_WLAST		),
    	.m_axi_gmem2_WVALID		(m_axi_gmem2_WVALID		),
    	.m_axi_gmem2_WREADY		(m_axi_gmem2_WREADY		),
    	.m_axi_gmem2_BID		(m_axi_gmem2_BID		),
    	.m_axi_gmem2_BRESP		(m_axi_gmem2_BRESP		),
    	.m_axi_gmem2_BVALID		(m_axi_gmem2_BVALID		),
    	.m_axi_gmem2_BREADY		(m_axi_gmem2_BREADY		),
    	.m_axi_gmem2_ARID		(m_axi_gmem2_ARID		),
    	.m_axi_gmem2_ARADDR		(m_axi_gmem2_ARADDR		),
    	.m_axi_gmem2_ARLEN		(m_axi_gmem2_ARLEN		),
    	.m_axi_gmem2_ARSIZE		(m_axi_gmem2_ARSIZE		),
    	.m_axi_gmem2_ARBURST	(m_axi_gmem2_ARBURST	),
    	.m_axi_gmem2_ARLOCK		(m_axi_gmem2_ARLOCK		),
    	.m_axi_gmem2_ARREGION	(m_axi_gmem2_ARREGION	),
    	.m_axi_gmem2_ARCACHE	(m_axi_gmem2_ARCACHE	),
    	.m_axi_gmem2_ARPROT		(m_axi_gmem2_ARPROT		),
    	.m_axi_gmem2_ARQOS		(m_axi_gmem2_ARQOS		),
    	.m_axi_gmem2_ARVALID	(m_axi_gmem2_ARVALID	),
    	.m_axi_gmem2_ARREADY	(m_axi_gmem2_ARREADY	),
    	.m_axi_gmem2_RID		(m_axi_gmem2_RID		),
    	.m_axi_gmem2_RDATA		(m_axi_gmem2_RDATA		),
    	.m_axi_gmem2_RRESP		(m_axi_gmem2_RRESP		),
    	.m_axi_gmem2_RLAST		(m_axi_gmem2_RLAST		),
    	.m_axi_gmem2_RVALID		(m_axi_gmem2_RVALID		),
    	.m_axi_gmem2_RREADY		(m_axi_gmem2_RREADY		)
);

	blk_mem_gen_0 in0_data_sim (
		.s_aclk				(axi_clk					),  // input wire s_aclk
		.s_aresetn			(ap_rst_n					),  // input wire s_aresetn
		.s_axi_awid			(m_axi_gmem0_AWID			),  // input wire [3 : 0] s_axi_awid
		.s_axi_awaddr		(m_axi_gmem0_AWADDR[31:0]	),  // input wire [31 : 0] s_axi_awaddr
		.s_axi_awlen		(m_axi_gmem0_AWLEN			),  // input wire [7 : 0] s_axi_awlen
		.s_axi_awsize		(m_axi_gmem0_AWSIZE			),  // input wire [2 : 0] s_axi_awsize
		.s_axi_awburst		(m_axi_gmem0_AWBURST		),  // input wire [1 : 0] s_axi_awburst
		.s_axi_awvalid		(m_axi_gmem0_AWVALID		),  // input wire s_axi_awvalid
		.s_axi_awready		(m_axi_gmem0_AWREADY		),  // output wire s_axi_awready
		.s_axi_wdata		(m_axi_gmem0_WDATA			),  // input wire [31 : 0] s_axi_wdata
		.s_axi_wstrb		(m_axi_gmem0_WSTRB			),  // input wire [3 : 0] s_axi_wstrb
		.s_axi_wlast		(m_axi_gmem0_WLAST			),  // input wire s_axi_wlast
		.s_axi_wvalid		(m_axi_gmem0_WVALID			),  // input wire s_axi_wvalid
		.s_axi_wready		(m_axi_gmem0_WREADY			),  // output wire s_axi_wready
		.s_axi_bid			(m_axi_gmem0_BID			),  // output wire [3 : 0] s_axi_bid
		.s_axi_bresp		(m_axi_gmem0_BRESP			),  // output wire [1 : 0] s_axi_bresp
		.s_axi_bvalid		(m_axi_gmem0_BVALID			),  // output wire s_axi_bvalid
		.s_axi_bready		(m_axi_gmem0_BREADY			),  // input wire s_axi_bready
		.s_axi_arid			(m_axi_gmem0_ARID			),  // input wire [3 : 0] s_axi_arid
		.s_axi_araddr		(m_axi_gmem0_ARADDR[31:0]	),  // input wire [31 : 0] s_axi_araddr
		.s_axi_arlen		(m_axi_gmem0_ARLEN			),  // input wire [7 : 0] s_axi_arlen
		.s_axi_arsize		(m_axi_gmem0_ARSIZE			),  // input wire [2 : 0] s_axi_arsize
		.s_axi_arburst		(m_axi_gmem0_ARBURST		),  // input wire [1 : 0] s_axi_arburst
		.s_axi_arvalid		(m_axi_gmem0_ARVALID		),  // input wire s_axi_arvalid
		.s_axi_arready		(m_axi_gmem0_ARREADY		),  // output wire s_axi_arready
		.s_axi_rid			(m_axi_gmem0_RID			),  // output wire [3 : 0] s_axi_rid
		.s_axi_rdata		(m_axi_gmem0_RDATA			),  // output wire [31 : 0] s_axi_rdata
		.s_axi_rresp		(m_axi_gmem0_RRESP			),  // output wire [1 : 0] s_axi_rresp
		.s_axi_rlast		(m_axi_gmem0_RLAST			),  // output wire s_axi_rlast
		.s_axi_rvalid		(m_axi_gmem0_RVALID			),  // output wire s_axi_rvalid
		.s_axi_rready		(m_axi_gmem0_RREADY			)   // input wire s_axi_rready
	);

	blk_mem_gen_1 in1_data_sim (
		.s_aclk				(axi_clk					),  // input wire s_aclk
		.s_aresetn			(ap_rst_n					),  // input wire s_aresetn
		.s_axi_awid			(m_axi_gmem1_AWID			),  // input wire [3 : 0] s_axi_awid
		.s_axi_awaddr		(m_axi_gmem1_AWADDR[31:0]	),  // input wire [31 : 0] s_axi_awaddr
		.s_axi_awlen		(m_axi_gmem1_AWLEN			),  // input wire [7 : 0] s_axi_awlen
		.s_axi_awsize		(m_axi_gmem1_AWSIZE			),  // input wire [2 : 0] s_axi_awsize
		.s_axi_awburst		(m_axi_gmem1_AWBURST		),  // input wire [1 : 0] s_axi_awburst
		.s_axi_awvalid		(m_axi_gmem1_AWVALID		),  // input wire s_axi_awvalid
		.s_axi_awready		(m_axi_gmem1_AWREADY		),  // output wire s_axi_awready
		.s_axi_wdata		(m_axi_gmem1_WDATA			),  // input wire [31 : 0] s_axi_wdata
		.s_axi_wstrb		(m_axi_gmem1_WSTRB			),  // input wire [3 : 0] s_axi_wstrb
		.s_axi_wlast		(m_axi_gmem1_WLAST			),  // input wire s_axi_wlast
		.s_axi_wvalid		(m_axi_gmem1_WVALID			),  // input wire s_axi_wvalid
		.s_axi_wready		(m_axi_gmem1_WREADY			),  // output wire s_axi_wready
		.s_axi_bid			(m_axi_gmem1_BID			),  // output wire [3 : 0] s_axi_bid
		.s_axi_bresp		(m_axi_gmem1_BRESP			),  // output wire [1 : 0] s_axi_bresp
		.s_axi_bvalid		(m_axi_gmem1_BVALID			),  // output wire s_axi_bvalid
		.s_axi_bready		(m_axi_gmem1_BREADY			),  // input wire s_axi_bready
		.s_axi_arid			(m_axi_gmem1_ARID			),  // input wire [3 : 0] s_axi_arid
		.s_axi_araddr		(m_axi_gmem1_ARADDR[31:0]	),  // input wire [31 : 0] s_axi_araddr
		.s_axi_arlen		(m_axi_gmem1_ARLEN			),  // input wire [7 : 0] s_axi_arlen
		.s_axi_arsize		(m_axi_gmem1_ARSIZE			),  // input wire [2 : 0] s_axi_arsize
		.s_axi_arburst		(m_axi_gmem1_ARBURST		),  // input wire [1 : 0] s_axi_arburst
		.s_axi_arvalid		(m_axi_gmem1_ARVALID		),  // input wire s_axi_arvalid
		.s_axi_arready		(m_axi_gmem1_ARREADY		),  // output wire s_axi_arready
		.s_axi_rid			(m_axi_gmem1_RID			),  // output wire [3 : 0] s_axi_rid
		.s_axi_rdata		(m_axi_gmem1_RDATA			),  // output wire [31 : 0] s_axi_rdata
		.s_axi_rresp		(m_axi_gmem1_RRESP			),  // output wire [1 : 0] s_axi_rresp
		.s_axi_rlast		(m_axi_gmem1_RLAST			),  // output wire s_axi_rlast
		.s_axi_rvalid		(m_axi_gmem1_RVALID			),  // output wire s_axi_rvalid
		.s_axi_rready		(m_axi_gmem1_RREADY			)   // input wire s_axi_rready
	);

	axi_bram_ctrl_0 out_data_sim (
		.s_axi_aclk			(axi_clk					),        // input wire s_axi_aclk
		.s_axi_aresetn		(ap_rst_n					),  // input wire s_axi_aresetn
		.s_axi_awaddr		(m_axi_gmem2_AWADDR			),    // input wire [16 : 0] s_axi_awaddr
		.s_axi_awlen		(m_axi_gmem2_AWLEN			),      // input wire [7 : 0] s_axi_awlen
		.s_axi_awsize		(m_axi_gmem2_AWSIZE			),    // input wire [2 : 0] s_axi_awsize
		.s_axi_awburst		(m_axi_gmem2_AWBURST		),  // input wire [1 : 0] s_axi_awburst
		.s_axi_awlock		(m_axi_gmem2_AWLOCK			),    // input wire s_axi_awlock
		.s_axi_awcache		(m_axi_gmem2_AWCACHE		),  // input wire [3 : 0] s_axi_awcache
		.s_axi_awprot		(m_axi_gmem2_AWPROT			),    // input wire [2 : 0] s_axi_awprot
		.s_axi_awvalid		(m_axi_gmem2_AWVALID		),  // input wire s_axi_awvalid
		.s_axi_awready		(m_axi_gmem2_AWREADY		),  // output wire s_axi_awready
		.s_axi_wdata		(m_axi_gmem2_WDATA			),      // input wire [31 : 0] s_axi_wdata
		.s_axi_wstrb		(m_axi_gmem2_WSTRB			),      // input wire [3 : 0] s_axi_wstrb
		.s_axi_wlast		(m_axi_gmem2_WLAST			),      // input wire s_axi_wlast
		.s_axi_wvalid		(m_axi_gmem2_WVALID			),    // input wire s_axi_wvalid
		.s_axi_wready		(m_axi_gmem2_WREADY			),    // output wire s_axi_wready
		.s_axi_bresp		(m_axi_gmem2_BRESP			),      // output wire [1 : 0] s_axi_bresp
		.s_axi_bvalid		(m_axi_gmem2_BVALID			),    // output wire s_axi_bvalid
		.s_axi_bready		(m_axi_gmem2_BREADY			),    // input wire s_axi_bready
		.s_axi_araddr		(m_axi_gmem2_ARADDR			),    // input wire [16 : 0] s_axi_araddr
		.s_axi_arlen		(m_axi_gmem2_ARLEN			),      // input wire [7 : 0] s_axi_arlen
		.s_axi_arsize		(m_axi_gmem2_ARSIZE			),    // input wire [2 : 0] s_axi_arsize
		.s_axi_arburst		(m_axi_gmem2_ARBURST		),  // input wire [1 : 0] s_axi_arburst
		.s_axi_arlock		(m_axi_gmem2_ARLOCK			),    // input wire s_axi_arlock
		.s_axi_arcache		(m_axi_gmem2_ARCACHE		),  // input wire [3 : 0] s_axi_arcache
		.s_axi_arprot		(m_axi_gmem2_ARPROT			),    // input wire [2 : 0] s_axi_arprot
		.s_axi_arvalid		(m_axi_gmem2_ARVALID		),  // input wire s_axi_arvalid
		.s_axi_arready		(m_axi_gmem2_ARREADY		),  // output wire s_axi_arready
		.s_axi_rdata		(m_axi_gmem2_RDATA			),      // output wire [31 : 0] s_axi_rdata
		.s_axi_rresp		(m_axi_gmem2_RRESP			),      // output wire [1 : 0] s_axi_rresp
		.s_axi_rlast		(m_axi_gmem2_RLAST			),      // output wire s_axi_rlast
		.s_axi_rvalid		(m_axi_gmem2_RVALID			),    // output wire s_axi_rvalid
		.s_axi_rready		(m_axi_gmem2_RREADY			),    // input wire s_axi_rready
		.bram_rst_a			(bram_rst_a					),        // output wire bram_rst_a
		.bram_clk_a			(bram_clk_a					),        // output wire bram_clk_a
		.bram_en_a			(bram_en_a					),          // output wire bram_en_a
		.bram_we_a			(bram_we_a					),          // output wire [3 : 0] bram_we_a
		.bram_addr_a		(bram_addr_a				),      // output wire [16 : 0] bram_addr_a
		.bram_wrdata_a		(bram_wrdata_a				),  // output wire [31 : 0] bram_wrdata_a
		.bram_rddata_a		(bram_rddata_a				)  // input wire [31 : 0] bram_rddata_a
	);

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            add_out_count <= 16'b0;
        end
        else begin
            if(add_out_count <= 16'd24575)begin
                if(bram_en_a && add_start)begin
                    $fwrite(add_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                add_out_count <= add_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            mul_out_count <= 16'b0;
        end
        else begin
            if(mul_out_count <= 16'd24575)begin
                if(bram_en_a && mul_start)begin
                    $fwrite(mul_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                mul_out_count <= mul_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            softmax_out_count <= 16'b0;
        end
        else begin
            if(softmax_out_count <= 16'd24575)begin
                if(bram_en_a && softmax_start)begin
                    $fwrite(softmax_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                softmax_out_count <= softmax_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            silu_out_count <= 16'b0;
        end
        else begin
            if(silu_out_count <= 16'd24575)begin
                if(bram_en_a && silu_start)begin
                    $fwrite(silu_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                silu_out_count <= silu_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            gelu_out_count <= 16'b0;
        end
        else begin
            if(gelu_out_count <= 16'd24575)begin
                if(bram_en_a && gelu_start)begin
                    $fwrite(gelu_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                gelu_out_count <= gelu_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            rms_out_count <= 16'b0;
        end
        else begin
            if(rms_out_count <= 16'd24575)begin
                if(bram_en_a && rms_start)begin
                    $fwrite(rms_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                rms_out_count <= rms_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

	always @ (posedge bram_clk_a)begin
        if(bram_rst_a)begin
            layer_out_count <= 16'b0;
        end
        else begin
            if(layer_out_count <= 16'd24575)begin
                if(bram_en_a && layer_start)begin
                    $fwrite(layer_file_out, "%c%c%c%c", 
					bram_wrdata_a[23:16],
					bram_wrdata_a[31:24],
					bram_wrdata_a[7:0],
					bram_wrdata_a[15:8]
                );
                layer_out_count <= layer_out_count + 1'b1;
                end
            end
            else begin
            end
        end
    end

endmodule
