module EX_MEM(

	input logic 		  i_clk,
	input logic 		  i_rst_n,
	
	//IF-ID-EX-MEM
	input logic  [31:0] i_EX_pc,			//pc_debug
	input logic  [31:0] i_EX_pc_four,	//WB
	input logic  [31:0] i_EX_inst,		//func3, rd_addr
	input logic			  i_EX_mispred,
	
	output logic [31:0] o_MEM_pc,
	output logic [31:0] o_MEM_pc_four,
	output logic [31:0] o_MEM_inst,
	output logic		  o_MEM_mispred,
	
	//LSU
	input logic  [31:0] i_EX_alu_data,	//LSU address
	input logic  [31:0] i_EX_rs2_data,	//LSU store data
	
	output logic [31:0] o_MEM_alu_data,	
	output logic [31:0] o_MEM_rs2_data,	
	
	//Control unit
	input logic 		  i_EX_mem_wren,
	input logic 		  i_EX_rd_wren,
	input logic  [1:0]  i_EX_wb_sel,
	input logic			  i_EX_insn_vld,
	
	output logic 		  o_MEM_mem_wren,
	output logic 		  o_MEM_rd_wren,
	output logic [1:0]  o_MEM_wb_sel,
	output logic		  o_MEM_insn_vld
	
);

	always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_EX_MEM
		
		if(~i_rst_n) begin
		
			o_MEM_pc			<= 32'b0;
			o_MEM_pc_four	<= 32'b0;
			o_MEM_inst		<= 32'b0;
			o_MEM_mispred	<= 1'b0;
			
			o_MEM_alu_data	<= 32'b0;
			o_MEM_rs2_data	<= 32'b0;
			
			o_MEM_mem_wren	<= 1'b0;
			o_MEM_rd_wren	<= 1'b0;
			o_MEM_wb_sel	<= 2'b01;
			o_MEM_insn_vld <= 1'b0;
			
		end else begin
			
			o_MEM_pc			<= i_EX_pc;
			o_MEM_pc_four	<= i_EX_pc_four;
			o_MEM_inst		<= i_EX_inst;
			o_MEM_mispred	<= i_EX_mispred;
			
			o_MEM_alu_data	<= i_EX_alu_data;
			o_MEM_rs2_data	<= i_EX_rs2_data;
			
			o_MEM_mem_wren	<= i_EX_mem_wren;
			o_MEM_rd_wren	<= i_EX_rd_wren;
			o_MEM_wb_sel	<= i_EX_wb_sel;
			o_MEM_insn_vld <= i_EX_insn_vld;
			
		end
		
	end


endmodule 