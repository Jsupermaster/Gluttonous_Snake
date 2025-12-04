module accelerator_control (
    // AXI4-Lite Control Slave Interface
    // Global Signals
    input  wire        ap_clk,
    input  wire        ap_resetn,
    // Write Address Channel
    input  wire [6:0]  s_axi_control_AWADDR,
    input  wire        s_axi_control_AWVALID,
    output wire        s_axi_control_AWREADY,
    // Write Data Channel
    input  wire [31:0] s_axi_control_WDATA,
    input  wire [3:0]  s_axi_control_WSTRB,
    input  wire        s_axi_control_WVALID,
    output wire        s_axi_control_WREADY,
    // Write Response Channel
    output wire [1:0]  s_axi_control_BRESP,
    output wire        s_axi_control_BVALID,
    input  wire        s_axi_control_BREADY,
    // Read Address Channel
    input  wire [6:0]  s_axi_control_ARADDR,
    input  wire        s_axi_control_ARVALID,
    output wire        s_axi_control_ARREADY,
    // Read Data Channel
    output wire [31:0] s_axi_control_RDATA,
    output wire [1:0]  s_axi_control_RRESP,
    output wire        s_axi_control_RVALID,
    input  wire        s_axi_control_RREADY,

    // Interrupt
    output wire        interrupt,

    // AXI4 Full Master Interface 0 (gmem0) - READ_ONLY
    // Write Address Channel
    output wire [0:0]  m_axi_gmem0_AWID,
    output wire [63:0] m_axi_gmem0_AWADDR,
    output wire [7:0]  m_axi_gmem0_AWLEN,
    output wire [2:0]  m_axi_gmem0_AWSIZE,
    output wire [1:0]  m_axi_gmem0_AWBURST,
    output wire [1:0]  m_axi_gmem0_AWLOCK,
    output wire [3:0]  m_axi_gmem0_AWREGION,
    output wire [3:0]  m_axi_gmem0_AWCACHE,
    output wire [2:0]  m_axi_gmem0_AWPROT,
    output wire [3:0]  m_axi_gmem0_AWQOS,
    output wire        m_axi_gmem0_AWVALID,
    input  wire        m_axi_gmem0_AWREADY,
    // Write Data Channel
    output wire [0:0]  m_axi_gmem0_WID,
    output wire [31:0] m_axi_gmem0_WDATA,
    output wire [3:0]  m_axi_gmem0_WSTRB,
    output wire        m_axi_gmem0_WLAST,
    output wire        m_axi_gmem0_WVALID,
    input  wire        m_axi_gmem0_WREADY,
    // Write Response Channel
    input  wire [0:0]  m_axi_gmem0_BID,
    input  wire [1:0]  m_axi_gmem0_BRESP,
    input  wire        m_axi_gmem0_BVALID,
    output wire        m_axi_gmem0_BREADY,
    // Read Address Channel
    output wire [0:0]  m_axi_gmem0_ARID,
    output wire [63:0] m_axi_gmem0_ARADDR,
    output wire [7:0]  m_axi_gmem0_ARLEN,
    output wire [2:0]  m_axi_gmem0_ARSIZE,
    output wire [1:0]  m_axi_gmem0_ARBURST,
    output wire [1:0]  m_axi_gmem0_ARLOCK,
    output wire [3:0]  m_axi_gmem0_ARREGION,
    output wire [3:0]  m_axi_gmem0_ARCACHE,
    output wire [2:0]  m_axi_gmem0_ARPROT,
    output wire [3:0]  m_axi_gmem0_ARQOS,
    output wire        m_axi_gmem0_ARVALID,
    input  wire        m_axi_gmem0_ARREADY,
    // Read Data Channel
    input  wire [0:0]  m_axi_gmem0_RID,
    input  wire [31:0] m_axi_gmem0_RDATA,
    input  wire [1:0]  m_axi_gmem0_RRESP,
    input  wire        m_axi_gmem0_RLAST,
    input  wire        m_axi_gmem0_RVALID,
    output wire        m_axi_gmem0_RREADY,

    // AXI4 Full Master Interface 1 (gmem1) - READ_ONLY
    // Write Address Channel
    output wire [0:0]  m_axi_gmem1_AWID,
    output wire [63:0] m_axi_gmem1_AWADDR,
    output wire [7:0]  m_axi_gmem1_AWLEN,
    output wire [2:0]  m_axi_gmem1_AWSIZE,
    output wire [1:0]  m_axi_gmem1_AWBURST,
    output wire [1:0]  m_axi_gmem1_AWLOCK,
    output wire [3:0]  m_axi_gmem1_AWREGION,
    output wire [3:0]  m_axi_gmem1_AWCACHE,
    output wire [2:0]  m_axi_gmem1_AWPROT,
    output wire [3:0]  m_axi_gmem1_AWQOS,
    output wire        m_axi_gmem1_AWVALID,
    input  wire        m_axi_gmem1_AWREADY,
    // Write Data Channel
    output wire [0:0]  m_axi_gmem1_WID,
    output wire [31:0] m_axi_gmem1_WDATA,
    output wire [3:0]  m_axi_gmem1_WSTRB,
    output wire        m_axi_gmem1_WLAST,
    output wire        m_axi_gmem1_WVALID,
    input  wire        m_axi_gmem1_WREADY,
    // Write Response Channel
    input  wire [0:0]  m_axi_gmem1_BID,
    input  wire [1:0]  m_axi_gmem1_BRESP,
    input  wire        m_axi_gmem1_BVALID,
    output wire        m_axi_gmem1_BREADY,
    // Read Address Channel
    output wire [0:0]  m_axi_gmem1_ARID,
    output wire [63:0] m_axi_gmem1_ARADDR,
    output wire [7:0]  m_axi_gmem1_ARLEN,
    output wire [2:0]  m_axi_gmem1_ARSIZE,
    output wire [1:0]  m_axi_gmem1_ARBURST,
    output wire [1:0]  m_axi_gmem1_ARLOCK,
    output wire [3:0]  m_axi_gmem1_ARREGION,
    output wire [3:0]  m_axi_gmem1_ARCACHE,
    output wire [2:0]  m_axi_gmem1_ARPROT,
    output wire [3:0]  m_axi_gmem1_ARQOS,
    output wire        m_axi_gmem1_ARVALID,
    input  wire        m_axi_gmem1_ARREADY,
    // Read Data Channel
    input  wire [0:0]  m_axi_gmem1_RID,
    input  wire [31:0] m_axi_gmem1_RDATA,
    input  wire [1:0]  m_axi_gmem1_RRESP,
    input  wire        m_axi_gmem1_RLAST,
    input  wire        m_axi_gmem1_RVALID,
    output wire        m_axi_gmem1_RREADY,

    // AXI4 Full Master Interface 2 (gmem2) - WRITE_ONLY
    // Write Address Channel
    output wire [0:0]  m_axi_gmem2_AWID,
    output wire [63:0] m_axi_gmem2_AWADDR,
    output wire [7:0]  m_axi_gmem2_AWLEN,
    output wire [2:0]  m_axi_gmem2_AWSIZE,
    output wire [1:0]  m_axi_gmem2_AWBURST,
    output wire [1:0]  m_axi_gmem2_AWLOCK,
    output wire [3:0]  m_axi_gmem2_AWREGION,
    output wire [3:0]  m_axi_gmem2_AWCACHE,
    output wire [2:0]  m_axi_gmem2_AWPROT,
    output wire [3:0]  m_axi_gmem2_AWQOS,
    output wire        m_axi_gmem2_AWVALID,
    input  wire        m_axi_gmem2_AWREADY,
    // Write Data Channel
    output wire [0:0]  m_axi_gmem2_WID,
    output wire [31:0] m_axi_gmem2_WDATA,
    output wire [3:0]  m_axi_gmem2_WSTRB,
    output wire        m_axi_gmem2_WLAST,
    output wire        m_axi_gmem2_WVALID,
    input  wire        m_axi_gmem2_WREADY,
    // Write Response Channel
    input  wire [0:0]  m_axi_gmem2_BID,
    input  wire [1:0]  m_axi_gmem2_BRESP,
    input  wire        m_axi_gmem2_BVALID,
    output wire        m_axi_gmem2_BREADY,
    // Read Address Channel
    output wire [0:0]  m_axi_gmem2_ARID,
    output wire [63:0] m_axi_gmem2_ARADDR,
    output wire [7:0]  m_axi_gmem2_ARLEN,
    output wire [2:0]  m_axi_gmem2_ARSIZE,
    output wire [1:0]  m_axi_gmem2_ARBURST,
    output wire [1:0]  m_axi_gmem2_ARLOCK,
    output wire [3:0]  m_axi_gmem2_ARREGION,
    output wire [3:0]  m_axi_gmem2_ARCACHE,
    output wire [2:0]  m_axi_gmem2_ARPROT,
    output wire [3:0]  m_axi_gmem2_ARQOS,
    output wire        m_axi_gmem2_ARVALID,
    input  wire        m_axi_gmem2_ARREADY,
    // Read Data Channel
    input  wire [0:0]  m_axi_gmem2_RID,
    input  wire [31:0] m_axi_gmem2_RDATA,
    input  wire [1:0]  m_axi_gmem2_RRESP,
    input  wire        m_axi_gmem2_RLAST,
    input  wire        m_axi_gmem2_RVALID,
    output wire        m_axi_gmem2_RREADY
);

    // ------------------------Signal Declarations----------------------------------//

    // control signals from axi-lite
    wire    	        stage_start_axi                 ;
    reg    	            stage_done                      ;
    wire    [31:0]      in0_low_addr                    ;
    wire    [31:0]      in0_high_addr                   ;
    wire    [31:0]      in1_low_addr                    ;
    wire    [31:0]      in1_high_addr                   ;
    wire    [31:0]      out_low_addr                    ;
    wire    [31:0]      out_high_addr                   ;
    wire    [31:0]      stage_axi                       ;
    wire    [31:0]      configs_axi                     ;
    (*MAX_FANOUT = 30 *)reg     [31:0]      stage       ;
    (*MAX_FANOUT = 30 *)reg     [31:0]      configs     ;
    (*MAX_FANOUT = 30 *)reg                 stage_start ;
    reg     [3:0]       configs_snake     [7:0]         ;
    reg     [3:0]       tiny_configs_snake[7:0]         ;

    // signals for in0_bram
    // write
    wire                in0_bram_wea    [15:0]          ;
    wire    [13:0]      in0_bram_addra  [15:0]          ;
    wire    [63:0]      in0_bram_dina   [15:0]          ;
    wire                in0_bram_wdone  [15:0]          ;

    //read
    wire                in0_bram_enb    [15:0]          ;
    wire    [13:0]      in0_bram_addrb  [15:0]          ;
    wire    [63:0]      in0_bram_doutb  [15:0]          ;

    wire                all_in0_bram_wdone              ;

    // signals for in1_bram
    // write
    wire                in1_bram_wea    [15:0]          ;
    wire    [13:0]      in1_bram_addra  [15:0]          ;
    wire    [63:0]      in1_bram_dina   [15:0]          ;
    wire                in1_bram_wdone  [15:0]          ;

    //read
    wire                in1_bram_enb    [15:0]          ;
    wire    [13:0]      in1_bram_addrb  [15:0]          ;
    wire    [63:0]      in1_bram_doutb  [15:0]          ;

    wire                all_in1_bram_wdone              ;

    // signals for out_bram
    wire                out_bram_wea    [15:0]          ;
    wire    [13:0]      out_bram_addra  [15:0]          ;
    wire    [63:0]      out_bram_dina   [15:0]          ;
    wire    [15:0]      out_bram_wdone                  ;

    wire                out_bram_enb    [15:0]          ;
    wire    [13:0]      out_bram_addrb  [15:0]          ;
    wire    [63:0]      out_bram_doutb  [15:0]          ;
    
    // signals for AXI Full Master
    reg     [63:0]      in0_read_address                ;
    wire    [31:0]      in0_read_data                   ;
    reg                 in0_read_enable                 ;

    reg     [63:0]      in1_read_address                ;
    wire    [31:0]      in1_read_data                   ;
    reg                 in1_read_enable                 ;

    reg     [63:0]      out_write_address               ;
    reg     [31:0]      out_write_data                  ;
    reg                 out_write_enable                ;
    wire                out_write_ready                 ;

    wire                stage_0_done                    ;

    // signals for accelerators
    wire    [63:0]      in0_tdata               [7:0]  ;
    wire                in0_tvalid              [7:0]  ;

    wire    [63:0]      in1_tdata               [7:0]  ;
    wire                in1_tvalid              [7:0]  ;

    reg                 acc_in0_tvalid          [7:0]  ;
    reg     [63:0]      acc_in0_tdata           [7:0]  ;

    reg                 acc_in1_tvalid          [7:0]  ;
    reg     [63:0]      acc_in1_tdata           [7:0]  ;

    wire    [63:0]      tiny_in0_tdata          [7:0]  ;
    wire                tiny_in0_tvalid         [7:0]  ;

    wire    [63:0]      tiny_in1_tdata          [7:0]  ;
    wire                tiny_in1_tvalid         [7:0]  ;

    reg                 tiny_acc_in0_tvalid     [7:0]  ;
    reg     [63:0]      tiny_acc_in0_tdata      [7:0]  ;

    reg                 tiny_acc_in1_tvalid     [7:0]  ;
    reg     [63:0]      tiny_acc_in1_tdata      [7:0]  ;

    (*MAX_FANOUT = 30 *)reg                 snake_stage_start       [7:0]   ;
    (*MAX_FANOUT = 30 *)reg                 tiny_snake_stage_start  [7:0]   ;

    wire                snake_out_tvalid        [7:0]   ;
    wire    [127:0]     snake_out_tdata         [7:0]   ;
    wire                tiny_snake_out_tvalid   [7:0]   ;
    wire    [63:0]      tiny_snake_out_tdata    [7:0]   ;


    wire    [127:0]     fifo1_din               [7:0]   ; 
    wire                fifo1_wr_en             [7:0]   ;
    wire    [127:0]     fifo1_dout              [7:0]   ;
    wire                fifo1_rd_en             [7:0]   ;
    wire    [127:0]     fifo2_din               [7:0]   ;
    wire                fifo2_wr_en             [7:0]   ;
    wire    [127:0]     fifo2_dout              [7:0]   ;
    wire                fifo2_rd_en             [7:0]   ;
    wire    [63:0]      fifo3_din               [7:0]   ; 
    wire                fifo3_wr_en             [7:0]   ;
    wire    [63:0]      fifo3_dout              [7:0]   ;
    wire                fifo3_rd_en             [7:0]   ;

    reg     [127:0]     acc_out_data_fp32       [7:0]   ;
    reg                 acc_out_valid_fp32      [7:0]   ;

    wire    [63:0]      trans_acc_out_data_bf16 [7:0]   ;
    reg     [63:0]      acc_out_data_bf16       [7:0]   ;
    reg                 acc_out_valid_bf16      [7:0]   ;

    wire                stage_1_done                    ;

    wire    [63:0]      axi_write_data                  ;
    wire                axi_write_enable                ;

    wire                stage_2_done                    ;


    // Instantiation of AXI Lite Configs IP Core
    axi_config_ctrl u_axi_config_ctrl(
        .stage_start        (stage_start_axi        ),
        .stage_done         (stage_done             ),
        .in0_low_addr       (in0_low_addr           ),
        .in0_high_addr      (in0_high_addr          ),
        .in1_low_addr       (in1_low_addr           ),
        .in1_high_addr      (in1_high_addr          ),
        .out_low_addr       (out_low_addr           ),
        .out_high_addr      (out_high_addr          ),
        .stage              (stage_axi              ),
        .configs            (configs_axi            ),

        .S_AXI_ACLK         (ap_clk                 ),
        .S_AXI_ARESETN      (ap_resetn              ),
        .S_AXI_AWADDR       (s_axi_control_AWADDR   ),
        .S_AXI_AWPROT       (3'b000                 ),
        .S_AXI_AWVALID      (s_axi_control_AWVALID  ),
        .S_AXI_AWREADY      (s_axi_control_AWREADY  ),
        .S_AXI_WDATA        (s_axi_control_WDATA    ),
        .S_AXI_WSTRB        (s_axi_control_WSTRB    ),
        .S_AXI_WVALID       (s_axi_control_WVALID   ),
        .S_AXI_WREADY       (s_axi_control_WREADY   ),
        .S_AXI_BRESP        (s_axi_control_BRESP    ),
        .S_AXI_BVALID       (s_axi_control_BVALID   ),
        .S_AXI_BREADY       (s_axi_control_BREADY   ),
        .S_AXI_ARADDR       (s_axi_control_ARADDR   ),
        .S_AXI_ARPROT       (3'b000                 ),
        .S_AXI_ARVALID      (s_axi_control_ARVALID  ),
        .S_AXI_ARREADY      (s_axi_control_ARREADY  ),
        .S_AXI_RDATA        (s_axi_control_RDATA    ),
        .S_AXI_RRESP        (s_axi_control_RRESP    ),
        .S_AXI_RVALID       (s_axi_control_RVALID   ),
        .S_AXI_RREADY       (s_axi_control_RREADY   )
    );

    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin: config_array
            always @(posedge ap_clk) begin
                if (!ap_resetn) begin
                    configs_snake[i] <= 4'b0;
                end
                else begin
                    configs_snake[i] <= configs_axi[3:0];
                end
            end
        end
    endgenerate

    generate
        for (i=0; i<8; i=i+1) begin: tiny_config_array
            always @(posedge ap_clk) begin
                if (!ap_resetn) begin
                    tiny_configs_snake[i] <= 4'b0;
                end
                else begin
                    tiny_configs_snake[i] <= configs_axi[3:0];
                end
            end
        end
    endgenerate

    always @(posedge ap_clk) begin
        if (!ap_resetn) begin
            stage_start <= 1'b0;
            stage       <= 32'b0;
            configs     <= 32'b0;
        end
        else begin
            stage_start <= stage_start_axi;
            stage       <= stage_axi;
            configs     <= configs_axi;
        end
    end

    // control AXI-FULL-Master
    always @(posedge ap_clk) begin
        if (!ap_resetn) begin
            in0_read_address    <= 64'b0;
            in0_read_enable     <= 1'b0;
            in1_read_address    <= 64'b0;
            in1_read_enable     <= 1'b0;
            out_write_address   <= 64'b0;
            out_write_data      <= 64'b0;
            out_write_enable    <= 1'b0;
        end 
        else begin
            if(stage == 32'd0 && stage_start && ~stage_0_done) begin
                in0_read_address <= {in0_high_addr, in0_low_addr};
                in0_read_enable  <= 1'b1;
                in1_read_address <= {in1_high_addr, in1_low_addr};
                in1_read_enable  <= 1'b1;
            end
            else if(stage == 32'd2 && stage_start) begin
                out_write_address <= {out_high_addr, out_low_addr};
                out_write_data    <= axi_write_data;
                out_write_enable  <= axi_write_enable;
            end
            else if(stage == 32'd1) begin
                in0_read_address    <= 64'b0;
                in0_read_enable     <= 1'b0;
                in1_read_address    <= 64'b0;
                in1_read_enable     <= 1'b0;
                out_write_address   <= 64'b0;
                out_write_data      <= 64'b0;
                out_write_enable    <= 1'b0;
            end
            else begin
                in0_read_address    <= 64'b0;
                in0_read_enable     <= 1'b0;
                in1_read_address    <= 64'b0;
                in1_read_enable     <= 1'b0;
                out_write_address   <= 64'b0;
                out_write_data      <= 64'b0;
                out_write_enable    <= 1'b0;
            end
        end
    end

    axi_full_master_r u_in0_axi_full_master
	(   
        .stage_start            (stage_start && (stage == 32'd0) && ~stage_0_done   ),
        .read_address           (in0_read_address                                   ),
        .read_data              (in0_read_data                                      ),
        .read_enable            (in0_read_enable                                    ),

		.M_AXI_ACLK             (ap_clk                                             ),
		.M_AXI_ARESETN          (ap_resetn                                          ),

		.M_AXI_ARID             (m_axi_gmem0_ARID                                   ),
		.M_AXI_ARADDR           (m_axi_gmem0_ARADDR                                 ),
		.M_AXI_ARLEN            (m_axi_gmem0_ARLEN                                  ),
		.M_AXI_ARSIZE           (m_axi_gmem0_ARSIZE                                 ),
		.M_AXI_ARBURST          (m_axi_gmem0_ARBURST                                ),
		.M_AXI_ARLOCK           (m_axi_gmem0_ARLOCK                                 ),
		.M_AXI_ARCACHE          (m_axi_gmem0_ARCACHE                                ),
		.M_AXI_ARPROT           (m_axi_gmem0_ARPROT                                 ),
		.M_AXI_ARQOS            (m_axi_gmem0_ARQOS                                  ),
		.M_AXI_ARVALID          (m_axi_gmem0_ARVALID                                ),
		.M_AXI_ARREADY          (m_axi_gmem0_ARREADY                                ),

		.M_AXI_RID              (m_axi_gmem0_RID                                    ),
		.M_AXI_RDATA            (m_axi_gmem0_RDATA                                  ),
		.M_AXI_RRESP            (m_axi_gmem0_RRESP                                  ),
		.M_AXI_RLAST            (m_axi_gmem0_RLAST                                  ),
		.M_AXI_RVALID           (m_axi_gmem0_RVALID                                 ),
		.M_AXI_RREADY           (m_axi_gmem0_RREADY                                 )
	);

    axi_full_master_r u_in1_axi_full_master
	(   
        .stage_start            (stage_start && (stage == 32'd0) && ~stage_0_done   ),
        .read_address           (in1_read_address                                   ),
        .read_data              (in1_read_data                                      ),
        .read_enable            (in1_read_enable                                    ),

		.M_AXI_ACLK             (ap_clk                                             ),
		.M_AXI_ARESETN          (ap_resetn                                          ),

		.M_AXI_ARID             (m_axi_gmem1_ARID                                   ),
		.M_AXI_ARADDR           (m_axi_gmem1_ARADDR                                 ),
		.M_AXI_ARLEN            (m_axi_gmem1_ARLEN                                  ),
		.M_AXI_ARSIZE           (m_axi_gmem1_ARSIZE                                 ),
		.M_AXI_ARBURST          (m_axi_gmem1_ARBURST                                ),
		.M_AXI_ARLOCK           (m_axi_gmem1_ARLOCK                                 ),
		.M_AXI_ARCACHE          (m_axi_gmem1_ARCACHE                                ),
		.M_AXI_ARPROT           (m_axi_gmem1_ARPROT                                 ),
		.M_AXI_ARQOS            (m_axi_gmem1_ARQOS                                  ),
		.M_AXI_ARVALID          (m_axi_gmem1_ARVALID                                ),
		.M_AXI_ARREADY          (m_axi_gmem1_ARREADY                                ),

		.M_AXI_RID              (m_axi_gmem1_RID                                    ),
		.M_AXI_RDATA            (m_axi_gmem1_RDATA                                  ),
		.M_AXI_RRESP            (m_axi_gmem1_RRESP                                  ),
		.M_AXI_RLAST            (m_axi_gmem1_RLAST                                  ),
		.M_AXI_RVALID           (m_axi_gmem1_RVALID                                 ),
		.M_AXI_RREADY           (m_axi_gmem1_RREADY                                 )
	);

    axi_full_master_w u_out_axi_full_master
	(   
        .stage_start            (stage_start && (stage == 32'd2)                    ),
        .write_done             (stage_2_done                                       ),
        .write_address          (out_write_address                                  ),
        .write_data             (out_write_data                                     ),
        .write_enable           (out_write_enable                                   ),
        .write_ready            (out_write_ready                                    ),
        .read_address           (64'b0                                              ),
        .read_data              (                                                   ),
        .read_enable            (1'b0                                               ),

		.M_AXI_ACLK             (ap_clk                                             ),
		.M_AXI_ARESETN          (ap_resetn                                          ),

		.M_AXI_AWID             (m_axi_gmem2_AWID                                   ),
		.M_AXI_AWADDR           (m_axi_gmem2_AWADDR                                 ),
		.M_AXI_AWLEN            (m_axi_gmem2_AWLEN                                  ),
		.M_AXI_AWSIZE           (m_axi_gmem2_AWSIZE                                 ),
		.M_AXI_AWBURST          (m_axi_gmem2_AWBURST                                ),
		.M_AXI_AWLOCK           (m_axi_gmem2_AWLOCK                                 ),
		.M_AXI_AWCACHE          (m_axi_gmem2_AWCACHE                                ),
		.M_AXI_AWPROT           (m_axi_gmem2_AWPROT                                 ),
		.M_AXI_AWQOS            (m_axi_gmem2_AWQOS                                  ),
		.M_AXI_AWVALID          (m_axi_gmem2_AWVALID                                ),
		.M_AXI_AWREADY          (m_axi_gmem2_AWREADY                                ),

		.M_AXI_WDATA            (m_axi_gmem2_WDATA                                  ),
		.M_AXI_WSTRB            (m_axi_gmem2_WSTRB                                  ),
		.M_AXI_WLAST            (m_axi_gmem2_WLAST                                  ),
		.M_AXI_WVALID           (m_axi_gmem2_WVALID                                 ),
		.M_AXI_WREADY           (m_axi_gmem2_WREADY                                 ),

		.M_AXI_BID              (m_axi_gmem2_BID                                    ),
		.M_AXI_BRESP            (m_axi_gmem2_BRESP                                  ),
		.M_AXI_BVALID           (m_axi_gmem2_BVALID                                 ),
		.M_AXI_BREADY           (m_axi_gmem2_BREADY                                 )
	);

    assign m_axi_gmem2_WID = m_axi_gmem2_AWID;
    assign m_axi_gmem2_AWREGION = 4'b0000;
    assign m_axi_gmem2_ARREGION = 4'b0000;

    // DATA STREAM: AXI-FULL(From DDR) --> AR2BW --> BRAM(store in stage 0) --> BR2AS --> ACCELERATORs(read in stage 1)) --> AS2BW --> BRAM(store in stage 1) --> BR2AW --> AXI-FULL(To DDR)

    // AXI-FULL transfer to BRAM

    DIN_TRANS in0_DIN_TRANS(
        .axi_ACLK           (ap_clk                                                 ),
        .axi_ARESETN        (ap_resetn                                              ),
        .stage_start        (stage_start && (stage == 32'd0)                        ),
        .axi_RDATA          (in0_read_data                                          ),
        .axi_RLAST          (m_axi_gmem0_RLAST                                      ),
        .axi_SHAKE          (m_axi_gmem0_RVALID && m_axi_gmem0_RREADY               ),
        .bram_wea           (in0_bram_wea                                           ),
        .bram_addra         (in0_bram_addra                                         ),
        .bram_dina          (in0_bram_dina                                          ),
        .bram_wdone         (in0_bram_wdone                                         )
    );

    DIN_TRANS in1_DIN_TRANS(
        .axi_ACLK           (ap_clk                                                 ),
        .axi_ARESETN        (ap_resetn                                              ),
        .stage_start        (stage_start && (stage == 32'd0)                        ),
        .axi_RDATA          (in1_read_data                                          ),
        .axi_RLAST          (m_axi_gmem1_RLAST                                      ),
        .axi_SHAKE          (m_axi_gmem1_RVALID && m_axi_gmem1_RREADY               ),
        .bram_wea           (in1_bram_wea                                           ),
        .bram_addra         (in1_bram_addra                                         ),
        .bram_dina          (in1_bram_dina                                          ),
        .bram_wdone         (in1_bram_wdone                                         )
    );

    assign all_in0_bram_wdone = in0_bram_wdone[0] & in0_bram_wdone[1] & in0_bram_wdone[2] & in0_bram_wdone[3] & in0_bram_wdone[4] & in0_bram_wdone[5] & in0_bram_wdone[6] & in0_bram_wdone[7] & in0_bram_wdone[8] & in0_bram_wdone[9] & in0_bram_wdone[10] & in0_bram_wdone[11] & in0_bram_wdone[12] & in0_bram_wdone[13] & in0_bram_wdone[14] & in1_bram_wdone[15];

    assign all_in1_bram_wdone = in1_bram_wdone[0] & in1_bram_wdone[1] & in1_bram_wdone[2] & in1_bram_wdone[3] & in1_bram_wdone[4] & in1_bram_wdone[5] & in1_bram_wdone[6] & in1_bram_wdone[7] & in1_bram_wdone[8] & in1_bram_wdone[9] & in1_bram_wdone[10] & in1_bram_wdone[11] & in1_bram_wdone[12] & in1_bram_wdone[13] & in1_bram_wdone[14] & in1_bram_wdone[15];

    assign stage_0_done = all_in0_bram_wdone && all_in1_bram_wdone;

    // in0 URAM
    generate
        for (i = 0; i < 16; i = i + 1) begin : in0_uram_array
            uram_top in0_uram (
                .rst_n  (ap_resetn              ),
                .clk    (ap_clk                 ),
                .dina   (in0_bram_dina[i]       ),
                .addra  (in0_bram_addra[i]      ),
                .wea    (in0_bram_wea[i]        ),
                .addrb  (in0_bram_addrb[i]      ),
                .doutb  (in0_bram_doutb[i]      ),
                .enb    (in0_bram_enb[i]        )
            );
        end
    endgenerate

    // in1 URAM
    generate
        for (i = 0; i < 16; i = i + 1) begin : in1_uram_array
            uram_top in1_uram (
                .rst_n  (ap_resetn              ),
                .clk    (ap_clk                 ),
                .dina   (in1_bram_dina[i]       ),
                .addra  (in1_bram_addra[i]      ),
                .wea    (in1_bram_wea[i]        ),
                .addrb  (in1_bram_addrb[i]      ),
                .doutb  (in1_bram_doutb[i]      ),
                .enb    (in1_bram_enb[i]        )
            );
        end
    endgenerate

    // BRAM transfer to AXI-Stream

    // in0
    ACC_DIN_TRANS in0_ACC_DIN_TRANS(
        .clk                 (ap_clk                         ),
        .rst_n               (ap_resetn                      ),
        .stage_start         (stage_start && (stage == 32'd1)),
        .configs             (configs                               ),
        .in_bram_enb         (in0_bram_enb                   ),
        .in_bram_addrb       (in0_bram_addrb                 ),
        .in_bram_doutb       (in0_bram_doutb                 ),
        .full_atdata         (in0_tdata                      ),
        .full_atvalid        (in0_tvalid                     ),
        .tiny_atdata         (tiny_in0_tdata                 ),
        .tiny_atvalid        (tiny_in0_tvalid                )
    );

    // in1
    ACC_DIN_TRANS in1_ACC_DIN_TRANS(
        .clk                 (ap_clk                         ),
        .rst_n               (ap_resetn                      ),
        .stage_start         (stage_start && (stage == 32'd1)),
        .configs             (configs                               ),
        .in_bram_enb         (in1_bram_enb                   ),
        .in_bram_addrb       (in1_bram_addrb                 ),
        .in_bram_doutb       (in1_bram_doutb                 ),
        .full_atdata         (in1_tdata                      ),
        .full_atvalid        (in1_tvalid                     ),
        .tiny_atdata         (tiny_in1_tdata                 ),
        .tiny_atvalid        (tiny_in1_tvalid                )
         
    );

    // TO Acceleraters
    // Config=0: SOFTMAX
    // Config=1: LAYERNORM
    // Config=2: RMSNORM
    // Config=3: SILU
    // Config=4: GELU
    // Config=5: ADD
    // Config=6: MUL

    // control signals for accelerators
    generate
        for (i=0; i<8; i=i+1) begin: acc_in_array
            always@(posedge ap_clk) begin
                if (!ap_resetn) begin
                    snake_stage_start[i]    <=  1'b0;
                    acc_in0_tvalid[i]       <=  1'b0;
                    acc_in0_tdata[i]        <=  64'd0;
                    acc_in1_tvalid[i]       <=  1'b0;
                    acc_in1_tdata[i]        <=  64'd0;
                end 
                else begin
                    if(stage_start && (stage == 32'd1)) begin
                        acc_in0_tvalid[i]    <= in0_tvalid[i];
                        acc_in0_tdata[i]     <= in0_tdata[i];
                        acc_in1_tvalid[i]    <= in1_tvalid[i];
                        acc_in1_tdata[i]     <= in1_tdata[i];
                        snake_stage_start[i] <= stage_start;
                    end
                    else begin
                        snake_stage_start[i]    <=  1'b0;
                        acc_in0_tvalid[i]       <=  1'b0;
                        acc_in0_tdata[i]        <=  64'd0;
                        acc_in1_tvalid[i]       <=  1'b0;
                        acc_in1_tdata[i]        <=  64'd0;
                    end
                end
            end
        end
    endgenerate

    generate
        for (i=0; i<8; i=i+1) begin: tiny_acc_in_array
            always@(posedge ap_clk) begin
                if (!ap_resetn) begin
                    tiny_snake_stage_start[i]    <=  1'b0;
                    tiny_acc_in0_tvalid[i]       <=  1'b0;
                    tiny_acc_in0_tdata[i]        <=  64'd0;
                    tiny_acc_in1_tvalid[i]       <=  1'b0;
                    tiny_acc_in1_tdata[i]        <=  64'd0;
                end 
                else begin
                    if(stage_start && (stage == 32'd1)) begin
                        tiny_snake_stage_start[i] <= stage_start;
                        tiny_acc_in0_tvalid[i]    <= tiny_in0_tvalid[i];
                        tiny_acc_in0_tdata[i]     <= tiny_in0_tdata[i];
                        tiny_acc_in1_tvalid[i]    <= tiny_in1_tvalid[i];
                        tiny_acc_in1_tdata[i]     <= tiny_in1_tdata[i];
                    end
                    else begin
                        tiny_snake_stage_start[i]    <=  1'b0;
                        tiny_acc_in0_tvalid[i]       <=  1'b0;
                        tiny_acc_in0_tdata[i]        <=  64'd0;
                        tiny_acc_in1_tvalid[i]       <=  1'b0;
                        tiny_acc_in1_tdata[i]        <=  64'd0;
                    end
                end
            end
        end
    endgenerate

    //FIFO_ARRAY1
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_fifo_array1
            fifo_512 fifo1 (
                .clk    (ap_clk             ),
                .din    (fifo1_din[i]       ),
                .wr_en  (fifo1_wr_en[i]     ),
                .rd_en  (fifo1_rd_en[i]     ),
                .dout   (fifo1_dout[i]      )
            );
        end
    endgenerate

    //FIFO_ARRAY2
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_fifo_array2
            fifo_512 fifo2 (
                .clk    (ap_clk             ),
                .din    (fifo2_din[i]       ),
                .wr_en  (fifo2_wr_en[i]     ),
                .rd_en  (fifo2_rd_en[i]     ),
                .dout   (fifo2_dout[i]      )
            );
        end
    endgenerate

    // FULL GLUT BLOCK
    generate
        for (i = 0; i < 8; i = i + 1) begin : FULL_SNAKE_array
            GLUT_SNAKE_array FULL_GLUT_SNAKE_array
            (
                .clk              (ap_clk                   ),
                .rst_n            (ap_resetn                ),
                .stage_start      (snake_stage_start[i]     ),
                .configs          (configs_snake[i]         ),
                .input_atvalid    (acc_in0_tvalid[i]        ),
                .input_atdata     (acc_in0_tdata[i]         ),
                .input_btvalid    (acc_in1_tvalid[i]        ),
                .input_btdata     (acc_in1_tdata[i]         ),
                .fifo1_din        (fifo1_din[i]             ),
                .fifo1_wr_en      (fifo1_wr_en[i]           ),
                .fifo1_dout       (fifo1_dout[i]            ),
                .fifo1_rd_en      (fifo1_rd_en[i]           ),
                .fifo2_din        (fifo2_din[i]             ),
                .fifo2_wr_en      (fifo2_wr_en[i]           ),
                .fifo2_dout       (fifo2_dout[i]            ),
                .fifo2_rd_en      (fifo2_rd_en[i]           ),
                .result_tvalid    (snake_out_tvalid[i]      ),
                .result_tdata     (snake_out_tdata[i]       )
            );
        end
    endgenerate

    // TINY FIFO_ARRAY1
    generate
        for (i = 0; i < 8; i = i + 1) begin : tiny_fifo_array1
            fifo_512_64 fifo3 (
                .clk    (ap_clk             ),
                .din    (fifo3_din[i]       ),
                .wr_en  (fifo3_wr_en[i]     ),
                .rd_en  (fifo3_rd_en[i]     ),
                .dout   (fifo3_dout[i]      )
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin : TINY_SNAKE_array
            tiny_GLUT_SNAKE_array TINY_GLUT_SNAKE_array(
                .clk                 (ap_clk                    ),
                .rst_n               (ap_resetn                 ),
                .stage_start         (tiny_snake_stage_start[i] ),
                .input_atvalid       (tiny_acc_in0_tvalid[i]    ),
                .input_atdata        (tiny_acc_in0_tdata[i]     ),
                .input_btvalid       (tiny_acc_in1_tvalid[i]    ),
                .input_btdata        (tiny_acc_in1_tdata[i]     ),
                .configs             (tiny_configs_snake[i]     ),
                .fifo1_din           (fifo3_din[i]              ),
                .fifo1_wr_en         (fifo3_wr_en[i]            ),
                .fifo1_dout          (fifo3_dout[i]             ),
                .fifo1_rd_en         (fifo3_rd_en[i]            ),
                .result_tvalid       (tiny_snake_out_tvalid[i]  ),
                .result_tdata        (tiny_snake_out_tdata[i]   ) 
            );
        end
    endgenerate

    // out_data choose from 7 calculators
    generate
        for (i=0; i<8; i=i+1) begin: acc_out_fp32_array
            always@(posedge ap_clk) begin
                if (!ap_resetn) begin
                    acc_out_data_fp32[i]    <= 128'd0;
                    acc_out_valid_fp32[i]   <= 1'b0;
                end 
                else begin
                    if(stage_start && (stage == 32'd1)) begin
                        acc_out_data_fp32[i]   <= snake_out_tdata[i];
                        acc_out_valid_fp32[i]  <= snake_out_tvalid[i];
                    end
                    else begin
                        acc_out_data_fp32[i]    <= 128'd0;
                        acc_out_valid_fp32[i]   <= 1'b0;
                    end
                end
            end
        end
    endgenerate

    // FP32 transfer to BF16
    generate
        for (i = 0; i < 8; i = i + 1) begin : FP32_2_BF16_QUAD_array
            FP32_2_BF16_QUAD FP32_2_BF16_QUAD(
                .fp32_in      (acc_out_data_fp32[i]        ),
                .bf16_out     (trans_acc_out_data_bf16[i]  ) 
            );
        end
    endgenerate

    generate
        for (i=0; i<8; i=i+1) begin: acc_out_bf16_array
            always@(posedge ap_clk) begin
                if (!ap_resetn) begin
                    acc_out_data_bf16[i]    <= 64'd0;
                    acc_out_valid_bf16[i]   <= 1'b0;
                end
                else begin
                    acc_out_data_bf16[i]    <= trans_acc_out_data_bf16[i];
                    acc_out_valid_bf16[i]   <= acc_out_valid_fp32[i];
                end
            end
        end
    endgenerate

    // AXI-Stream tramsfer to BRAM

    ACC_DOUT_TRANS out_ACC_DOUT_TRANS
    (
        .clk                (ap_clk                         ),
        .rst_n              (ap_resetn                      ),
        .stage_start        (stage_start && (stage == 32'd1)),
        .configs            (configs                        ),
        .full_atdata        (acc_out_data_bf16              ),
        .full_atvalid       (acc_out_valid_bf16             ),
        .tiny_atdata        (tiny_snake_out_tdata           ),
        .tiny_atvalid       (tiny_snake_out_tvalid          ),
        .out_bram_wea       (out_bram_wea                   ),
        .out_bram_addra     (out_bram_addra                 ),
        .out_bram_dina      (out_bram_dina                  ),
        .stage_done         (stage_1_done                   )
    );

    // out URAM
    generate
        for (i = 0; i < 16; i = i + 1) begin : out_uram_array
            uram_top out_uram (
                .rst_n  (ap_resetn              ),
                .clk    (ap_clk                 ),
                .dina   (out_bram_dina[i]       ),
                .addra  (out_bram_addra[i]      ),
                .wea    (out_bram_wea[i]        ),
                .addrb  (out_bram_addrb[i]      ),
                .doutb  (out_bram_doutb[i]      ),
                .enb    (out_bram_enb[i]        )
            );
        end
    endgenerate

    // BRAM transfer to AXI-FULL
    DOUT_TRANS out_DOUT_TRANS (
        .axi_ACLK        (ap_clk                         ),
        .axi_ARESETN     (ap_resetn                      ),
        .stage_start     (stage_start && (stage == 32'd2)),
        .write_data      (axi_write_data                 ),
        .write_enable    (axi_write_enable               ),
        .write_ready     (out_write_ready                ),
        .bram_enb        (out_bram_enb                   ),
        .bram_addrb      (out_bram_addrb                 ),
        .bram_doutb      (out_bram_doutb                 )
    );

    // Generate stage_done signal
    always@(posedge ap_clk) begin
        if (!ap_resetn) begin
            stage_done <= 1'b0;
        end 
        else begin
            if (stage == 32'd0) begin
                stage_done <= stage_0_done;
            end
            else if(stage == 32'd1)begin
                stage_done <= stage_1_done;
            end
            else if(stage == 32'd2)begin
                stage_done <= stage_2_done;
            end
            else begin
                stage_done <= 1'b0;
            end
        end
    end

endmodule