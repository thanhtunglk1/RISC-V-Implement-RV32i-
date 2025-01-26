module output_buffer(
  input  logic        i_clk,
  input  logic        i_rst_n, 
  input  logic [15:0] i_out_buf_addr,//pointer_addr    
  input  logic [31:0] i_out_buf_data, //rs2_data   
  input  logic        i_lsu_wren,//sel
  input  logic [2:0]  i_control, //func3  
  output logic [31:0] o_out_buf_data, //wb_regfile    
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
  output logic [31:0] o_io_lcd
);

  parameter O_BUF_SIZE = 64;
  logic [7:0] out_buffer [O_BUF_SIZE - 1:0];
  logic [7:0] temp [3:0];
  
  localparam [2:0] LB   = 3'b000,
					    LH   = 3'b001,
					    LW   = 3'b010,
					    LBU  = 3'b100,
					    LHU  = 3'b101;
  
  localparam [15:0] red_addr   = 8'h00,
						  green_addr = 8'h10,
						  hex0_addr  = 8'h20,
						  hex1_addr  = 8'h21,
						  hex2_addr  = 8'h22,
						  hex3_addr  = 8'h23,
						  hex4_addr  = 8'h24,
						  hex5_addr  = 8'h25,
						  hex6_addr  = 8'h26,
						  hex7_addr  = 8'h27,
						  lcd_addr   = 8'h30,
						  end_addr   = 8'h3F;
  
  logic [7:0] addr_even;
  assign addr_even = i_out_buf_addr[7:0] & 8'hFE;
  
  logic o_buf_sel;
  assign o_buf_sel = (i_out_buf_addr[15:8] == 8'h70);
						  
  always_ff @(posedge i_clk) begin: proc_write_out_buffer
    if(~i_rst_n) begin
	   out_buffer[red_addr]      <= 8'b0;
		out_buffer[red_addr + 1]  <= 8'b0;
		out_buffer[red_addr + 2]  <= 8'b0;
		out_buffer[green_addr]    <= 8'b0;
		out_buffer[hex0_addr]     <= 8'b0; 
		out_buffer[hex1_addr]     <= 8'b0;
		out_buffer[hex2_addr]     <= 8'b0;
		out_buffer[hex3_addr]     <= 8'b0;
		out_buffer[hex4_addr]     <= 8'b0;
		out_buffer[hex5_addr]     <= 8'b0;
		out_buffer[hex6_addr]     <= 8'b0;
		out_buffer[hex7_addr]     <= 8'b0;
	 end else if(i_lsu_wren && o_buf_sel) begin
	   case(i_control[1:0])
		  2'b00: if(i_out_buf_addr[7:0] <= end_addr) out_buffer[i_out_buf_addr[7:0]] = i_out_buf_data[7:0];
		  2'b01: begin
		    if(addr_even <= end_addr)     out_buffer[addr_even]     = i_out_buf_data[7:0];
			 if(addr_even <= end_addr + 1) out_buffer[addr_even + 1] = i_out_buf_data[15:8];
		  end
		  2'b10: begin
		    if(addr_even <= end_addr)     out_buffer[addr_even]     = i_out_buf_data[7:0];
			 if(addr_even <= end_addr + 1) out_buffer[addr_even + 1] = i_out_buf_data[15:8];
			 if(addr_even <= end_addr + 2) out_buffer[addr_even + 2] = i_out_buf_data[23:16];
			 if(addr_even <= end_addr + 3) out_buffer[addr_even + 3] = i_out_buf_data[31:24];
		  end
		endcase
	 end
  end
  
  always_comb begin: proc_check_out_data
    if(addr_even <= end_addr)     temp[0] = out_buffer[addr_even];
	 else temp[0] = 8'h00;
	 
	 if(addr_even + 1 <= end_addr) temp[1] = out_buffer[addr_even + 1];
	 else temp[1] = 8'h00;
	 
	 if(addr_even + 2 <= end_addr) temp[2] = out_buffer[addr_even + 2];
	 else temp[2] = 8'h00;
	 
	 if(addr_even + 3 <= end_addr) temp[3] = out_buffer[addr_even + 3];
	 else temp[3] = 8'h00;
  end
  
  always_comb begin: proc_select_out_data
    case(i_control)
	   LB : begin
		  if(i_out_buf_addr[7:0] <= end_addr) o_out_buf_data = {{24{out_buffer[i_out_buf_addr[7:0]][7]}}, out_buffer[i_out_buf_addr[7:0]]};
		  else o_out_buf_data = 32'h0;
		end
		LH : o_out_buf_data = {{16{temp[1][7]}}, temp[1], temp[0]};
		LW : o_out_buf_data = {temp[3], temp[2], temp[1], temp[0]};
	   LBU: begin
		  if(i_out_buf_addr[7:0] <= end_addr) o_out_buf_data = {24'h0, out_buffer[i_out_buf_addr[7:0]]};
		  else o_out_buf_data = 32'h0;
		end
		LHU: o_out_buf_data = {16'h0, temp[1], temp[0]};
		default: o_out_buf_data = 32'hz;
	 endcase
  end

  assign o_io_ledr = {out_buffer[red_addr + 3]  , out_buffer[red_addr + 2]  , out_buffer[red_addr + 1]   , out_buffer[red_addr]};
  assign o_io_ledg = {out_buffer[green_addr + 3], out_buffer[green_addr + 2], out_buffer[green_addr  + 1], out_buffer[green_addr]};
  assign o_io_hex0 = out_buffer[hex0_addr][6:0];
  assign o_io_hex1 = out_buffer[hex1_addr][6:0];
  assign o_io_hex2 = out_buffer[hex2_addr][6:0];
  assign o_io_hex3 = out_buffer[hex3_addr][6:0];
  assign o_io_hex4 = out_buffer[hex4_addr][6:0];
  assign o_io_hex5 = out_buffer[hex5_addr][6:0];
  assign o_io_hex6 = out_buffer[hex6_addr][6:0];
  assign o_io_hex7 = out_buffer[hex7_addr][6:0];
  assign o_io_lcd  = {out_buffer[lcd_addr + 3], out_buffer[lcd_addr + 2], out_buffer[lcd_addr + 1], out_buffer[lcd_addr]};
  
endmodule 