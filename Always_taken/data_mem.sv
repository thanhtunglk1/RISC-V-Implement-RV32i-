module data_mem(
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic [15:0] i_lsu_addr,//pointer_addr    
  input  logic [31:0] i_st_data, //rs2_data   
  input  logic        i_lsu_wren,//sel_write
  input  logic [2:0]  i_control, //func3  
  output logic [31:0] o_dmem_data  //wb_regfile 
);
	localparam [2:0]LB   = 3'b000,
					    LH   = 3'b001,
					    LW   = 3'b010,
					    LBU  = 3'b100,
					    LHU  = 3'b101;

	localparam [12:0] end_addr = 13'b1_1111_1111_1111;
	
	localparam SIZE = 8192;//8192;
	
	logic [7:0] dmem [SIZE - 1:0];
	
	logic [13:0] addr_even;
   assign addr_even = i_lsu_addr[12:0] & 13'b1_1111_1111_1110;// xoa bit cuoi
	
	logic  o_dmem_sel;
   assign o_dmem_sel = (i_lsu_addr[15:12] == 4'h2) | (i_lsu_addr[15:12] == 4'h3);
	
	longint i;
	
	always_ff @(posedge i_clk) begin
		if(~i_rst_n) begin
			for(i = 0; i < SIZE; i++) begin
				dmem[i] <= 8'b0;
			end
		end else if(i_lsu_wren && o_dmem_sel) begin
	   case(i_control[1:0])
		  2'b00: if(i_lsu_addr[12:0] <= end_addr) dmem[i_lsu_addr[12:0]] = i_st_data[7:0];
		  2'b01: begin
		    if(addr_even <= end_addr)     dmem[addr_even]     = i_st_data[7:0];
			 if(addr_even <= end_addr + 1) dmem[addr_even + 1] = i_st_data[15:8];
		  end
		  2'b10: begin
		    if(addr_even <= end_addr)     dmem[addr_even]     = i_st_data[7:0];
			 if(addr_even <= end_addr + 1) dmem[addr_even + 1] = i_st_data[15:8];
			 if(addr_even <= end_addr + 2) dmem[addr_even + 2] = i_st_data[23:16];
			 if(addr_even <= end_addr + 3) dmem[addr_even + 3] = i_st_data[31:24];
		  end
		endcase
	 end
	end

	logic [7:0] temp [3:0];
	always_comb begin: proc_check_out_data
    if(addr_even <= end_addr)     temp[0] = dmem[addr_even];
	 else temp[0] = 8'h00;
	 
	 if(addr_even + 1 <= end_addr) temp[1] = dmem[addr_even + 1];
	 else temp[1] = 8'h00;
	 
	 if(addr_even + 2 <= end_addr) temp[2] = dmem[addr_even + 2];
	 else temp[2] = 8'h00;
	 
	 if(addr_even + 3 <= end_addr) temp[3] = dmem[addr_even + 3];
	 else temp[3] = 8'h00;
   end
	
	always_comb begin: proc_select_out_data
    case(i_control)
	   LB : begin
		  if(i_lsu_addr[12:0] <= end_addr) o_dmem_data = {{24{dmem[i_lsu_addr[12:0]][7]}}, dmem[i_lsu_addr[12:0]]};
		  else o_dmem_data = 32'h0;
		end
		LH : o_dmem_data = {{16{temp[1][7]}}, temp[1], temp[0]};
		LW : o_dmem_data = {temp[3], temp[2], temp[1], temp[0]};
	   LBU: begin
		  if(i_lsu_addr[12:0] <= end_addr) o_dmem_data = {24'h0, dmem[i_lsu_addr[12:0]]};
		  else o_dmem_data = 32'h0;
		end
		LHU: o_dmem_data = {16'h0, temp[1], temp[0]};
		default: o_dmem_data = 32'hz;
	 endcase
  end
	
endmodule 
