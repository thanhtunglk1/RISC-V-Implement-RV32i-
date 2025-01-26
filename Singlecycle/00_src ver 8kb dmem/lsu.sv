module lsu(
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic [31:0] i_lsu_addr,   
  input  logic [31:0] i_st_data,    
  input  logic        i_lsu_wren,
  input  logic 		  i_lsu_rden,
  input  logic [2:0]  i_control,  
  output logic [31:0] o_ld_data,    
  output logic [31:0] o_io_ledr,     
  output logic [31:0] o_io_ledg,     
  output logic [6:0]  o_io_hex0,     
  output logic [6:0]  o_io_hex1,     
  output logic [6:0]  o_io_hex2,     
  output logic [6:0]  o_io_hex3,     
  output logic [6:0]  o_io_hex4,     
  output logic [6:0]  o_io_hex5,     
  output logic [6:0]  o_io_hex6,     
  output logic [6:0]  o_io_hex7,    
  output logic [31:0] o_io_lcd,      
  input  logic [31:0] i_io_sw,    
  input  logic [3:0]  i_io_btn 
  /*
  output logic        o_ack,    
  
  output logic [17:0] SRAM_ADDR,
  inout  wire  [15:0] SRAM_DQ  ,
  output logic        SRAM_CE_N,
  output logic        SRAM_WE_N,
  output logic        SRAM_LB_N,
  output logic        SRAM_UB_N,
  output logic        SRAM_OE_N  
*/ 
);

  logic [31:0] in_buf_data, out_buft_data, o_dmem_data ;
  //logic  [31:0]  sram_data;
  //mux_ld_data 
  always_comb begin: proc_mux_ld_data
    if(i_lsu_addr[15:8] == 8'h78) o_ld_data = in_buf_data;
	 else if (i_lsu_addr[15:8] == 8'h70) o_ld_data = out_buft_data;
	 else if ((i_lsu_addr[15:12] == 4'h2) || (i_lsu_addr[15:12] == 4'h3)) o_ld_data = o_dmem_data;
	 else o_ld_data = 32'hz;
  end
  
  input_buffer i_buf_mem(
  .i_control(i_control),
  .i_in_buf_addr(i_lsu_addr[7:0]),
  .i_io_sw(i_io_sw), 
  .i_io_btn(i_io_btn),
  .o_in_buf_data(in_buf_data)
  );

  output_buffer o_buf_mem(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n), 
  .i_out_buf_addr(i_lsu_addr[15:0]),    
  .i_out_buf_data(i_st_data),    
  .i_lsu_wren(i_lsu_wren),
  .i_control(i_control),  
  .o_out_buf_data(out_buft_data),    
  .o_io_ledr(o_io_ledr),     
  .o_io_ledg(o_io_ledg),     
  .o_io_hex0(o_io_hex0),     
  .o_io_hex1(o_io_hex1),     
  .o_io_hex2(o_io_hex2),     
  .o_io_hex3(o_io_hex3),     
  .o_io_hex4(o_io_hex4),     
  .o_io_hex5(o_io_hex5),     
  .o_io_hex6(o_io_hex6),     
  .o_io_hex7(o_io_hex7),    
  .o_io_lcd(o_io_lcd)
);
/*
  control_sram sram_mem(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_lsu_addr(i_lsu_addr[15:0]),  
  .i_st_data(i_st_data),   
  .i_lsu_wren(i_lsu_wren),
  .i_lsu_rden(i_lsu_rden),
  .i_control(i_control),  
  .o_sram_data(sram_data),
  
  .o_ack(o_ack),
  
  .SRAM_ADDR(SRAM_ADDR),
  .SRAM_DQ(SRAM_DQ),
  .SRAM_CE_N(SRAM_CE_N),
  .SRAM_WE_N(SRAM_WE_N),
  .SRAM_LB_N(SRAM_LB_N),
  .SRAM_UB_N(SRAM_UB_N),
  .SRAM_OE_N(SRAM_OE_N) 
);
*/
  data_mem dmem(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_lsu_addr(i_lsu_addr),
  .i_st_data(i_st_data),
  .i_lsu_wren(i_lsu_wren),
  .i_control(i_control),
  .o_dmem_data(o_dmem_data)
  );
endmodule 
