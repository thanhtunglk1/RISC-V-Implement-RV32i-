module hazard_detect(

	input logic  [31:0] i_EX_inst,   //rd
	input logic			  i_EX_rd_wren,
	
	input logic  [31:0] i_ID_inst,
	input logic			  i_rs1_en,		//ID stage
	input logic			  i_rs2_en,		//ID stage

	input logic	 [31:0]	i_WB_inst,
	input logic	 		i_WB_rd_wren,
	
	output logic 		  o_pc_en,
	output logic		  o_IF_ID_stall,
	output logic		  o_ID_EX_flush

);

	logic [4:0] ID_rs1_addr, ID_rs2_addr, EX_rd_addr, WB_rd_addr;
	logic [6:0] EX_opcode;
	
	assign ID_rs1_addr = i_ID_inst[19:15];
	assign ID_rs2_addr = i_ID_inst[24:20];
	assign EX_opcode   = i_EX_inst[6:0];
	
	assign EX_rd_addr  = i_EX_inst[11:7];
	assign WB_rd_addr  = i_WB_inst[11:7];
	
	
	logic load_hazard, wb_hazard;

	assign load_hazard = (EX_opcode == 7'h3) && (EX_rd_addr != 5'b0) && ((EX_rd_addr == ID_rs1_addr) || (EX_rd_addr == ID_rs2_addr));
	//assign wb_hazard   = i_WB_rd_wren && (WB_rd_addr != 0) && ((WB_rd_addr == ID_rs1_addr) || (WB_rd_addr == ID_rs2_addr));

	always_comb begin: proc_stall_flush
		/*if(wb_hazard) begin

			o_pc_en 				= 1'b0;
			o_IF_ID_stall		= 1'b1;
			o_ID_EX_flush		= 1'b1;

		end else */if(load_hazard) begin
		
			o_pc_en 				= 1'b0;
			o_IF_ID_stall		= 1'b1;
			o_ID_EX_flush		= 1'b1;
		
		end else begin

			o_pc_en 				= 1'b1;
			o_IF_ID_stall		= 1'b0;
			o_ID_EX_flush		= 1'b0;
					
		end
	
	end

endmodule 







