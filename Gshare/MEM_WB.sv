module MEM_WB (

	input  logic 		  i_clk,
	input  logic 		  i_rst_n,
	
	//IF-ID-EX-MEM
	input logic  [31:0] i_MEM_pc,			//pc_debug
	input logic  [31:0] i_MEM_pc_four,	//WB
	input logic  [31:0] i_MEM_inst,		//func3, rd_addr
	input logic			  i_MEM_mispred,
	
	output logic [31:0] o_WB_pc,
	output logic [31:0] o_WB_pc_four,
	output logic [31:0] o_WB_inst,
	output logic		  o_WB_mispred,

	input logic  [31:0] i_MEM_alu_data,
	input logic  [31:0] i_MEM_ld_data,
	
	output logic [31:0] o_WB_alu_data,
	output logic [31:0] o_WB_ld_data,
	
	input logic 		  i_MEM_rd_wren,
	input logic  [1:0]  i_MEM_wb_sel,
	input logic			  i_MEM_insn_vld,
	
	output logic 		  o_WB_rd_wren,
	output logic [1:0]  o_WB_wb_sel,
	output logic		  o_WB_insn_vld
	
);

	always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_MEM_WB
		
		if(~i_rst_n) begin
			
			o_WB_pc			<= 32'b0;
			o_WB_pc_four	<= 32'b0;
			o_WB_inst		<= 32'b0;
			o_WB_mispred	<= 1'b0;
			o_WB_alu_data	<= 32'b0;
			o_WB_ld_data	<= 32'b0;
			o_WB_wb_sel		<= 2'b01;
			o_WB_rd_wren	<= 1'b0;
			o_WB_insn_vld	<= 1'b0;
			
		end else begin
			
			o_WB_pc			<= i_MEM_pc;
			o_WB_pc_four	<= i_MEM_pc_four;
			o_WB_inst		<= i_MEM_inst;
			o_WB_mispred	<= i_MEM_mispred;
			o_WB_alu_data	<= i_MEM_alu_data;
			o_WB_ld_data	<= i_MEM_ld_data;
			o_WB_wb_sel		<= i_MEM_wb_sel;
			o_WB_rd_wren	<= i_MEM_rd_wren;
			o_WB_insn_vld	<= i_MEM_insn_vld;
			
		end
		
	end

endmodule 