	module input_buffer(
  input  logic [2:0]  i_control, //func3
  input  logic [7:0]  i_in_buf_addr,
  input  logic [31:0] i_io_sw, 
  input  logic [3:0]  i_io_btn,
  output logic [31:0] o_in_buf_data
);
  //size_input_buffer
  parameter I_BUF_SIZE = 32;
  logic [7:0] in_buffer [I_BUF_SIZE - 1:0];
  
  //address
  localparam [7:0] sw_addr  = 8'h00,
						 btn_addr = 8'h10,
						 end_addr = 8'h1F;
						 
  //func3
  localparam [2:0] LB   = 3'b000,
					    LH   = 3'b001,
					    LW   = 3'b010,
					    LBU  = 3'b100,
					    LHU  = 3'b101;

  logic [7:0] addr_even;
  logic [7:0] temp [3:0];
  
  assign in_buffer[sw_addr]     = i_io_sw[7:0];
  assign in_buffer[sw_addr + 1] = i_io_sw[15:8];
  assign in_buffer[sw_addr + 2] = i_io_sw[23:16];
  assign in_buffer[sw_addr + 3] = i_io_sw[31:24];
  assign in_buffer[btn_addr]    = {4'h0, i_io_btn};
  
  assign addr_even = i_in_buf_addr & 8'hFE;
  
  always_comb begin: proc_check_out_data
    if(addr_even <= end_addr)     temp[0] = in_buffer[addr_even];
	 else temp[0] = 8'h00;
	 
	 if(addr_even + 1 <= end_addr) temp[1] = in_buffer[addr_even + 1];
	 else temp[1] = 8'h00;
	 
	 if(addr_even + 2 <= end_addr) temp[2] = in_buffer[addr_even + 2];
	 else temp[2] = 8'h00;
	 
	 if(addr_even + 3 <= end_addr) temp[3] = in_buffer[addr_even + 3];
	 else temp[3] = 8'h00;
  end
  
  always_comb begin: proc_select_out_data
    case(i_control)
	   LB : begin
		  if(i_in_buf_addr <= end_addr) o_in_buf_data = {{24{in_buffer[i_in_buf_addr][7]}}, in_buffer[i_in_buf_addr]};
		  else o_in_buf_data = 32'h0;
		end
		LH : o_in_buf_data = {{16{temp[1][7]}}, temp[1], temp[0]};
		LW : o_in_buf_data = {temp[3], temp[2], temp[1], temp[0]};
		LBU: begin
		  if(i_in_buf_addr <= end_addr) o_in_buf_data = {24'h0, in_buffer[i_in_buf_addr]};
		  else o_in_buf_data = 32'h0;
		end
		LHU: o_in_buf_data = {16'h0, temp[1], temp[0]};
		default: o_in_buf_data = 32'hz;
	 endcase 
  end

endmodule 