module branch_prediction(
	
	input  logic			i_clk,
	input  logic			i_rst_n,
	input  logic [31:0] 	i_IF_pc,
	input  logic [31:0] 	i_ID_pc,
	input  logic [31:0] 	i_EX_pc,
	input  logic [31:0] 	i_EX_pc_four,
	
	input  logic [31:0] 	i_alu_data,
	
	input  logic [31:0] 	i_IF_inst,
	input  logic [31:0] 	i_EX_inst,
	
	input  logic			i_brc_taken,
	
	output logic 			o_flush,
	output logic [31:0]	o_next_pc
	
);

//DEFINE-----------------------------------------
	localparam [4:0] 	B_TYPE = 5'b11000,
						JAL    = 5'b11011,
						JALR   = 5'b11001;
							
//-----------------------------------------------
	logic [9:0] IF_index, EX_index;
	assign IF_index = i_IF_pc[11:2];
	assign EX_index = i_EX_pc[11:2];
	
	logic [19:0] IF_tag, EX_tag;
	assign IF_tag = i_IF_pc[31:12];
	assign EX_tag = i_EX_pc[31:12];
	
	logic [4:0] EX_opcode, IF_opcode;
	assign EX_opcode = i_EX_inst[6:2];
	assign IF_opcode = i_IF_inst[6:2];

	logic jump_branch_EX, jump_branch_IF; //detect jump/branch instruction
	assign jump_branch_EX = (EX_opcode == B_TYPE) | (EX_opcode == JAL) | (EX_opcode == JALR);
	assign jump_branch_IF = (IF_opcode == B_TYPE) | (IF_opcode == JAL) | (IF_opcode == JALR);
	
//BTB_cache-------------------------------------- 
	reg [50:0] btb [1023:0];
	/*
	initial
	begin
		integer i;
		for(i = 0; i < 1024; i++) btb[i] <= 51'b0;
	end
	*/
	always_ff @(posedge i_clk or negedge i_rst_n) begin: proc_update_btb
		
		if(~i_rst_n) begin 
			integer i;
			for(i = 0; i < 1024; i++) btb[i] <= 51'b0;
		end else if(jump_branch_EX) btb[EX_index] <= {1'b1, EX_tag, i_alu_data[31:2]};
		
	end
	
	logic [31:0] btb_pc_predict;
	assign btb_pc_predict = {btb[IF_index][29:0], 2'b00};
	
	logic btb_valid;
	assign btb_valid = btb[IF_index][50];
	
	logic [19:0] btb_tag;
	assign btb_tag = btb[IF_index][49:30];
	
//-----------------------------------------------
	logic hit;
	assign hit = btb_valid & (btb_tag == IF_tag) & jump_branch_IF;// btb valid, tag IF equal to tag btb, jump/branch instruction

	logic [31:0] EX_true_pc, IF_predict_pc;

	assign IF_predict_pc = hit ? btb_pc_predict : (i_IF_pc + 32'd4);//pc_predict
	assign EX_true_pc = i_brc_taken ? i_alu_data : i_EX_pc_four; 	//pc_true
	
	assign o_flush = jump_branch_EX & (EX_true_pc != i_ID_pc);	//check_predict_EX_stage
	assign o_next_pc = o_flush ? EX_true_pc : IF_predict_pc; //fix_pc
	
endmodule	
