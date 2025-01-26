module ID_EX(

	input logic 		  i_clk,
	input logic			  i_rst_n,
	input logic			  i_flush,
	
	//IF-ID-EX
	input logic  [31:0] i_ID_pc_four,
	input logic  [31:0] i_ID_pc,	
	input logic  [31:0] i_ID_inst,	//use it's func3 to control LSU at MEM, rd_addr to regfile
	input logic			  i_ID_mispred,
	
	output logic [31:0] o_EX_pc_four,
	output logic [31:0] o_EX_pc,  
	output logic [31:0] o_EX_inst,	//use it's func3 to control LSU at MEM, rd_addr to regfile
	output logic		  o_EX_mispred,
	
	//ID-EX immediate generation
	input logic	 [31:0] i_ID_imm_data,
	output logic [31:0] o_EX_imm_data,

	//ID-EX regfile
	input logic  [31:0] i_ID_rs1_data,
	input logic  [31:0] i_ID_rs2_data,
	
	output logic [31:0] o_EX_rs1_data,
	output logic [31:0] o_EX_rs2_data,
	
	//ID-EX control unit
		//note design again Control Unit (remove br_less and br_equal and pc_sel) and BRC (move BRC from ID to EX, use instruction)  
	input logic  		  i_ID_rd_wren, 	//return to regfile at WB stage
	input logic			  i_ID_opa_sel,
	input logic			  i_ID_opb_sel,
	input logic			  i_ID_mem_wren,	//lsu control
	//input logic		  i_ID_mem_rden,	//lsu control (available if use sram)
	input logic  [3:0]  i_ID_alu_op,
	input logic			  i_ID_br_un,
	input logic  [1:0]  i_ID_wb_sel,
	input logic			  i_ID_insn_vld,
	 
	output logic		  o_EX_rd_wren, 	//return to regfile at WB stage
	output logic		  o_EX_opa_sel,
	output logic		  o_EX_opb_sel,
	output logic		  o_EX_mem_wren,	//lsu control
	//output logic		  o_EX_mem_rden,	//lsu control (available if use sram)
	output logic [3:0]  o_EX_alu_op,
	output logic		  o_EX_br_un,
	output logic [1:0]  o_EX_wb_sel,
	output logic		  o_EX_insn_vld
	
);

	always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_ID_to_EX
		
		if(~i_rst_n) o_EX_insn_vld <= 1'b0;
		else			 o_EX_insn_vld <= i_ID_insn_vld;
		
		if(~i_rst_n) begin
			
			o_EX_pc_four	<= 32'b0;
			o_EX_pc			<= 32'b0;
			o_EX_inst		<= 32'b0;
			o_EX_mispred	<= 1'b0;
			
			o_EX_imm_data	<= 32'b0;
			
			o_EX_rs1_data	<= 32'b0;
			o_EX_rs2_data	<= 32'b0;
			
			o_EX_rd_wren	<= 1'b0;
			o_EX_opa_sel	<= 1'b0;
			o_EX_opb_sel	<= 1'b0;
			o_EX_mem_wren	<= 1'b0;
			//o_EX_mem_rden	<= 32b'0;
			o_EX_alu_op		<= 4'b0;
			o_EX_br_un		<= 1'b0;
			o_EX_wb_sel		<= 2'b10;
			
		end else if(i_flush) begin
		
			o_EX_pc_four	<= 32'b0;
			o_EX_pc			<= 32'b0;
			o_EX_inst		<= 32'b0;
			o_EX_mispred	<= 1'b1;
			
			o_EX_imm_data	<= 32'b0;
			
			o_EX_rs1_data	<= 32'b0;
			o_EX_rs2_data	<= 32'b0;
			
			o_EX_rd_wren	<= 1'b0;
			o_EX_opa_sel	<= 1'b0;
			o_EX_opb_sel	<= 1'b0;
			o_EX_mem_wren	<= 1'b0;
			//o_EX_mem_rden	<= 32b'0;
			o_EX_alu_op		<= 4'b0;
			o_EX_br_un		<= 1'b0;
			o_EX_wb_sel		<= 2'b10;
		
		end else begin
			
			o_EX_pc_four	<= i_ID_pc_four;
			o_EX_pc			<= i_ID_pc;
			o_EX_inst		<= i_ID_inst;
			o_EX_mispred	<= i_ID_mispred;
			
			o_EX_imm_data	<= i_ID_imm_data;
			
			o_EX_rs1_data	<= i_ID_rs1_data;
			o_EX_rs2_data	<= i_ID_rs2_data;
			
			o_EX_rd_wren	<= i_ID_rd_wren;
			o_EX_opa_sel	<= i_ID_opa_sel;
			o_EX_opb_sel	<= i_ID_opb_sel;
			o_EX_mem_wren	<= i_ID_mem_wren;
			//o_EX_mem_rden	<= i_ID_mem_rden;
			o_EX_alu_op		<= i_ID_alu_op;
			o_EX_br_un		<= i_ID_br_un;
			o_EX_wb_sel		<= i_ID_wb_sel;
			
		end
	end
	
endmodule 
















