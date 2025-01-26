module regfile(
  input logic i_clk, i_rst_n, i_rd_wren, //control
  input logic [4:0]i_rs1_addr, i_rs2_addr, i_rd_addr, //register address
  input logic [31:0]i_rd_data,
  output logic [31:0]o_rs1_data, o_rs2_data
);

  logic [31:0] registers [31:0];
  
  int i;   

  always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_registers_update
  
    if(i_rst_n == 1'b0) begin
	 
      for(i = 0; i < 32; i++) begin
		  registers[i] = 32'b0;
		end
		
    end else if(i_rd_wren && i_rd_addr != 5'd0) registers[i_rd_addr] = i_rd_data;
	 else registers[0] = 32'b0;
  end

  assign o_rs1_data = (i_rs1_addr != 5'd0) ? registers[i_rs1_addr] : 32'b0;
  assign o_rs2_data = (i_rs2_addr != 5'd0) ? registers[i_rs2_addr] : 32'b0;

endmodule
