module inst_mem(
  input logic [31:0] i_pc_addr,
  output logic [31:0] o_inst
);

logic [3:0][7:0] imem [2**11-1:0];

	initial begin
		$readmemh("../02_test/dump/mem.dump", imem);
	end

	assign o_inst = imem[i_pc_addr[12:2]];

endmodule
