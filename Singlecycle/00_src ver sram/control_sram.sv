module control_sram(
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic [15:0] i_lsu_addr,//pointer_addr    
  input  logic [31:0] i_st_data, //rs2_data   
  input  logic        i_lsu_wren,//sel_write
  input  logic			 i_lsu_rden,//sel_read
  input  logic [2:0]  i_control, //func3  
  output logic [31:0] o_sram_data,  //wb_regfile 
  
  output logic        o_ack,
  
  output logic [17:0] SRAM_ADDR,
  inout  wire  [15:0] SRAM_DQ  ,
  output logic        SRAM_CE_N,
  output logic        SRAM_WE_N,
  output logic        SRAM_LB_N,
  output logic        SRAM_UB_N,
  output logic        SRAM_OE_N  
);
  
  typedef enum logic[1:0]{
  IDLE,
  RD_SET,
  WR_SET,
  WAIT
  } e_state;
  
  e_state p_state, n_state;
  
  logic d_mem_sel, read_en, write_en, ack;
  logic [17:0] addr_sram;
  logic [3:0]  b_mask;
  logic [31:0] wr_data, rd_data;
  
  assign d_mem_sel = (i_lsu_addr[15:12] == 4'h3) || (i_lsu_addr[15:12] == 4'h2);	
  assign addr_sram = {3'b0, i_lsu_addr[15:1]}; //shift_right
  
  //bit mask and wr_data control
  always_comb begin: proc_store_load_control
    b_mask  = 4'b0000;
	 wr_data = 'z;
    if(i_lsu_wren && ~i_lsu_rden) begin
	   case(i_control[1:0])
		  2'b00: begin //SB
		    b_mask  = i_lsu_addr[0] ?  4'b0010 : 4'b0001;
 			 wr_data = i_lsu_addr[0] ? {16'b0, i_st_data[7:0], 8'b0} : i_st_data;
		  end
		  2'b01: begin //SH
		    b_mask  = 4'b0011;
 			 wr_data = i_st_data;
		  end
		  2'b10: begin //SW
		    b_mask  = 4'b1111;
 			 wr_data = i_st_data;
		  end
		  default: begin
		    b_mask  = 4'b0000;
			 wr_data = 'z;
		  end
		endcase
	 end else if(~i_lsu_wren && i_lsu_rden) begin
	   case(i_control) 
		  3'b000: b_mask  = 4'b0011;
		  3'b001: b_mask  = 4'b0011;
		  3'b010: b_mask  = 4'b1111;
		  3'b100: b_mask  = 4'b0011;
		  3'b101: b_mask  = 4'b0011;
		  default: b_mask = 4'b0000;
		endcase
	 end
  end
  
  //store_control
  always_comb begin: proc_next_state
    case(p_state)
	   IDLE: begin
		  if(~d_mem_sel) n_state = IDLE; 
		  //else n_state = i_lsu_wren ? WR_SET : RD_SET;
		  else begin
		    case({i_lsu_wren,i_lsu_rden})
			   2'b10: n_state = WR_SET;
				2'b01: n_state = RD_SET;
				default: n_state = IDLE;
			 endcase
		  end
		end
		
		RD_SET: n_state = WAIT;
		
		WR_SET: n_state = WAIT;
		
		WAIT: begin
		  case(ack) 
		    1'b0: n_state = WAIT;
			 1'b1: n_state = IDLE;
		  endcase
		end
		
	   default: n_state = IDLE;
	 endcase
  end
 
  always_ff @(posedge i_clk) begin: proc_update_state
    if(~i_rst_n) p_state <= IDLE;
	 else p_state <= n_state;
  end
  
  always_comb begin: proc_en_signal
    case(p_state)
	   IDLE  : {read_en,write_en} = 2'b00;	 //float
	   RD_SET: {read_en,write_en} = 2'b10;  //read
		WR_SET: {read_en,write_en} = 2'b01;  //write
		WAIT  : {read_en,write_en} = 2'b00;  //float
	 endcase
  end
  
  //load control
  always_comb begin: proc_sram_load
    o_sram_data = 32'b0;
	 if(d_mem_sel) begin
	   case(i_control) 
		  3'b000: o_sram_data = i_lsu_addr[0] ? ({{24{rd_data[15]}}, rd_data[15:8]}) : ({{24{rd_data[7]}}, rd_data[7:0]});   // lb
        3'b001: o_sram_data = {{16{rd_data[15]}}, rd_data[15:0]};                                                          // lh
        3'b010: o_sram_data = rd_data; 																												// lw
        3'b100: o_sram_data = i_lsu_addr[0] ? {24'b0, rd_data[15:8]} : {24'b0, rd_data[7:0]};                     			// lbu
        3'b101: o_sram_data = rd_data;            																									// lhu
		  default: o_sram_data = 32'b0;
		endcase
	 end
  end
  
  assign o_ack = ack;
  
  sram_IS61WV25616_controller_32b_5lr sram_control(
  .i_ADDR(addr_sram),
  .i_WDATA(wr_data),
  .i_BMASK(b_mask),
  .i_WREN(write_en),
  .i_RDEN(read_en)  ,
  .o_RDATA(rd_data)  ,
  .o_ACK(ack),
  
  .SRAM_ADDR(SRAM_ADDR),
  .SRAM_DQ(SRAM_DQ),
  .SRAM_CE_N(SRAM_CE_N),
  .SRAM_WE_N(SRAM_WE_N),
  .SRAM_LB_N(SRAM_LB_N),
  .SRAM_UB_N(SRAM_UB_N),
  .SRAM_OE_N(SRAM_OE_N),
  .i_clk(i_clk),
  .i_reset(i_rst_n)
);
 
endmodule 
