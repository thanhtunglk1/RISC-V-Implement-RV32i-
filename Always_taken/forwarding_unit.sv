module forwarding_unit(
		
	input logic  [31:0] i_ID_inst,
	input logic  [31:0] i_EX_inst,
	
	input logic  [31:0] i_MEM_inst,
	input logic			  i_MEM_rd_wren,
	
	input logic  [31:0] i_WB_inst,
	input logic			  i_WB_rd_wren,
	
	output logic		o_forward_rs1_sel,
	output logic		o_forward_rs2_sel,

	output logic [1:0]  o_forward_a_sel,
	output logic [1:0]  o_forward_b_sel

);	
	
	localparam [1:0] no_forward  = 2'b00,
						  mem_forward = 2'b10,
						  wb_forward  = 2'b01;
	
	localparam regfile_forward 		= 1'b1,
			   regfile_non_forward 	= 1'b0;
	
	logic [4:0] ID_rs1_addr, ID_rs2_addr, EX_rs1_addr, EX_rs2_addr, MEM_rd_addr, WB_rd_addr;
	
	assign ID_rs1_addr = i_ID_inst[19:15];
	assign ID_rs2_addr = i_ID_inst[24:20];	

	assign EX_rs1_addr = i_EX_inst[19:15];
	assign EX_rs2_addr = i_EX_inst[24:20];
	
	assign MEM_rd_addr = i_MEM_inst[11:7];
	assign WB_rd_addr	 = i_WB_inst[11:7];
	
	always_comb begin: proc_forward_detect
	
		if(i_WB_rd_wren & (WB_rd_addr != 5'b0) & (WB_rd_addr == ID_rs1_addr)) o_forward_rs1_sel = regfile_forward;
		else o_forward_rs1_sel = regfile_non_forward;

 		if(i_WB_rd_wren & (WB_rd_addr != 5'b0) & (WB_rd_addr == ID_rs2_addr)) o_forward_rs2_sel = regfile_forward;
		else o_forward_rs2_sel = regfile_non_forward;

		if(i_MEM_rd_wren & (MEM_rd_addr != 5'b0) & (MEM_rd_addr == EX_rs1_addr)) 		o_forward_a_sel = mem_forward;
		else if (i_WB_rd_wren & (WB_rd_addr != 5'b0) & (WB_rd_addr == EX_rs1_addr))	o_forward_a_sel = wb_forward;
		else o_forward_a_sel = no_forward;
		
		if(i_MEM_rd_wren & (MEM_rd_addr != 5'b0) & (MEM_rd_addr == EX_rs2_addr)) 		o_forward_b_sel = mem_forward;
		else if (i_WB_rd_wren & (WB_rd_addr != 5'b0) & (WB_rd_addr == EX_rs2_addr))	o_forward_b_sel = wb_forward;
		else o_forward_b_sel = no_forward;		

	end

endmodule 















