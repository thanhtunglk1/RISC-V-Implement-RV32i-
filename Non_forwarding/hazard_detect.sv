module hazard_detect(

	input logic  [31:0] i_EX_inst,   //rd
	input logic			  i_EX_rd_wren,
	
	input logic  [31:0] i_MEM_inst,  //rd
	input logic			  i_MEM_rd_wren,
	
	input logic  [31:0] i_ID_inst,
	input logic			  i_rs1_en,		//ID stage
	input logic			  i_rs2_en,		//ID stage
	
	output logic 		  o_pc_en,
	output logic		  o_IF_ID_stall,
	output logic		  o_ID_EX_flush

);

	logic [4:0] ID_rs1_addr, ID_rs2_addr, EX_rd_addr, MEM_rd_addr;
	
	assign ID_rs1_addr = i_ID_inst[19:15];
	assign ID_rs2_addr = i_ID_inst[24:20];
	
	assign EX_rd_addr  = i_EX_inst[11:7];
	assign MEM_rd_addr = i_MEM_inst[11:7];
	
	
	logic hazard_rs1, hazard_rs2;
	//kiểm tra hazard gây ra bởi rs1, rs2
	// rs1_en or rs2_en enable => addr != 0 => rd_wren in EX, MEM stage enable => rs1_addr or rs2_addr == rd_addr (MEM/EX) => hazard_data
	//assign hazard_rs1 = i_rs1_en & (((EX_rd_addr != 5'b0) & i_EX_rd_wren & (ID_rs1_addr == EX_rd_addr)) | ((MEM_rd_addr != 5'b0) & i_MEM_rd_wren & (ID_rs1_addr == MEM_rd_addr)));
	//assign hazard_rs2 = i_rs2_en & (((EX_rd_addr != 5'b0) & i_EX_rd_wren & (ID_rs2_addr == EX_rd_addr)) | ((MEM_rd_addr != 5'b0) & i_MEM_rd_wren & (ID_rs2_addr == MEM_rd_addr)));
	//assign hazard_detect = hazard_rs1 | hazard_rs2;

	assign hazard_rs1 = i_rs1_en & ((i_EX_rd_wren && (EX_rd_addr != 5'b0) && (EX_rd_addr == ID_rs1_addr)) || (i_MEM_rd_wren && (MEM_rd_addr != 5'b0) && (MEM_rd_addr == ID_rs1_addr)));
	assign hazard_rs2 = i_rs2_en & ((i_EX_rd_wren && (EX_rd_addr != 5'b0) && (EX_rd_addr == ID_rs2_addr)) || (i_MEM_rd_wren && (MEM_rd_addr != 5'b0) && (MEM_rd_addr == ID_rs2_addr)));

	always_comb begin: proc_stall_flush
			
		if(hazard_rs1 || hazard_rs2) begin
		
			o_pc_en 			= 1'b0;
			o_IF_ID_stall		= 1'b1;
			o_ID_EX_flush		= 1'b1;
		
		end else begin

			o_pc_en 			= 1'b1;
			o_IF_ID_stall		= 1'b0;
			o_ID_EX_flush		= 1'b0;
					
		end
	
	end

endmodule 







